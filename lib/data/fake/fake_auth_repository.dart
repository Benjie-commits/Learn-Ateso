import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../models/app_user.dart';
import '../repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository() : _controller = StreamController<AppUser?>.broadcast() {
    // Mirrors real FirebaseAuth.authStateChanges(), which always fires once
    // with the current state (null, for a fresh fake session) so listeners
    // like AuthProvider can tell "no session" apart from "still checking".
    Future.microtask(() => _controller.add(_currentUser));
  }

  final _uuid = const Uuid();
  final StreamController<AppUser?> _controller;
  final Map<String, String> _passwordsByEmail = {};
  final Map<String, AppUser> _usersByEmail = {};

  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() => _controller.stream;

  void _setCurrentUser(AppUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  Future<AppUser> signInAnonymously() async {
    final user = AppUser(
      id: _uuid.v4(),
      name: 'Guest',
      email: '',
      isGuest: true,
    );
    _setCurrentUser(user);
    return user;
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_usersByEmail.containsKey(email)) {
      throw StateError('An account already exists for $email');
    }
    final user = AppUser(id: _uuid.v4(), name: name, email: email, isGuest: false);
    _usersByEmail[email] = user;
    _passwordsByEmail[email] = password;
    _setCurrentUser(user);
    return user;
  }

  @override
  Future<AppUser> logIn({required String email, required String password}) async {
    final user = _usersByEmail[email];
    if (user == null || _passwordsByEmail[email] != password) {
      throw StateError('Invalid email or password');
    }
    _setCurrentUser(user);
    return user;
  }

  @override
  Future<AppUser> upgradeGuestToFullAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final guest = _currentUser;
    if (guest == null || !guest.isGuest) {
      throw StateError('No guest session to upgrade');
    }
    // Same id preserved across the upgrade, mirroring Firebase's
    // linkWithCredential behavior of keeping the anonymous UID.
    final upgraded = AppUser(id: guest.id, name: name, email: email, isGuest: false);
    _usersByEmail[email] = upgraded;
    _passwordsByEmail[email] = password;
    _setCurrentUser(upgraded);
    return upgraded;
  }

  @override
  Future<void> signOut() async {
    _setCurrentUser(null);
  }
}

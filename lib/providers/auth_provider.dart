import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/repositories/auth_repository.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository) {
    _subscription = _repository.authStateChanges().listen((user) {
      _user = user;
      _isInitialized = true;
      notifyListeners();
    });
    _user = _repository.currentUser;
  }

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _subscription;

  AppUser? _user;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isGuest => _user?.isGuest ?? false;
  bool get isSignedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// True once the first authStateChanges event has arrived, i.e. once we
  /// definitively know whether a session exists (real Firebase Auth
  /// restores a persisted session asynchronously, so this distinguishes
  /// "still checking" from "definitely signed out" for AuthGate).
  bool get isInitialized => _isInitialized;

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> continueAsGuest() {
    return _run(() => _repository.signInAnonymously());
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(() => _repository.signUp(name: name, email: email, password: password));
  }

  Future<bool> logIn({required String email, required String password}) {
    return _run(() => _repository.logIn(email: email, password: password));
  }

  Future<bool> upgradeGuestToFullAccount({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(() => _repository.upgradeGuestToFullAccount(
          name: name,
          email: email,
          password: password,
        ));
  }

  Future<void> signOut() => _repository.signOut();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

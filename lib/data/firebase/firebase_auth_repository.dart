import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../../models/app_user.dart';
import '../repositories/auth_repository.dart';
import 'firestore_paths.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb_auth.FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? fb_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(FirestorePaths.users).doc(uid);

  AppUser _mapUser(fb_auth.User user, {required bool isGuest}) {
    return AppUser(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      isGuest: isGuest,
    );
  }

  Future<AppUser> _hydrateUser(fb_auth.User user) async {
    final snapshot = await _userDoc(user.uid).get();
    final isGuest = snapshot.data()?['isGuest'] as bool? ?? user.isAnonymous;
    return AppUser(
      id: user.uid,
      name: snapshot.data()?['name'] as String? ?? user.displayName ?? '',
      email: snapshot.data()?['email'] as String? ?? user.email ?? '',
      isGuest: isGuest,
    );
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _hydrateUser(user);
    });
  }

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    // Synchronous best-effort mapping; authStateChanges() provides the
    // Firestore-hydrated version for reactive consumers.
    return _mapUser(user, isGuest: user.isAnonymous);
  }

  @override
  Future<AppUser> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    final user = credential.user!;
    await _userDoc(user.uid).set({
      'name': 'Guest',
      'email': '',
      'isGuest': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return _mapUser(user, isGuest: true);
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name);
    await _userDoc(user.uid).set({
      'name': name,
      'email': email,
      'isGuest': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return AppUser(id: user.uid, name: name, email: email, isGuest: false);
  }

  @override
  Future<AppUser> logIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _hydrateUser(credential.user!);
  }

  @override
  Future<AppUser> upgradeGuestToFullAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final guest = _auth.currentUser;
    if (guest == null || !guest.isAnonymous) {
      throw StateError('No guest session to upgrade');
    }
    // linkWithCredential preserves the anonymous UID, which is what carries
    // the guest's existing progress documents over to the full account.
    final fbCredential = fb_auth.EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    final linked = await guest.linkWithCredential(fbCredential);
    final user = linked.user!;
    await user.updateDisplayName(name);
    await _userDoc(user.uid).set({
      'name': name,
      'email': email,
      'isGuest': false,
    }, SetOptions(merge: true));
    return AppUser(id: user.uid, name: name, email: email, isGuest: false);
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

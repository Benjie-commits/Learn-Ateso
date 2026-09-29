import '../../models/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<AppUser> signInAnonymously();

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<AppUser> logIn({required String email, required String password});

  /// Upgrades the current guest user to a full account while preserving the
  /// same user id, so progress recorded as a guest carries over untouched.
  /// The Firebase implementation backs this with `linkWithCredential`, which
  /// preserves the Firebase Auth UID the same way.
  Future<AppUser> upgradeGuestToFullAccount({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();
}

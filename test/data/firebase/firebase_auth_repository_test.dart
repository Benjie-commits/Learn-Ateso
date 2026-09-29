import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_ateso/data/firebase/firebase_auth_repository.dart';

void main() {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late FirebaseAuthRepository repo;

  setUp(() {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    repo = FirebaseAuthRepository(auth: auth, firestore: firestore);
  });

  group('FirebaseAuthRepository', () {
    test('signInAnonymously creates a guest user and a users/{uid} doc', () async {
      final user = await repo.signInAnonymously();

      expect(user.isGuest, isTrue);
      expect(repo.currentUser?.id, user.id);

      final doc = await firestore.collection('users').doc(user.id).get();
      expect(doc.data()?['isGuest'], isTrue);
    });

    test('signUp creates a non-guest user', () async {
      final user = await repo.signUp(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      );

      expect(user.isGuest, isFalse);
      expect(user.email, 'test@example.com');
    });

    // upgradeGuestToFullAccount's UID-preservation behavior (linkWithCredential)
    // is verified against the real learn-ateso Firebase project instead of a
    // mock here: firebase_auth_mocks' MockUser.linkWithCredential asserts the
    // linked credential's anonymity matches the original user's, which can't
    // represent an anonymous->permanent transition at all. See the fake-backed
    // equivalent test in fake_auth_repository_test.dart for the same behavior
    // exercised against a real (non-mocked-library) implementation.

    test('upgradeGuestToFullAccount throws when there is no guest session', () async {
      expect(
        () => repo.upgradeGuestToFullAccount(
          name: 'x',
          email: 'x@example.com',
          password: 'password123',
        ),
        throwsStateError,
      );
    });
  });
}

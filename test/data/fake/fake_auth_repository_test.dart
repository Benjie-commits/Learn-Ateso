import 'package:flutter_test/flutter_test.dart';
import 'package:learn_ateso/data/fake/fake_auth_repository.dart';

void main() {
  group('FakeAuthRepository', () {
    test('signInAnonymously creates a guest user', () async {
      final repo = FakeAuthRepository();
      final user = await repo.signInAnonymously();

      expect(user.isGuest, isTrue);
      expect(repo.currentUser?.id, user.id);
    });

    test('upgradeGuestToFullAccount preserves the same user id', () async {
      final repo = FakeAuthRepository();
      final guest = await repo.signInAnonymously();

      final upgraded = await repo.upgradeGuestToFullAccount(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      );

      expect(upgraded.id, guest.id);
      expect(upgraded.isGuest, isFalse);
      expect(upgraded.email, 'test@example.com');
    });

    test('upgradeGuestToFullAccount throws when there is no guest session', () async {
      final repo = FakeAuthRepository();
      expect(
        () => repo.upgradeGuestToFullAccount(
          name: 'x',
          email: 'x@example.com',
          password: 'password123',
        ),
        throwsStateError,
      );
    });

    test('logIn rejects wrong password', () async {
      final repo = FakeAuthRepository();
      await repo.signUp(name: 'A', email: 'a@example.com', password: 'correct');

      expect(
        () => repo.logIn(email: 'a@example.com', password: 'wrong'),
        throwsStateError,
      );
    });
  });
}

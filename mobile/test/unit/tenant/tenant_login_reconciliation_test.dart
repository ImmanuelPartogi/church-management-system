import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:church_management_mobile/core/error/failures.dart';
import 'package:church_management_mobile/core/storage/secure_storage_service.dart';
import 'package:church_management_mobile/features/auth/domain/entities/user.dart';
import 'package:church_management_mobile/features/church/domain/entities/church.dart';
import 'package:church_management_mobile/features/church/domain/repositories/church_repository.dart';
import 'package:church_management_mobile/features/church/presentation/providers/tenant_provider.dart';

class FakeSecureStorageService implements SecureStorageService {
  Map<String, dynamic>? storedChurch;

  @override
  Future<void> saveActiveChurch(Map<String, dynamic> churchData) async {
    storedChurch = churchData;
  }

  @override
  Future<Map<String, dynamic>?> getActiveChurch() async {
    return storedChurch;
  }

  @override
  Future<void> removeActiveChurch() async {
    storedChurch = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeChurchRepository implements ChurchRepository {
  final List<Church> churches;
  FakeChurchRepository(this.churches);

  @override
  Future<Either<Failure, List<Church>>> getChurches() async => Right(churches);
}

void main() {
  group('Tenant Login Reconciliation Matrix Tests (ADR 7.4)', () {
    late FakeSecureStorageService fakeStorage;
    late FakeChurchRepository fakeRepo;
    late TenantNotifier notifier;

    const churchA = Church(id: 1, uuid: 'uuid-a', name: 'Gereja A', slug: 'gereja-a');
    const churchB = Church(id: 2, uuid: 'uuid-b', name: 'Gereja B', slug: 'gereja-b');
    const churchC = Church(id: 3, uuid: 'uuid-c', name: 'Gereja C', slug: 'gereja-c');

    setUp(() async {
      fakeStorage = FakeSecureStorageService();
      fakeRepo = FakeChurchRepository([churchA, churchB, churchC]);
      notifier = TenantNotifier(fakeStorage, fakeRepo);
      await notifier.init();
    });

    test('Case 1: Super Admin retains current church selection intact', () async {
      await notifier.selectChurch(churchB);
      expect(notifier.state.activeChurch?.slug, 'gereja-b');

      const superAdminUser = User(
        id: 99,
        name: 'Super Admin',
        email: 'superadmin@church.org',
        roles: ['super_admin'],
        memberships: [],
      );

      final result = await notifier.reconcileWithUser(superAdminUser);

      expect(result?.slug, 'gereja-b');
      expect(notifier.state.activeChurch?.slug, 'gereja-b');
      expect(notifier.state.promptMultiMembershipSelection, isFalse);
    });

    test('Case 2: Current church matches user membership -> retains selection intact', () async {
      await notifier.selectChurch(churchA);
      expect(notifier.state.activeChurch?.slug, 'gereja-a');

      const memberUser = User(
        id: 10,
        name: 'John Member',
        email: 'john@example.com',
        roles: ['member'],
        memberships: [
          UserChurchMembership(
            churchId: 1,
            churchUuid: 'uuid-a',
            churchName: 'Gereja A',
            churchSlug: 'gereja-a',
            role: 'member',
          ),
          UserChurchMembership(
            churchId: 3,
            churchUuid: 'uuid-c',
            churchName: 'Gereja C',
            churchSlug: 'gereja-c',
            role: 'member',
          ),
        ],
      );

      final result = await notifier.reconcileWithUser(memberUser);

      expect(result?.slug, 'gereja-a');
      expect(notifier.state.activeChurch?.slug, 'gereja-a');
      expect(notifier.state.promptMultiMembershipSelection, isFalse);
    });

    test('Case 3: Mismatch with single membership -> Auto-switches and writes to storage & state', () async {
      // Guest browsing Church B
      await notifier.selectChurch(churchB);
      expect(notifier.state.activeChurch?.slug, 'gereja-b');

      // User authenticates, belongs strictly to Church A
      const singleMemberUser = User(
        id: 20,
        name: 'Alice Member',
        email: 'alice@example.com',
        roles: ['member'],
        memberships: [
          UserChurchMembership(
            churchId: 1,
            churchUuid: 'uuid-a',
            churchName: 'Gereja A',
            churchSlug: 'gereja-a',
            role: 'member',
          ),
        ],
      );

      final result = await notifier.reconcileWithUser(singleMemberUser);

      // Reconciled to Church A
      expect(result?.id, 1);
      expect(result?.slug, 'gereja-a');
      expect(notifier.state.activeChurch?.id, 1);
      expect(notifier.state.activeChurch?.slug, 'gereja-a');
      expect(notifier.state.promptMultiMembershipSelection, isFalse);

      // Persisted to SecureStorage
      expect(fakeStorage.storedChurch?['slug'], 'gereja-a');
      expect(fakeStorage.storedChurch?['id'], 1);
    });

    test('Case 4: Mismatch with multi-membership (>= 2) -> Deterministic primary fallback + triggers prompt flag', () async {
      // Guest browsing Church B
      await notifier.selectChurch(churchB);
      expect(notifier.state.activeChurch?.slug, 'gereja-b');

      // User has memberships in Church A (primary) and Church C
      const multiMemberUser = User(
        id: 30,
        name: 'David Multi',
        email: 'david@example.com',
        roles: ['member'],
        memberships: [
          UserChurchMembership(
            churchId: 1,
            churchUuid: 'uuid-a',
            churchName: 'Gereja A',
            churchSlug: 'gereja-a',
            role: 'member',
          ),
          UserChurchMembership(
            churchId: 3,
            churchUuid: 'uuid-c',
            churchName: 'Gereja C',
            churchSlug: 'gereja-c',
            role: 'elder',
          ),
        ],
      );

      final result = await notifier.reconcileWithUser(multiMemberUser);

      // Deterministic fallback to Church A (first membership)
      expect(result?.id, 1);
      expect(result?.slug, 'gereja-a');
      expect(notifier.state.activeChurch?.slug, 'gereja-a');
      // Prompt flag is set to true for UI dialog presentation
      expect(notifier.state.promptMultiMembershipSelection, isTrue);

      // Persisted in SecureStorage
      expect(fakeStorage.storedChurch?['slug'], 'gereja-a');
    });

    test('Parallel reconcileWithUser calls are deduplicated into a single execution', () async {
      await notifier.selectChurch(churchB);

      const singleMemberUser = User(
        id: 40,
        name: 'Single Member',
        email: 'single@example.com',
        roles: ['member'],
        memberships: [
          UserChurchMembership(
            churchId: 1,
            churchUuid: 'uuid-a',
            churchName: 'Gereja A',
            churchSlug: 'gereja-a',
            role: 'member',
          ),
        ],
      );

      // Fire 3 simultaneous concurrent reconciliation calls
      final results = await Future.wait([
        notifier.reconcileWithUser(singleMemberUser),
        notifier.reconcileWithUser(singleMemberUser),
        notifier.reconcileWithUser(singleMemberUser),
      ]);

      // All 3 return the exact same reconciled church instance
      expect(results[0]?.id, 1);
      expect(results[1]?.id, 1);
      expect(results[2]?.id, 1);
      expect(notifier.state.activeChurch?.slug, 'gereja-a');
    });

    test('dismissMultiMembershipPrompt resets flag to false', () async {
      await notifier.selectChurch(churchB);

      const multiMemberUser = User(
        id: 50,
        name: 'Multi Member',
        email: 'multi@example.com',
        roles: ['member'],
        memberships: [
          UserChurchMembership(
            churchId: 1,
            churchUuid: 'uuid-a',
            churchName: 'Gereja A',
            churchSlug: 'gereja-a',
            role: 'member',
          ),
          UserChurchMembership(
            churchId: 3,
            churchUuid: 'uuid-c',
            churchName: 'Gereja C',
            churchSlug: 'gereja-c',
            role: 'member',
          ),
        ],
      );

      await notifier.reconcileWithUser(multiMemberUser);
      expect(notifier.state.promptMultiMembershipSelection, isTrue);

      notifier.dismissMultiMembershipPrompt();
      expect(notifier.state.promptMultiMembershipSelection, isFalse);
    });
  });
}

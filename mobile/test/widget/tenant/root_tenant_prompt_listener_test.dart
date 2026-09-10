import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:church_management_mobile/app/router/app_router.dart';
import 'package:church_management_mobile/app/widgets/root_tenant_prompt_listener.dart';
import 'package:church_management_mobile/core/error/failures.dart';
import 'package:church_management_mobile/core/storage/secure_storage_service.dart';
import 'package:church_management_mobile/features/auth/domain/entities/user.dart';
import 'package:church_management_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:church_management_mobile/features/church/domain/entities/church.dart';
import 'package:church_management_mobile/features/church/domain/repositories/church_repository.dart';
import 'package:church_management_mobile/features/church/data/repositories/church_repository_impl.dart';
import 'package:church_management_mobile/features/church/presentation/providers/tenant_provider.dart';

class FakeSecureStorageService implements SecureStorageService {
  @override
  Future<void> saveActiveChurch(Map<String, dynamic> churchData) async {}

  @override
  Future<Map<String, dynamic>?> getActiveChurch() async => null;

  @override
  Future<void> removeActiveChurch() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeChurchRepository implements ChurchRepository {
  @override
  Future<Either<Failure, List<Church>>> getChurches() async =>
      const Right(<Church>[]);
}

void main() {
  testWidgets(
      'RootTenantPromptListener presents multi-membership bottom sheet from any screen',
      (tester) async {
    const multiUser = User(
      id: 99,
      name: 'Maria Member',
      email: 'maria@example.com',
      roles: ['member'],
      memberships: [
        UserChurchMembership(
          churchId: 1,
          churchUuid: 'uuid-1',
          churchName: 'HKBP Bandung',
          churchSlug: 'hkbp-bandung',
          role: 'member',
        ),
        UserChurchMembership(
          churchId: 2,
          churchUuid: 'uuid-2',
          churchName: 'HKBP Sudirman',
          churchSlug: 'hkbp-sudirman',
          role: 'elder',
        ),
      ],
    );

    late TenantNotifier notifier;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(FakeSecureStorageService()),
          churchRepositoryProvider.overrideWithValue(FakeChurchRepository()),
          authNotifierProvider.overrideWith(() {
            return _MockAuthNotifier(const AuthState.authenticated(multiUser));
          }),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            notifier = ref.watch(tenantProvider.notifier);
            return MaterialApp(
              navigatorKey: rootNavigatorKey,
              builder: (ctx, ch) => RootTenantPromptListener(child: ch!),
              home: const Scaffold(
                body: Center(child: Text('Any Sub Screen')),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Any Sub Screen'), findsOneWidget);
    expect(find.text('Pilih Gereja Aktif'), findsNothing);

    // Trigger reconciliation mismatch with multi-membership
    await notifier.reconcileWithUser(multiUser);
    await tester.pumpAndSettle();

    // Verify modal bottom sheet appeared on top of the sub screen
    expect(find.text('Pilih Gereja Aktif'), findsOneWidget);
    expect(find.text('HKBP Bandung'), findsOneWidget);
    expect(find.text('HKBP Sudirman'), findsOneWidget);
  });
}

class _MockAuthNotifier extends AuthNotifier {
  final AuthState _initialState;

  _MockAuthNotifier(this._initialState);

  @override
  AuthState build() => _initialState;
}

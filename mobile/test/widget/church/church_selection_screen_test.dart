import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:church_management_mobile/core/storage/secure_storage_service.dart';
import 'package:church_management_mobile/features/church/data/repositories/church_repository_impl.dart';
import 'package:church_management_mobile/features/church/domain/entities/church.dart';
import 'package:church_management_mobile/features/church/presentation/providers/tenant_provider.dart';
import 'package:church_management_mobile/features/church/presentation/screens/church_selection_screen.dart';
import '../../unit/tenant/tenant_login_reconciliation_test.dart';

void main() {
  group('ChurchSelectionScreen Widget Tests', () {
    const church1 = Church(
      id: 1,
      uuid: 'uuid-1',
      name: 'HKBP Sudirman Jakarta',
      slug: 'hkbp-sudirman',
      address: 'Jl. Jend. Sudirman No. 1',
    );
    const church2 = Church(
      id: 2,
      uuid: 'uuid-2',
      name: 'HKBP Bandung',
      slug: 'hkbp-bandung',
      address: 'Jl. Riau No. 5',
    );

    late FakeChurchRepository fakeRepo;
    late FakeSecureStorageService fakeStorage;

    setUp(() {
      fakeRepo = FakeChurchRepository([church1, church2]);
      fakeStorage = FakeSecureStorageService();
    });

    Widget createScreenUnderTest() {
      return ProviderScope(
        overrides: [
          churchRepositoryProvider.overrideWithValue(fakeRepo),
          secureStorageServiceProvider.overrideWithValue(fakeStorage),
        ],
        child: const MaterialApp(
          home: ChurchSelectionScreen(),
        ),
      );
    }

    testWidgets('renders search field and church list from repository', (tester) async {
      await tester.pumpWidget(createScreenUnderTest());
      await tester.pumpAndSettle();

      // Verify AppBar & Title
      expect(find.text('Pilih Gereja'), findsOneWidget);

      // Verify Search TextField
      expect(find.byType(TextField), findsOneWidget);

      // Verify Churches Rendered
      expect(find.text('HKBP Sudirman Jakarta'), findsOneWidget);
      expect(find.text('HKBP Bandung'), findsOneWidget);
    });

    testWidgets('filters church list dynamically based on search query', (tester) async {
      await tester.pumpWidget(createScreenUnderTest());
      await tester.pumpAndSettle();

      // Enter search term
      await tester.enterText(find.byType(TextField), 'Bandung');
      await tester.pumpAndSettle();

      // HKBP Bandung should remain, HKBP Sudirman filtered out
      expect(find.text('HKBP Bandung'), findsOneWidget);
      expect(find.text('HKBP Sudirman Jakarta'), findsNothing);
    });

    testWidgets('tapping a church updates activeChurchProvider', (tester) async {
      final container = ProviderContainer(
        overrides: [
          churchRepositoryProvider.overrideWithValue(fakeRepo),
          secureStorageServiceProvider.overrideWithValue(fakeStorage),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ChurchSelectionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on HKBP Bandung
      await tester.tap(find.text('HKBP Bandung'));
      await tester.pumpAndSettle();

      // Verify active church in container is updated
      expect(container.read(activeChurchProvider)?.name, 'HKBP Bandung');
      expect(container.read(activeChurchProvider)?.slug, 'hkbp-bandung');

      container.dispose();
    });
  });
}

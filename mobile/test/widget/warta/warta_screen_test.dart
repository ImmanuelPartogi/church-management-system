import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:church_management_mobile/features/warta/domain/entities/warta.dart';
import 'package:church_management_mobile/features/warta/presentation/providers/warta_provider.dart';
import 'package:church_management_mobile/features/warta/presentation/screens/warta_screen.dart';
import 'package:church_management_mobile/features/warta/presentation/screens/warta_detail_screen.dart';
import 'package:church_management_mobile/features/warta/domain/repositories/warta_repository.dart';

// Stub repository for the notifier initialization override
class FakeWartaRepository implements WartaRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final fakeWartaRepositoryProvider =
    Provider<WartaRepository>((ref) => FakeWartaRepository());

void main() {
  group('WartaScreen Widget Tests', () {
    final testWartas = [
      const Warta(
        id: 1,
        title: 'Warta Minggu Pagi',
        description: 'Detail ibadah minggu pagi.',
        fileName: 'warta_pagi.pdf',
        fileSize: 102400,
        mimeType: 'application/pdf',
        publishedAt: '2026-08-14 08:00:00',
        isPublished: true,
        downloadCount: 3,
      ),
      const Warta(
        id: 2,
        title: 'Warta Minggu Sore',
        description: 'Detail ibadah minggu sore.',
        fileName: 'warta_sore.pdf',
        fileSize: 204800,
        mimeType: 'application/pdf',
        publishedAt: '2026-08-14 15:00:00',
        isPublished: true,
        downloadCount: 1,
      ),
    ];

    Widget createWartaScreen(AsyncValue<List<Warta>> listState) {
      return ProviderScope(
        overrides: [
          wartaListProvider.overrideWith(
            (ref) => listState.when(
              data: (d) async => d,
              error: (e, s) => throw e,
              loading: () => Completer<List<Warta>>().future,
            ),
          ),
        ],
        child: const MaterialApp(
          home: WartaScreen(),
        ),
      );
    }

    testWidgets('renders Loading state cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(createWartaScreen(const AsyncValue.loading()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders Empty state cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(createWartaScreen(const AsyncValue.data([])));
      await tester.pumpAndSettle();
      expect(find.text('Tidak ada warta tersedia'), findsOneWidget);
    });

    testWidgets('renders Error state cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWartaScreen(
          AsyncValue.error(Exception('Koneksi terputus'), StackTrace.empty),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Gagal memuat warta'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('renders Data list state cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(createWartaScreen(AsyncValue.data(testWartas)));
      await tester.pumpAndSettle();

      expect(find.text('Warta Minggu Pagi'), findsOneWidget);
      expect(find.text('Detail ibadah minggu pagi.'), findsOneWidget);
      expect(find.text('Warta Minggu Sore'), findsOneWidget);
      expect(find.text('100.0 KB'), findsOneWidget);
      expect(find.text('200.0 KB'), findsOneWidget);
    });
  });

  group('WartaDetailScreen Widget Tests', () {
    const testWarta = Warta(
      id: 1,
      title: 'Warta Minggu Pagi',
      description: 'Detail ibadah minggu pagi.',
      fileName: 'warta_pagi.pdf',
      fileSize: 102400,
      mimeType: 'application/pdf',
      publishedAt: '2026-08-14 08:00:00',
      isPublished: true,
      downloadCount: 3,
    );

    Widget createWartaDetailScreen({
      required AsyncValue<Warta> detailState,
      DownloadState downloadState = const DownloadState.initial(),
    }) {
      return ProviderScope(
        overrides: [
          wartaDetailProvider(1).overrideWith(
            (ref) => detailState.when(
              data: (d) async => d,
              error: (e, s) => throw e,
              loading: () => Completer<Warta>().future,
            ),
          ),
          wartaDownloadProvider(1).overrideWith((ref) {
            final notifier = WartaDownloadNotifier(FakeWartaRepository(), 1);
            notifier.state = downloadState;
            return notifier;
          }),
        ],
        child: const MaterialApp(
          home: WartaDetailScreen(id: 1),
        ),
      );
    }

    testWidgets('renders detail data cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWartaDetailScreen(
          detailState: const AsyncValue.data(testWarta),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Warta Minggu Pagi'), findsOneWidget);
      expect(find.text('Detail ibadah minggu pagi.'), findsOneWidget);
      expect(find.text('warta_pagi.pdf'), findsOneWidget);
      expect(find.text('100.0 KB'), findsOneWidget);
      expect(find.text('Baca Warta'), findsOneWidget);
      expect(find.text('Download Warta'), findsOneWidget);
    });

    testWidgets('renders download progress states',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createWartaDetailScreen(
          detailState: const AsyncValue.data(testWarta),
          downloadState: const DownloadState(
            status: DownloadStatus.downloading,
            progress: 0.5,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Mengunduh...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Mengunduh: 50%'), findsOneWidget);
    });
  });
}

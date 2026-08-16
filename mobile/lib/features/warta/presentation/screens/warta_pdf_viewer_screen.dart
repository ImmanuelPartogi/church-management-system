import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/widgets/app_state_views.dart';
import '../providers/warta_provider.dart';

class WartaPdfViewerScreen extends ConsumerStatefulWidget {
  final int id;
  final String title;

  const WartaPdfViewerScreen({
    super.key,
    required this.id,
    required this.title,
  });

  @override
  ConsumerState<WartaPdfViewerScreen> createState() =>
      _WartaPdfViewerScreenState();
}

class _WartaPdfViewerScreenState extends ConsumerState<WartaPdfViewerScreen> {
  bool _hasLoadFailed = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final wartaAsync = ref.watch(wartaDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: wartaAsync.when(
        data: (warta) {
          final pdfFileAsync = ref.watch(wartaPdfFileProvider(warta));

          return pdfFileAsync.when(
            data: (file) {
              if (_hasLoadFailed) {
                return AppErrorView(
                  message: 'Gagal membuka PDF: $_errorMessage',
                  onRetry: () {
                    setState(() {
                      _hasLoadFailed = false;
                      _errorMessage = '';
                    });
                    ref.invalidate(wartaPdfFileProvider(warta));
                  },
                );
              }

              return SfPdfViewer.file(
                file,
                onDocumentLoadFailed: (details) {
                  setState(() {
                    _hasLoadFailed = true;
                    _errorMessage = details.description;
                  });
                },
              );
            },
            loading: () =>
                const AppLoadingView(message: 'Mengunduh file PDF...'),
            error: (error, stack) => AppErrorView(
              message: 'Gagal mengunduh file PDF: $error',
              onRetry: () => ref.invalidate(wartaPdfFileProvider(warta)),
            ),
          );
        },
        loading: () => const AppLoadingView(message: 'Memuat data warta...'),
        error: (error, stack) => AppErrorView(
          message: 'Gagal memuat detail warta: $error',
          onRetry: () => ref.invalidate(wartaDetailProvider(widget.id)),
        ),
      ),
    );
  }
}

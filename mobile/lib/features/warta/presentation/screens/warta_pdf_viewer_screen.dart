import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Gagal membuka PDF: $_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _hasLoadFailed = false;
                              _errorMessage = '';
                            });
                            ref.invalidate(wartaPdfFileProvider(warta));
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
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
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Mengunduh file PDF...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal mengunduh file PDF: ${error.toString()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(wartaPdfFileProvider(warta)),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat detail warta: ${error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(wartaDetailProvider(widget.id)),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

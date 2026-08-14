import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/repositories/warta_repository_impl.dart';
import '../../domain/entities/warta.dart';
import '../../domain/repositories/warta_repository.dart';

final wartaListProvider = FutureProvider<List<Warta>>((ref) async {
  final repository = ref.watch(wartaRepositoryProvider);
  final result = await repository.getWartas(page: 1);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
});

final wartaDetailProvider = FutureProvider.family<Warta, int>((ref, id) async {
  final repository = ref.watch(wartaRepositoryProvider);
  final result = await repository.getWartaDetail(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (warta) => warta,
  );
});

final wartaPdfFileProvider =
    FutureProvider.family<File, Warta>((ref, warta) async {
  final repository = ref.watch(wartaRepositoryProvider);

  final tempDir = await getTemporaryDirectory();
  final wartaCacheDir = Directory('${tempDir.path}/warta_cache');
  if (!await wartaCacheDir.exists()) {
    await wartaCacheDir.create(recursive: true);
  }

  final file =
      File('${wartaCacheDir.path}/warta_${warta.id}_${warta.fileName}');
  if (await file.exists()) {
    return file;
  }

  final partFile = File('${file.path}.part');
  if (await partFile.exists()) {
    await partFile.delete();
  }

  final result = await repository.downloadWarta(warta.id, partFile.path);
  return result.fold(
    (failure) async {
      if (await partFile.exists()) {
        await partFile.delete();
      }
      throw Exception(failure.message);
    },
    (downloadedPartFile) async {
      final renamedFile = await downloadedPartFile.rename(file.path);
      return renamedFile;
    },
  );
});

enum DownloadStatus { idle, downloading, success, error }

class DownloadState {
  final DownloadStatus status;
  final double progress;
  final String? errorMessage;
  final String? filePath;

  const DownloadState({
    required this.status,
    required this.progress,
    this.errorMessage,
    this.filePath,
  });

  const DownloadState.initial()
      : this(status: DownloadStatus.idle, progress: 0.0);
}

class WartaDownloadNotifier extends StateNotifier<DownloadState> {
  final WartaRepository _repository;
  final int _wartaId;

  WartaDownloadNotifier(this._repository, this._wartaId)
      : super(const DownloadState.initial());

  Future<void> download({required String fileName}) async {
    File? partFile;
    try {
      state = const DownloadState(
        status: DownloadStatus.downloading,
        progress: 0.0,
      );

      final directory = await getApplicationDocumentsDirectory();
      final wartaDir = Directory('${directory.path}/wartas');
      if (!await wartaDir.exists()) {
        await wartaDir.create(recursive: true);
      }

      final uniqueFile = await _getUniqueFile(wartaDir.path, fileName);
      final finalPath = uniqueFile.path;
      partFile = File('$finalPath.part');

      if (await partFile.exists()) {
        await partFile.delete();
      }

      final result = await _repository.downloadWarta(
        _wartaId,
        partFile.path,
        onProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            state = DownloadState(
              status: DownloadStatus.downloading,
              progress: progress,
            );
          }
        },
      );

      await result.fold(
        (failure) async {
          if (partFile != null && await partFile.exists()) {
            await partFile.delete();
          }
          state = DownloadState(
            status: DownloadStatus.error,
            progress: 0.0,
            errorMessage: failure.message,
          );
        },
        (file) async {
          final renamedFile = await file.rename(finalPath);
          state = DownloadState(
            status: DownloadStatus.success,
            progress: 1.0,
            filePath: renamedFile.path,
          );
        },
      );
    } catch (e) {
      if (partFile != null && await partFile.exists()) {
        try {
          await partFile.delete();
        } catch (_) {}
      }
      state = DownloadState(
        status: DownloadStatus.error,
        progress: 0.0,
        errorMessage: 'Gagal mengunduh file: ${e.toString()}',
      );
    }
  }

  Future<File> _getUniqueFile(
      String directoryPath, String originalFileName,) async {
    var file = File('$directoryPath/$originalFileName');
    if (!await file.exists()) {
      return file;
    }

    final dotIndex = originalFileName.lastIndexOf('.');
    final name = dotIndex != -1
        ? originalFileName.substring(0, dotIndex)
        : originalFileName;
    final ext = dotIndex != -1 ? originalFileName.substring(dotIndex) : '';

    int counter = 1;
    while (true) {
      final newName = '$name ($counter)$ext';
      file = File('$directoryPath/$newName');
      if (!await file.exists()) {
        return file;
      }
      counter++;
    }
  }

  void reset() {
    state = const DownloadState.initial();
  }
}

final wartaDownloadProvider =
    StateNotifierProvider.family<WartaDownloadNotifier, DownloadState, int>(
        (ref, id) {
  final repository = ref.watch(wartaRepositoryProvider);
  return WartaDownloadNotifier(repository, id);
});

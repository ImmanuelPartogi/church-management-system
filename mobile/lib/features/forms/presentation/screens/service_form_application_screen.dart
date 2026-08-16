import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/entities/selected_document.dart';
import '../providers/service_forms_provider.dart';

class ServiceFormApplicationScreen extends ConsumerStatefulWidget {
  final int id;

  const ServiceFormApplicationScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<ServiceFormApplicationScreen> createState() =>
      _ServiceFormApplicationScreenState();
}

class _ServiceFormApplicationScreenState
    extends ConsumerState<ServiceFormApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _applicantNotesController = TextEditingController();
  final List<SelectedDocument> _documents = [];

  @override
  void dispose() {
    _applicantNotesController.dispose();
    super.dispose();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<void> _pickDocument() async {
    final docNameController = TextEditingController();

    final result = await showDialog<SelectedDocument?>(
      context: context,
      builder: (context) {
        String? selectedFilePath;
        String? selectedFileName;
        int? selectedFileSize;
        String? selectedMimeType;
        String? fileErrorMsg;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Dokumen Pendukung'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: docNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Dokumen *',
                        hintText: 'Misal: KTP / Akta Kelahiran',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final pickResult = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                        );

                        if (pickResult != null && pickResult.files.isNotEmpty) {
                          final file = pickResult.files.first;
                          final path = file.path;

                          if (path == null) {
                            setDialogState(() {
                              fileErrorMsg = 'Gagal mengakses file';
                            });
                            return;
                          }

                          const maxBytes = 5 * 1024 * 1024;
                          if (file.size > maxBytes) {
                            setDialogState(() {
                              fileErrorMsg =
                                  'Ukuran file melebihi batas maksimum (5 MB)';
                            });
                            return;
                          }

                          final ext = file.extension?.toLowerCase() ?? '';
                          if (!['pdf', 'jpg', 'jpeg', 'png'].contains(ext)) {
                            setDialogState(() {
                              fileErrorMsg =
                                  'Format file harus PDF, JPG, JPEG, atau PNG';
                            });
                            return;
                          }

                          setDialogState(() {
                            selectedFilePath = path;
                            selectedFileName = file.name;
                            selectedFileSize = file.size;
                            selectedMimeType =
                                ext == 'pdf' ? 'application/pdf' : 'image/$ext';
                            fileErrorMsg = null;
                          });
                        }
                      },
                      icon: const Icon(Icons.attach_file),
                      label: Text(
                        selectedFileName == null
                            ? 'Pilih File (PDF, JPG, PNG)'
                            : 'Ganti File',
                      ),
                    ),
                    if (selectedFileName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'File: $selectedFileName (${_formatFileSize(selectedFileSize ?? 0)})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (fileErrorMsg != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        fileErrorMsg!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final docName = docNameController.text.trim();
                    if (docName.isEmpty) {
                      setDialogState(() {
                        fileErrorMsg = 'Nama dokumen wajib diisi';
                      });
                      return;
                    }
                    if (selectedFilePath == null || selectedFileName == null) {
                      setDialogState(() {
                        fileErrorMsg = 'File belum dipilih';
                      });
                      return;
                    }

                    Navigator.pop(
                      context,
                      SelectedDocument(
                        documentName: docName,
                        filePath: selectedFilePath!,
                        fileName: selectedFileName!,
                        fileSize: selectedFileSize ?? 0,
                        mimeType:
                            selectedMimeType ?? 'application/octet-stream',
                      ),
                    );
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _documents.add(result);
      });
    }
  }

  void _submitApplication() {
    if (!_formKey.currentState!.validate()) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Pengajuan'),
          content: const Text(
            'Apakah Anda yakin ingin mengajukan permohonan ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _performSubmit();
              },
              child: const Text('Ya, Ajukan'),
            ),
          ],
        );
      },
    );
  }

  void _performSubmit() {
    ref.read(serviceFormSubmissionProvider.notifier).submit(
          serviceFormTypeId: widget.id,
          applicantNotes: _applicantNotesController.text.trim(),
          documents: _documents,
        );
  }

  @override
  Widget build(BuildContext context) {
    final typeAsync = ref.watch(serviceFormTypeDetailProvider(widget.id));
    final submissionState = ref.watch(serviceFormSubmissionProvider);

    ref.listen<FormSubmissionState>(serviceFormSubmissionProvider,
        (previous, next) {
      if (next.status == SubmissionStatus.success) {
        ref.invalidate(serviceFormApplicationsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permohonan pelayanan berhasil diajukan!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(serviceFormSubmissionProvider.notifier).reset();
        context.go(RoutePaths.myServiceApplications);
      } else if (next.status == SubmissionStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Gagal mengajukan permohonan.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final isSubmitting = submissionState.status == SubmissionStatus.submitting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Pengajuan'),
      ),
      body: typeAsync.when(
        data: (type) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ResponsiveLayout(
              maxWidth: AppBreakpoints.formMaxWidth,
              phone: Form(
                key: _formKey,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.assignment_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Jenis Pelayanan:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    type.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: 'Catatan Pemohon (Opsional)',
                        controller: _applicantNotesController,
                        maxLines: 4,
                        enabled: !isSubmitting,
                        hintText:
                            'Tuliskan keterangan atau pesan tambahan untuk majelis...',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Dokumen Pendukung',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppButton(
                            label: 'Tambah Dokumen',
                            icon: Icons.add_rounded,
                            variant: AppButtonVariant.outlined,
                            onPressed: isSubmitting ? null : _pickDocument,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (_documents.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.surfaceDark
                                    : Colors.grey.shade100,
                            borderRadius: AppRadius.borderSm,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            'Belum ada dokumen yang ditambahkan. Klik "Tambah Dokumen" untuk melampirkan berkas.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _documents.length,
                          itemBuilder: (context, index) {
                            final doc = _documents[index];
                            final isPdf = doc.fileName.endsWith('.pdf');
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(
                                  isPdf
                                      ? Icons.picture_as_pdf_rounded
                                      : Icons.image_rounded,
                                  color:
                                      isPdf ? AppColors.error : AppColors.info,
                                ),
                                title: Text(
                                  doc.documentName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${doc.fileName} (${_formatFileSize(doc.fileSize)})',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.error,
                                  ),
                                  onPressed: isSubmitting
                                      ? null
                                      : () {
                                          setState(() {
                                            _documents.removeAt(index);
                                          });
                                        },
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'Ajukan Permohonan',
                        fullWidth: true,
                        isLoading: isSubmitting,
                        onPressed: isSubmitting ? null : _submitApplication,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const AppLoadingView(message: 'Memuat data formulir...'),
        error: (error, stack) => AppErrorView(
          message: 'Gagal memuat formulir: $error',
          onRetry: () =>
              ref.invalidate(serviceFormTypeDetailProvider(widget.id)),
        ),
      ),
    );
  }
}

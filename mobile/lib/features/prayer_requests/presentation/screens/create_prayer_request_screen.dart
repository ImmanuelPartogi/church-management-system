import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../providers/prayer_request_provider.dart';

class CreatePrayerRequestScreen extends ConsumerStatefulWidget {
  const CreatePrayerRequestScreen({super.key});

  @override
  ConsumerState<CreatePrayerRequestScreen> createState() =>
      _CreatePrayerRequestScreenState();
}

class _CreatePrayerRequestScreenState
    extends ConsumerState<CreatePrayerRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'Kesehatan';
  bool _isPrivate = true;

  final List<String> _categories = const [
    'Kesehatan',
    'Keluarga',
    'Pekerjaan & Karir',
    'Pendidikan',
    'Ucapan Syukur',
    'Lain-lain',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Pokok Doa'),
          content: Text(
            'Apakah Anda yakin ingin mengirimkan permohonan doa "${_titleController.text.trim()}"?\n\n'
            '${_isPrivate ? "Sifat: Privat (Khusus Pendeta/Majelis)" : "Sifat: Publik (Tim Pendoa)"}',
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
              child: const Text('Ya, Kirim'),
            ),
          ],
        );
      },
    );
  }

  void _performSubmit() {
    ref.read(prayerSubmissionProvider.notifier).submit(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
          isPrivate: _isPrivate,
        );
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(prayerSubmissionProvider);
    final isSubmitting =
        submissionState.status == PrayerSubmissionStatus.submitting;

    ref.listen<PrayerSubmissionState>(prayerSubmissionProvider,
        (previous, next) {
      if (next.status == PrayerSubmissionStatus.success) {
        ref.invalidate(prayerRequestListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permohonan doa berhasil dikirimkan!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(prayerSubmissionProvider.notifier).reset();
        context.go(RoutePaths.prayerRequests);
      } else if (next.status == PrayerSubmissionStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorMessage ?? 'Gagal mengirimkan permohonan doa.',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Permohonan Doa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ResponsiveLayout(
          maxWidth: AppBreakpoints.formMaxWidth,
          phone: Form(
            key: _formKey,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  AppTextField(
                    label: 'Judul Pokok Doa *',
                    controller: _titleController,
                    enabled: !isSubmitting,
                    maxLength: 255,
                    hintText: 'Misal: Doa Kesembuhan untuk Orang Tua',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Judul pokok doa wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Category Selection
                  const Text(
                    'Kategori Pokok Doa',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: isSubmitting
                        ? null
                        : (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCategory = val;
                              });
                            }
                          },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Content Field
                  AppTextField(
                    label: 'Isi Permohonan Doa *',
                    controller: _contentController,
                    enabled: !isSubmitting,
                    maxLines: 5,
                    maxLength: 5000,
                    hintText:
                        'Tuliskan permohonan dan pergumulan doa Anda secara jelas...',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Isi permohonan doa wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Privacy Switch Box
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: (_isPrivate ? AppColors.accent : AppColors.info)
                          .withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(
                        color: (_isPrivate ? AppColors.accent : AppColors.info)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _isPrivate
                                      ? Icons.lock_rounded
                                      : Icons.public_rounded,
                                  color: _isPrivate
                                      ? AppColors.accent
                                      : AppColors.info,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  _isPrivate
                                      ? 'Sifat Rahasia (Privat)'
                                      : 'Sifat Publik',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: _isPrivate
                                        ? AppColors.accent
                                        : AppColors.info,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _isPrivate,
                              activeColor: AppColors.accent,
                              onChanged: isSubmitting
                                  ? null
                                  : (val) {
                                      setState(() {
                                        _isPrivate = val;
                                      });
                                    },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _isPrivate
                              ? 'Permohonan doa bersifat rahasia (Privat) dan hanya dapat dibaca oleh Pendeta & Majelis Gereja.'
                              : 'Permohonan doa bersifat Publik dan dapat dibaca oleh tim pendoa syafaat jemaat.',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                _isPrivate ? AppColors.accent : AppColors.info,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Submit Button
                  AppButton(
                    label: 'Kirim Permohonan Doa',
                    fullWidth: true,
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

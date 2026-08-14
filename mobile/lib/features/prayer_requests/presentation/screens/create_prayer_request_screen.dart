import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
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
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Permohonan Doa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              const Text(
                'Judul Pokok Doa *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                enabled: !isSubmitting,
                maxLength: 255,
                decoration: InputDecoration(
                  hintText: 'Misal: Doa Kesembuhan untuk Orang Tua',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul pokok doa wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selection
              const Text(
                'Kategori Pokok Doa',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
              const SizedBox(height: 16),

              // Content Field
              const Text(
                'Isi Permohonan Doa *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                enabled: !isSubmitting,
                maxLines: 5,
                maxLength: 5000,
                decoration: InputDecoration(
                  hintText:
                      'Tuliskan permohonan dan pergumulan doa Anda secara jelas...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Isi permohonan doa wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Privacy Switch & Explanation Box
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _isPrivate
                        ? Colors.purple.shade200
                        : Colors.teal.shade200,
                  ),
                ),
                color: _isPrivate ? Colors.purple.shade50 : Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isPrivate ? Icons.lock : Icons.public,
                                color: _isPrivate
                                    ? Colors.purple.shade800
                                    : Colors.teal.shade800,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isPrivate
                                    ? 'Sifat Rahasia (Privat)'
                                    : 'Sifat Publik',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: _isPrivate
                                      ? Colors.purple.shade900
                                      : Colors.teal.shade900,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isPrivate,
                            activeColor: Colors.purple.shade700,
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
                      const SizedBox(height: 8),
                      Text(
                        _isPrivate
                            ? 'Permohonan doa bersifat rahasia (Privat) dan hanya dapat dibaca oleh Pendeta & Majelis Gereja.'
                            : 'Permohonan doa bersifat Publik dan dapat dibaca oleh tim pendoa syafaat jemaat.',
                        style: TextStyle(
                          fontSize: 13,
                          color: _isPrivate
                              ? Colors.purple.shade900
                              : Colors.teal.shade900,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Kirim Permohonan Doa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

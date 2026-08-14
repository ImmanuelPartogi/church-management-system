import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/donation_provider.dart';

class DonationConfirmationScreen extends ConsumerStatefulWidget {
  const DonationConfirmationScreen({super.key});

  @override
  ConsumerState<DonationConfirmationScreen> createState() =>
      _DonationConfirmationScreenState();
}

class _DonationConfirmationScreenState
    extends ConsumerState<DonationConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();

  int _selectedCategoryId = 1; // Default to Persembahan Minggu (ID: 1)
  final _amountController = TextEditingController();
  final _transferDateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final _senderBankController = TextEditingController();
  final _depositorPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedProofPath;
  String? _selectedProofName;
  int? _selectedProofSize;
  String? _proofErrorMsg;

  final List<Map<String, dynamic>> _categories = const [
    {'id': 1, 'name': 'Persembahan Minggu (4000)'},
    {'id': 2, 'name': 'Persepuluhan (4100)'},
    {'id': 3, 'name': 'Pembangunan (4200)'},
    {'id': 4, 'name': 'Diakonia / Sosial (4300)'},
    {'id': 5, 'name': 'Ucapan Syukur (4400)'},
    {'id': 6, 'name': 'Donasi Khusus (4500)'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _transferDateController.dispose();
    _senderBankController.dispose();
    _depositorPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _formatAmountPreview(String text) {
    if (text.isEmpty) return '';
    final numValue = num.tryParse(text);
    if (numValue == null || numValue <= 0) return '';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(numValue);
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: now, // Future dates blocked
    );
    if (picked != null) {
      setState(() {
        _transferDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickProofFile() async {
    final pickResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (pickResult != null && pickResult.files.isNotEmpty) {
      final file = pickResult.files.first;
      final path = file.path;

      if (path == null) {
        setState(() {
          _proofErrorMsg = 'Gagal mengakses file';
        });
        return;
      }

      const maxBytes = 5 * 1024 * 1024; // 5MB
      if (file.size > maxBytes) {
        setState(() {
          _proofErrorMsg = 'Ukuran file melebihi 5 MB';
        });
        return;
      }

      final ext = file.extension?.toLowerCase() ?? '';
      if (!['jpg', 'jpeg', 'png', 'pdf'].contains(ext)) {
        setState(() {
          _proofErrorMsg = 'Format file harus JPG, JPEG, PNG, atau PDF';
        });
        return;
      }

      setState(() {
        _selectedProofPath = path;
        _selectedProofName = file.name;
        _selectedProofSize = file.size;
        _proofErrorMsg = null;
      });
    }
  }

  void _submitConfirmation() {
    if (!_formKey.currentState!.validate()) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Persembahan'),
          content: Text(
            'Apakah Anda yakin data konfirmasi persembahan sebesar ${_formatAmountPreview(_amountController.text)} sudah benar?',
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
    final amountNum = num.parse(_amountController.text.trim());
    ref.read(donationSubmissionProvider.notifier).submit(
          chartOfAccountId: _selectedCategoryId,
          amount: amountNum,
          transferDate: _transferDateController.text.trim(),
          senderBank: _senderBankController.text.trim(),
          depositorPhone: _depositorPhoneController.text.trim(),
          notes: _notesController.text.trim(),
          proofFilePath: _selectedProofPath,
        );
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(donationSubmissionProvider);
    final isSubmitting = submissionState.status == SubmissionStatus.submitting;

    ref.listen<DonationSubmissionState>(donationSubmissionProvider,
        (previous, next) {
      if (next.status == SubmissionStatus.success) {
        ref.invalidate(donationHistoryProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konfirmasi persembahan berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(donationSubmissionProvider.notifier).reset();
        context.go(RoutePaths.myDonations);
      } else if (next.status == SubmissionStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Gagal mengirimkan konfirmasi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Transfer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Selection
              const Text(
                'Kategori Persembahan *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat['id'] as int,
                    child: Text(cat['name'] as String),
                  );
                }).toList(),
                onChanged: isSubmitting
                    ? null
                    : (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategoryId = val;
                          });
                        }
                      },
              ),
              const SizedBox(height: 16),

              // Amount Field
              const Text(
                'Jumlah Persembahan (Rp) *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !isSubmitting,
                onChanged: (val) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Misal: 100000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  helperText: _formatAmountPreview(_amountController.text),
                  helperStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Jumlah persembahan wajib diisi';
                  }
                  final amount = num.tryParse(val);
                  if (amount == null || amount <= 0) {
                    return 'Jumlah persembahan harus lebih besar dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Transfer Date Field
              const Text(
                'Tanggal Transfer *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _transferDateController,
                readOnly: true,
                onTap: isSubmitting ? null : _selectDate,
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  suffixIcon: const Icon(Icons.calendar_month),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Tanggal transfer wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sender Bank Field
              const Text(
                'Bank Pengirim / Asal Transfer *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _senderBankController,
                enabled: !isSubmitting,
                decoration: InputDecoration(
                  hintText: 'Misal: BCA / Mandiri / QRIS / BRI',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Bank pengirim wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Depositor Phone (Optional)
              const Text(
                'No. WhatsApp / HP Pengirim (Opsional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _depositorPhoneController,
                keyboardType: TextInputType.phone,
                enabled: !isSubmitting,
                decoration: InputDecoration(
                  hintText: 'Misal: 081234567890',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes (Optional)
              const Text(
                'Catatan (Opsional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                enabled: !isSubmitting,
                decoration: InputDecoration(
                  hintText: 'Misal: Untuk ucapan syukur ulang tahun...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Proof File Section
              const Text(
                'Bukti Transfer (Opsional, PDF/JPG/PNG max 5MB)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (_selectedProofName == null)
                OutlinedButton.icon(
                  onPressed: isSubmitting ? null : _pickProofFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Pilih Bukti Transfer'),
                )
              else
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                    ),
                    title: Text(_selectedProofName!),
                    subtitle: Text(_formatFileSize(_selectedProofSize ?? 0)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _selectedProofPath = null;
                                _selectedProofName = null;
                                _selectedProofSize = null;
                              });
                            },
                    ),
                  ),
                ),
              if (_proofErrorMsg != null) ...[
                const SizedBox(height: 4),
                Text(
                  _proofErrorMsg!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 24),

              // Upload progress indicator
              if (isSubmitting) ...[
                LinearProgressIndicator(
                  value: submissionState.uploadProgress > 0
                      ? submissionState.uploadProgress
                      : null,
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Mengunggah... ${(submissionState.uploadProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitConfirmation,
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
                          'Kirim Konfirmasi Persembahan',
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

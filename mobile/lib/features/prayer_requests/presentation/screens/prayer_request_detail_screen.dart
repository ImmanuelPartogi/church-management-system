import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/prayer_request_provider.dart';

class PrayerRequestDetailScreen extends ConsumerWidget {
  final int id;

  const PrayerRequestDetailScreen({
    super.key,
    required this.id,
  });

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    final lower = status.toLowerCase();
    if (lower == 'submitted') {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade800;
      label = 'Menunggu Didoakan';
    } else if (lower == 'prayed') {
      bg = Colors.blue.shade50;
      fg = Colors.blue.shade800;
      label = 'Sudah Didoakan';
    } else if (lower == 'followed_up') {
      bg = Colors.green.shade50;
      fg = Colors.green.shade800;
      label = 'Sudah Ditindaklanjuti';
    } else {
      bg = Colors.grey.shade100;
      fg = Colors.grey.shade800;
      label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildPrivacyBadge(bool isPrivate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPrivate ? Colors.purple.shade50 : Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPrivate ? Icons.lock_outline : Icons.public_outlined,
            size: 14,
            color: isPrivate ? Colors.purple.shade800 : Colors.teal.shade800,
          ),
          const SizedBox(width: 4),
          Text(
            isPrivate ? 'Privat' : 'Publik',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPrivate ? Colors.purple.shade800 : Colors.teal.shade800,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy HH:mm', 'id_ID').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(prayerRequestDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Permohonan Doa'),
      ),
      body: detailAsync.when(
        data: (item) {
          final hasFollowUp = item.followUpNotes != null &&
              item.followUpNotes!.trim().isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPrivacyBadge(item.isPrivate),
                            _buildStatusBadge(item.status),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.category != null &&
                            item.category!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Kategori: ${item.category}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Dikirim: ${_formatDate(item.createdAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Content Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Isi Permohonan Doa',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          item.content,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Pastoral Care Follow-up Card
                if (hasFollowUp ||
                    item.status.toLowerCase() == 'followed_up' ||
                    item.status.toLowerCase() == 'prayed') ...[
                  Card(
                    elevation: 2,
                    color: Colors.green.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.green.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.green.shade100,
                                child: Icon(
                                  Icons.volunteer_activism,
                                  color: Colors.green.shade800,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tanggapan / Tindak Lanjut Pastoral',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: Colors.green),
                          const SizedBox(height: 8),
                          Text(
                            hasFollowUp
                                ? item.followUpNotes!
                                : 'Permohonan doa Anda telah didoakan oleh Tim Pastoral Gereja.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade900,
                              height: 1.4,
                            ),
                          ),
                          if (item.followedUpAt != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 14,
                                  color: Colors.green.shade800,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Ditindaklanjuti pada: ${_formatDate(item.followedUpAt)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green.shade800,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
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
                  'Gagal memuat detail permohonan doa: ${error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(prayerRequestDetailProvider(id)),
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

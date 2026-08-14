import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/prayer_request_provider.dart';

class PrayerRequestsScreen extends ConsumerWidget {
  const PrayerRequestsScreen({super.key});

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildPrivacyBadge(bool isPrivate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPrivate ? Colors.purple.shade50 : Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPrivate ? Icons.lock_outline : Icons.public_outlined,
            size: 12,
            color: isPrivate ? Colors.purple.shade800 : Colors.teal.shade800,
          ),
          const SizedBox(width: 4),
          Text(
            isPrivate ? 'Privat' : 'Publik',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPrivate ? Colors.purple.shade800 : Colors.teal.shade800,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy', 'id_ID').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(prayerRequestListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permohonan Doa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Buat Permohonan Doa',
            onPressed: () {
              context.push(RoutePaths.createPrayerRequest);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(RoutePaths.createPrayerRequest);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Buat Pokok Doa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(prayerRequestListProvider);
        },
        child: listAsync.when(
          data: (requests) {
            if (requests.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volunteer_activism_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum Ada Permohonan Doa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sampaikan permohonan doa Anda agar dapat didoakan oleh Tim Pastoral Gereja.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.push(RoutePaths.createPrayerRequest);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Ajukan Pokok Doa Baru'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final item = requests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      context.pushNamed(
                        RouteNames.prayerRequestDetail,
                        pathParameters: {'id': item.id.toString()},
                      );
                    },
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
                          const SizedBox(height: 10),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item.category != null &&
                              item.category!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Kategori: ${item.category}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            item.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(item.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (item.followUpNotes != null &&
                                  item.followUpNotes!.isNotEmpty)
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.comment,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Ada Tanggapan',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
                    'Gagal memuat permohonan doa: ${error.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(prayerRequestListProvider),
                    child: const Text('Coba Lagi'),
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

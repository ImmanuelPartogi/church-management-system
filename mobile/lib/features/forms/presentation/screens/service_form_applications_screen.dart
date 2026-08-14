import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/service_forms_provider.dart';

class ServiceFormApplicationsScreen extends ConsumerWidget {
  const ServiceFormApplicationsScreen({super.key});

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    final lower = status.toLowerCase();
    if (lower == 'pending') {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade800;
      label = 'Pending';
    } else if (lower == 'approved') {
      bg = Colors.green.shade50;
      fg = Colors.green.shade800;
      label = 'Disetujui';
    } else if (lower == 'rejected') {
      bg = Colors.red.shade50;
      fg = Colors.red.shade800;
      label = 'Ditolak';
    } else if (lower == 'completed') {
      bg = Colors.blue.shade50;
      fg = Colors.blue.shade800;
      label = 'Selesai';
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

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(serviceFormApplicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pengajuan'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(serviceFormApplicationsProvider);
        },
        child: applicationsAsync.when(
          data: (applications) {
            if (applications.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada riwayat permohonan pelayanan',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final app = applications[index];
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
                        RouteNames.myServiceApplicationDetail,
                        pathParameters: {'id': app.id.toString()},
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
                              Text(
                                app.applicationNumber,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              _buildStatusBadge(app.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            app.serviceFormType?.name ?? 'Permohonan Pelayanan',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(app.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const Spacer(),
                              if (app.documents.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.attach_file,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${app.documents.length} berkas',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
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
                    'Gagal memuat riwayat: ${error.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.invalidate(serviceFormApplicationsProvider),
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

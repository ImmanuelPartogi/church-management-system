import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../domain/entities/user_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final updateState = ref.watch(profileUpdateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: profileAsync.when(
        data: (profile) => RefreshIndicator(
          onRefresh: () async => ref.refresh(userProfileProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. User Header Card
                _buildUserHeader(context, profile),
                const SizedBox(height: 16),

                // 2. Account Information Section
                _buildSectionCard(
                  context,
                  title: 'Informasi Akun',
                  icon: Icons.person_outline,
                  child: Column(
                    children: [
                      _buildInfoRow('Nama Lengkap', profile.name),
                      const Divider(),
                      _buildInfoRow('Email', profile.email),
                      const Divider(),
                      _buildInfoRow('No. Telepon', profile.phone ?? '-'),
                      const Divider(),
                      _buildInfoRow('Alamat', profile.address ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Linked Church Member Section (if linked)
                if (profile.hasLinkedMember) ...[
                  _buildSectionCard(
                    context,
                    title: 'Data Jemaat Terhubung',
                    icon: Icons.badge_outlined,
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'No. Anggota',
                          profile.member!.membershipNumber ?? '-',
                        ),
                        const Divider(),
                        _buildInfoRow('Nama Jemaat', profile.member!.fullName),
                        const Divider(),
                        _buildInfoRow('Jenis Kelamin', profile.member!.gender ?? '-'),
                        const Divider(),
                        _buildInfoRow('Status', profile.member!.status ?? '-'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. Action Buttons (Edit Profile, Logout, Hapus Akun)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showEditProfileDialog(context, ref, profile),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Profil'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 5. Privacy / UU PDP Information Card
                Card(
                  color: Colors.blue.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blue.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.privacy_tip_outlined,
                            color:, Colors.blue.shade700,),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sesuai UU PDP No. 27/2022, Anda memiliki hak penuh atas pengelolaan dan penghapusan data akun pribadi Anda.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 6. Logout & Delete Account Actions
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.amber),
                  title: const Text('Keluar / Logout'),
                  onTap: () => ref.read(authNotifierProvider.notifier).logout(),
                ),
                ListTile(
                  leading: updateState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Hapus Akun Saya',
                    style: TextStyle(
                        color: Colors.red, fontWe,ight: FontWeight.bold,),
                  ),
                  subtitle: const Text(
                    'Penghapusan akun permanen sesuai regulasi data pribadi UU PDP.',
                    style: TextStyle(fontSize: 11),
                  ),
                  onTap: updateState.isLoading
                      ? null
                      : () => _showAccountDeletionDialog(context, ref),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('Gagal memuat profil: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(userProfileProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, UserProfile profile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      Chip(
                        label: Text(
                          profile.roles.isNotEmpty
                              ? profile.roles.first
                              : 'User',
                          style: const TextStyle(fontSize: 10),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (profile.hasLinkedMember)
                        const Chip(
                          avatar: Icon(Icons.check_circle,
                              size: 14,, color: Colors.green,),
                          label: Text(
                            'Jemaat Terverifikasi',
                            style: TextStyle(fontSize: 10, color: Colors.green),
                          ),
                          backgroundColor: Color(0xFFE8F5E9),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeig,ht.bold, fontSize: 16,),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) {
    final nameController = TextEditingController(text: profile.name);
    final phoneController = TextEditingController(text: profile.phone ?? '');
    final addressController =
        TextEditingController(text: profile.address ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'No. Telepon'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(profileUpdateNotifierProvider.notifier)
                  .updateProfile(
                    name: nameController.text,
                    phone: phoneController.text,
                    address: addressController.text,
                  );

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil berhasil diperbarui')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal memperbarui profil')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAccountDeletionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus Akun'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus akun Anda? Tindakan ini permanen sesuai regulasi perlindungan data pribadi (UU PDP). Token akses dan preferensi akun Anda akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await ref
                  .read(profileUpdateNotifierProvider.notifier)
                  .deleteAccount();

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Akun Anda telah dihapus.')),
                  );
                  ref.read(authNotifierProvider.notifier).forceLogout();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal menghapus akun.')),
                  );
                }
              }
            },
            child:
                const Text('Hapus Akun', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

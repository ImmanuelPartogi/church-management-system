import 'package:dio/dio.dart';
import 'package:church_management_mobile/core/error/exceptions.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile({
    required String name,
    String? phone,
    String? address,
  });
  Future<void> deleteAccount();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl(this.dio);

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/profile');
      if (response.data != null) {
        return UserProfileModel.fromJson(response.data!);
      } else {
        throw const ServerException('Gagal memuat profil pengguna');
      }
    } on DioException catch (e) {
      throw ServerException(
        (e.response?.data['message'] as String?) ?? 'Gagal memuat profil',
      );
    }
  }

  @override
  Future<UserProfileModel> updateProfile({
    required String name,
    String? phone,
    String? address,
  }) async {
    try {
      final response = await dio.put<Map<String, dynamic>>(
        '/profile',
        data: {
          'name': name.trim(),
          'phone': phone?.trim(),
          'address': address?.trim(),
        },
      );
      if (response.data != null) {
        return UserProfileModel.fromJson(response.data!);
      } else {
        throw const ServerException('Gagal memperbarui profil');
      }
    } on DioException catch (e) {
      throw ServerException(
        (e.response?.data['message'] as String?) ?? 'Gagal memperbarui profil',
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await dio.delete<Map<String, dynamic>>('/profile');
    } on DioException catch (e) {
      throw ServerException(
        (e.response?.data['message'] as String?) ?? 'Gagal menghapus akun',
      );
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthRemoteDataSource(dio);
});

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> loginWithFirebaseToken(
      String firebaseIdToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.authFirebaseEndpoint,
      data: {
        'firebase_id_token': firebaseIdToken,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<UserModel> getCurrentUser() async {
    final response =
        await _dio.get<Map<String, dynamic>>(ApiConstants.authMeEndpoint);
    final json = response.data as Map<String, dynamic>;
    return UserModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _dio.post<dynamic>(ApiConstants.authLogoutEndpoint);
  }
}

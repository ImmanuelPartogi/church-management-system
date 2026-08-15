import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:church_management_mobile/core/network/dio_client.dart';
import '../../data/datasource/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ProfileRemoteDataSourceImpl(dio);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource);
});

final userProfileProvider =
    FutureProvider.autoDispose<UserProfile>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.getProfile();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (profile) => profile,
  );
});

final profileUpdateNotifierProvider =
    StateNotifierProvider.autoDispose<ProfileUpdateNotifier, AsyncValue<void>>(
        (ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileUpdateNotifier(repository, ref);
});

class ProfileUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileUpdateNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  Future<bool> updateProfile({
    required String name,
    String? phone,
    String? address,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.updateProfile(
      name: name,
      phone: phone,
      address: address,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (updatedProfile) {
        state = const AsyncValue.data(null);
        _ref.invalidate(userProfileProvider);
        return true;
      },
    );
  }

  Future<bool> deleteAccount() async {
    state = const AsyncValue.loading();
    final result = await _repository.deleteAccount();

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }
}

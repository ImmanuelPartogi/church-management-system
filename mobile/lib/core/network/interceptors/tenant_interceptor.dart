import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/church/presentation/providers/tenant_provider.dart';

class TenantInterceptor extends Interceptor {
  final Ref? _ref;
  final ProviderContainer? _container;
  final Dio _dio;

  TenantInterceptor(Ref ref, this._dio)
      : _ref = ref,
        _container = null;

  TenantInterceptor.withContainer(ProviderContainer container, this._dio)
      : _ref = null,
        _container = container;

  T _read<T>(ProviderListenable<T> provider) {
    if (_ref != null) return _ref.read(provider);
    return _container!.read(provider);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final activeChurch = _read(activeChurchProvider);
    if (activeChurch != null) {
      options.headers['X-Church-Id'] = activeChurch.id.toString();
      options.headers['X-Church-Slug'] = activeChurch.slug;
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isTenantMismatch = err.response?.statusCode == 403 &&
        err.response?.data is Map &&
        (err.response!.data as Map)['code'] == 'TENANT_MEMBERSHIP_MISMATCH';

    final isRetryAttempted =
        err.requestOptions.extra['tenant_retry_attempted'] == true;

    // If not a tenant mismatch or already retried once (maxRetries = 1), pass error forward
    if (!isTenantMismatch || isRetryAttempted) {
      return handler.next(err);
    }

    // Mark single retry attempted
    err.requestOptions.extra['tenant_retry_attempted'] = true;

    // Check authenticated user
    final authState = _read(authNotifierProvider);
    final user = authState.maybeWhen(
      authenticated: (u) => u,
      orElse: () => null,
    );

    if (user != null) {
      try {
        // UNIFIED RECONCILIATION: update TenantNotifier state and storage in lockstep
        final reconciledChurch =
            await _read(tenantProvider.notifier).reconcileWithUser(user);

        if (reconciledChurch != null) {
          err.requestOptions.headers['X-Church-Id'] =
              reconciledChurch.id.toString();
          err.requestOptions.headers['X-Church-Slug'] = reconciledChurch.slug;

          final response = await _dio.fetch<dynamic>(err.requestOptions);
          return handler.resolve(response);
        }
      } catch (_) {
        // If retry fails, pass original/latest error forward
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}

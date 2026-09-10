import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:church_management_mobile/core/network/interceptors/tenant_interceptor.dart';
import 'package:church_management_mobile/core/storage/secure_storage_service.dart';
import 'package:church_management_mobile/features/auth/domain/entities/user.dart';
import 'package:church_management_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:church_management_mobile/features/church/data/repositories/church_repository_impl.dart';
import 'package:church_management_mobile/features/church/domain/entities/church.dart';
import 'package:church_management_mobile/features/church/presentation/providers/tenant_provider.dart';
import '../tenant/tenant_login_reconciliation_test.dart';

void main() {
  group('TenantInterceptor Unit Tests', () {
    late FakeSecureStorageService fakeStorage;
    late FakeChurchRepository fakeRepo;
    late ProviderContainer container;

    const churchA = Church(id: 1, uuid: 'uuid-a', name: 'Gereja A', slug: 'gereja-a');
    const churchB = Church(id: 2, uuid: 'uuid-b', name: 'Gereja B', slug: 'gereja-b');

    setUp(() {
      fakeStorage = FakeSecureStorageService();
      fakeRepo = FakeChurchRepository([churchA, churchB]);

      container = ProviderContainer(
        overrides: [
          churchRepositoryProvider.overrideWithValue(fakeRepo),
          secureStorageServiceProvider.overrideWithValue(fakeStorage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('onRequest injects X-Church-Id and X-Church-Slug when active church exists', () async {
      // Set active church to Church A
      await container.read(tenantProvider.notifier).selectChurch(churchA);

      final dio = Dio();
      final interceptor = TenantInterceptor.withContainer(container, dio);

      final options = RequestOptions(path: '/announcements');
      final handler = RequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(options.headers['X-Church-Id'], '1');
      expect(options.headers['X-Church-Slug'], 'gereja-a');
    });

    test('onError calls reconcileWithUser and retries request on TENANT_MEMBERSHIP_MISMATCH', () async {
      // Initially, local tenant is Church B (e.g. from guest browsing)
      await container.read(tenantProvider.notifier).selectChurch(churchB);
      expect(container.read(activeChurchProvider)?.slug, 'gereja-b');

      // User is authenticated as member of Church A
      const user = User(
        id: 10,
        name: 'User A',
        email: 'usera@example.com',
        roles: ['member'],
        memberships: [
          UserChurchMembership(
            churchId: 1,
            churchUuid: 'uuid-a',
            churchName: 'Gereja A',
            churchSlug: 'gereja-a',
            role: 'member',
          ),
        ],
      );

      // Create a mock adapter to simulate 200 on retry
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter();

      // Override auth state with user
      final customContainer = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockAuthNotifier(user)),
          churchRepositoryProvider.overrideWithValue(fakeRepo),
          secureStorageServiceProvider.overrideWithValue(fakeStorage),
        ],
      );

      // Set Church B initially in custom container
      await customContainer.read(tenantProvider.notifier).selectChurch(churchB);

      final interceptor = TenantInterceptor.withContainer(customContainer, dio);

      final requestOptions = RequestOptions(
        path: '/announcements',
        headers: {
          'X-Church-Id': '2',
          'X-Church-Slug': 'gereja-b',
        },
      );

      final dioException = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 403,
          data: {
            'message': 'Tenant mismatch',
            'code': 'TENANT_MEMBERSHIP_MISMATCH',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      var handlerResolved = false;
      final handler = _TestErrorInterceptorHandler(
        onResolve: (res) {
          handlerResolved = true;
        },
      );

      // Trigger interceptor onError
      expect(requestOptions.extra['tenant_retry_attempted'], isNull);

      await interceptor.onError(dioException, handler);

      // Verify single retry flag was set
      expect(requestOptions.extra['tenant_retry_attempted'], isTrue);

      // Verify retry was resolved successfully
      expect(handlerResolved, isTrue);

      // CRITICAL VERIFICATION: TenantNotifier state was reconciled to Church A!
      expect(customContainer.read(activeChurchProvider)?.slug, 'gereja-a');
      expect(customContainer.read(activeChurchProvider)?.id, 1);

      // Headers for retry request were updated to Church A
      expect(requestOptions.headers['X-Church-Id'], '1');
      expect(requestOptions.headers['X-Church-Slug'], 'gereja-a');

      customContainer.dispose();
    });

    test('Single-retry guard prevents infinite loop if tenant_retry_attempted is already true', () async {
      final dio = Dio();
      final interceptor = TenantInterceptor.withContainer(container, dio);

      final requestOptions = RequestOptions(
        path: '/announcements',
        extra: {'tenant_retry_attempted': true}, // already retried once!
      );

      final dioException = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 403,
          data: {
            'code': 'TENANT_MEMBERSHIP_MISMATCH',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      var nextCalled = false;
      final handler = _TestErrorInterceptorHandler(
        onNext: (e) {
          nextCalled = true;
        },
      );

      await interceptor.onError(dioException, handler);

      // Must directly forward error and NOT attempt another retry
      expect(nextCalled, isTrue);
    });
  });
}

class _MockAuthNotifier extends AuthNotifier {
  final User _user;
  _MockAuthNotifier(this._user);

  @override
  AuthState build() => AuthState.authenticated(_user);
}

class _MockHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<dynamic>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"success": true}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _TestErrorInterceptorHandler extends ErrorInterceptorHandler {
  final void Function(DioException)? onNext;
  final void Function(Response)? onResolve;
  _TestErrorInterceptorHandler({this.onNext, this.onResolve});

  @override
  void next(DioException err) {
    onNext?.call(err);
  }

  @override
  void resolve(Response response) {
    onResolve?.call(response);
  }
}

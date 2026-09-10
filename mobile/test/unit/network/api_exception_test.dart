import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:church_management_mobile/core/network/api_exception.dart';

void main() {
  group('ApiException Contract Parsing Tests', () {
    test('parses MODULE_DISABLED correctly from 403 response', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/finances/transparency'),
        response: Response(
          requestOptions: RequestOptions(path: '/finances/transparency'),
          statusCode: 403,
          data: {
            'message': 'Modul finances saat ini dinonaktifkan oleh administrator gereja.',
            'code': 'MODULE_DISABLED',
            'module': 'finances',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = ApiException.fromDioException(dioException);

      expect(exception.statusCode, 403);
      expect(exception.errorCode, 'MODULE_DISABLED');
      expect(exception.module, 'finances');
      expect(exception.isModuleDisabled, isTrue);
      expect(exception.isTenantMismatch, isFalse);
      expect(exception.isNoActiveMembership, isFalse);
      expect(exception.message, contains('dinonaktifkan'));
    });

    test('parses TENANT_MEMBERSHIP_MISMATCH correctly from 403 response', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/announcements'),
        response: Response(
          requestOptions: RequestOptions(path: '/announcements'),
          statusCode: 403,
          data: {
            'message': 'Anda bukan anggota aktif dari gereja ini.',
            'code': 'TENANT_MEMBERSHIP_MISMATCH',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = ApiException.fromDioException(dioException);

      expect(exception.statusCode, 403);
      expect(exception.errorCode, 'TENANT_MEMBERSHIP_MISMATCH');
      expect(exception.isTenantMismatch, isTrue);
      expect(exception.isModuleDisabled, isFalse);
      expect(exception.isNoActiveMembership, isFalse);
    });

    test('parses NO_ACTIVE_MEMBERSHIP correctly from 403 response', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/members'),
        response: Response(
          requestOptions: RequestOptions(path: '/members'),
          statusCode: 403,
          data: {
            'message': 'Akun Anda belum terdaftar sebagai anggota aktif di gereja manapun.',
            'code': 'NO_ACTIVE_MEMBERSHIP',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = ApiException.fromDioException(dioException);

      expect(exception.statusCode, 403);
      expect(exception.errorCode, 'NO_ACTIVE_MEMBERSHIP');
      expect(exception.isNoActiveMembership, isTrue);
      expect(exception.isTenantMismatch, isFalse);
      expect(exception.isModuleDisabled, isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:church_management_mobile/app/router/route_names.dart';
import 'package:church_management_mobile/features/notifications/data/services/notification_service.dart';

@GenerateNiceMocks([MockSpec<GoRouter>()])
import 'notification_service_test.mocks.dart';

void main() {
  late NotificationService notificationService;
  late MockGoRouter mockRouter;

  setUp(() {
    notificationService = NotificationService();
    mockRouter = MockGoRouter();
  });

  group('NotificationService Deep Link Handler Tests', () {
    test('navigates to whitelisted route using router.push', () {
      notificationService.handleNotificationNavigation(
        mockRouter,
        '/announcements',
      );
      verify(mockRouter.push('/announcements')).called(1);
    });

    test('navigates to whitelisted parameterized route using router.push', () {
      notificationService.handleNotificationNavigation(
        mockRouter,
        '/wartas/123',
      );
      verify(mockRouter.push('/wartas/123')).called(1);
    });

    test('falls back to home route when route is not whitelisted', () {
      notificationService.handleNotificationNavigation(
        mockRouter,
        '/malicious-route',
      );
      verify(mockRouter.go(RoutePaths.home)).called(1);
      verifyNever(mockRouter.push(argThat(anything)));
    });

    test('ignores navigation when rawRoute is null or empty', () {
      notificationService.handleNotificationNavigation(mockRouter, null);
      notificationService.handleNotificationNavigation(mockRouter, '   ');
      verifyNever(mockRouter.push(argThat(anything)));
      verifyNever(mockRouter.go(argThat(anything)));
    });

    test('handleNotificationData triggers onSwitchChurch when church_id is present', () {
      int? switchedChurchId;

      notificationService.handleNotificationData(
        mockRouter,
        {
          'church_id': '42',
          'route': '/announcements',
        },
        onSwitchChurch: (churchId) {
          switchedChurchId = churchId;
        },
      );

      expect(switchedChurchId, equals(42));
      verify(mockRouter.push('/announcements')).called(1);
    });

    test('handleNotificationData routes without onSwitchChurch when church_id is missing', () {
      notificationService.handleNotificationData(
        mockRouter,
        {
          'route': '/wartas/55',
        },
      );

      verify(mockRouter.push('/wartas/55')).called(1);
    });
  });
}

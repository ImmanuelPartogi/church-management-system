import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/constants/api_constants.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('FCM Background message received: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _messaging;

  NotificationService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  static const List<String> routeWhitelist = [
    RoutePaths.home,
    RoutePaths.announcements,
    RoutePaths.schedules,
    RoutePaths.schedulesCalendar,
    RoutePaths.wartas,
    RoutePaths.serviceForms,
    RoutePaths.myServiceApplications,
    RoutePaths.churchBankAccounts,
    RoutePaths.donationConfirm,
    RoutePaths.myDonations,
    RoutePaths.prayerRequests,
    RoutePaths.hymns,
    RoutePaths.finance,
    RoutePaths.members,
    RoutePaths.servants,
    RoutePaths.sermons,
  ];

  Future<void> initialize({
    GoRouter? router,
    Dio? dioClient,
  }) async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await _messaging.getToken();
        if (token != null && dioClient != null) {
          await syncTokenWithBackend(dioClient, token);
        }

        _messaging.onTokenRefresh.listen((newToken) {
          if (dioClient != null) {
            syncTokenWithBackend(dioClient, newToken);
          }
        });
      }

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          'FCM Foreground message received: ${message.notification?.title}',
        );
      });

      // App opened from notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (router != null) {
          handleNotificationData(router, message.data);
        }
      });

      // App launched from terminated state via notification tap
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null && router != null) {
        handleNotificationData(router, initialMessage.data);
      }
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  Future<bool> syncTokenWithBackend(Dio dioClient, String token) async {
    try {
      final response = await dioClient.post<Map<String, dynamic>>(
        ApiConstants.deviceTokenEndpoint,
        data: {
          'token': token,
          'platform':
              defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Sync device token failed: $e');
      return false;
    }
  }

  void handleNotificationData(GoRouter router, Map<String, dynamic> data) {
    final rawRoute = data['route'] as String?;
    handleNotificationNavigation(router, rawRoute);
  }

  void handleNotificationNavigation(GoRouter router, String? rawRoute) {
    if (rawRoute == null || rawRoute.trim().isEmpty) {
      return;
    }

    final cleanRoute = rawRoute.trim();
    final isWhitelisted = routeWhitelist.any((path) {
      if (cleanRoute == path) return true;
      final prefix = path.split('/:').first;
      return cleanRoute == prefix || cleanRoute.startsWith('$prefix/');
    });

    if (isWhitelisted) {
      router.push(cleanRoute);
    } else {
      debugPrint('Ignored unwhitelisted notification route: $cleanRoute');
      router.go(RoutePaths.home);
    }
  }
}

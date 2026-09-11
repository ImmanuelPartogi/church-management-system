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
  final FirebaseMessaging? _customMessaging;

  NotificationService({FirebaseMessaging? messaging})
      : _customMessaging = messaging;

  FirebaseMessaging get _messaging =>
      _customMessaging ?? FirebaseMessaging.instance;

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

  Future<bool> syncTokenWithBackend(
    Dio dioClient,
    String token, {
    int? churchId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'token': token,
        'platform':
            defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
      };
      if (churchId != null) {
        payload['church_id'] = churchId;
      }
      final response = await dioClient.post<Map<String, dynamic>>(
        ApiConstants.deviceTokenEndpoint,
        data: payload,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Sync device token failed: $e');
      return false;
    }
  }

  Future<bool> deleteTokenFromBackend(
    Dio dioClient,
    String token, {
    int? churchId,
  }) async {
    try {
      final payload = <String, dynamic>{'token': token};
      if (churchId != null) {
        payload['church_id'] = churchId;
      }
      final response = await dioClient.delete<Map<String, dynamic>>(
        ApiConstants.deviceTokenEndpoint,
        data: payload,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Delete device token failed: $e');
      return false;
    }
  }

  void handleNotificationData(
    GoRouter router,
    Map<String, dynamic> data, {
    void Function(int churchId)? onSwitchChurch,
  }) {
    final rawChurchId = data['church_id'];
    if (rawChurchId != null && onSwitchChurch != null) {
      final parsedChurchId = int.tryParse(rawChurchId.toString());
      if (parsedChurchId != null) {
        onSwitchChurch(parsedChurchId);
      }
    }

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

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/home/presentation/controllers/home_controller.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationService {
  PushNotificationService(this._apiClient);

  final ApiClient _apiClient;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  RemoteMessage? _initialMessageToHandle;
  
  bool get hasInitialMessage => _initialMessageToHandle != null;

  void handleInitialMessage() {
    if (_initialMessageToHandle != null) {
      _handleMessageTap(_initialMessageToHandle!);
      _initialMessageToHandle = null;
    }
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInitSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', 
        'High Importance Notifications', 
        description: 'This channel is used for important notifications.', 
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message, channel);
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchUnreadNotificationCount();
        }
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessageTap(message);
      });
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _initialMessageToHandle = initialMessage;
      }

      _isInitialized = true;
    } catch (_) {}
  }

  void _showLocalNotification(RemoteMessage message, AndroidNotificationChannel channel) {
    final notification = message.notification;

    if (notification != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        final message = RemoteMessage(data: data);
        _handleMessageTap(message);
      } catch (_) {}
    }
  }

  void _handleMessageTap(RemoteMessage message) async {
    final pageText = (message.data['pageText'] ?? '').toString().trim().toLowerCase();
    final String memberNotificationId = message.data['memberNotificationId'].toString();
    if(memberNotificationId.isNotEmpty) {
      await _apiClient.post(
        ApiEndpoints.markNotificationRead(int.parse(memberNotificationId)),
        cancelToken: CancelToken(),
      );
    }

    String? targetRoute;
    switch (pageText) {
      case 'family':
        targetRoute = AppRouter.familyAreas;
        break;
      case 'find member':
        targetRoute = AppRouter.findMember;
        break;
      case 'committee':
        targetRoute = AppRouter.committees;
        break;
      case 'payment':
        targetRoute = AppRouter.payments;
        break;
      case 'occupation directory':
        targetRoute = AppRouter.occupationDirectory;
        break;
      case 'matrimonial':
        targetRoute = AppRouter.marriage;
        break;
      case 'share app':
        targetRoute = AppRouter.shareApp;
        break;
      case 'samaj':
      case 'samaj profile':
      case 'samaj info':
        targetRoute = AppRouter.bankDetails;
        break;
      case 'support':
        targetRoute = AppRouter.customerSupport;
        break;
      case 'notification':
      case 'notifications':
      case 'notificatiion':
        targetRoute = AppRouter.notifications;
        break;
      default:
        targetRoute = null;
        break;
    }

    if (targetRoute != null) {
      if (Get.currentRoute == targetRoute) {
        Get.offNamed<void>(targetRoute);
      } else {
        // Push target route on top of home screen so the back button appears
        Get.offAllNamed<void>(AppRouter.home);
        // Add a small delay to allow the Home route transition to begin 
        // before pushing the target route, preventing GetX navigation collisions.
        Future.delayed(const Duration(milliseconds: 250), () {
          Get.toNamed<void>(targetRoute!);
        });
      }
    } else {
      // No specific target, fallback to home screen
      Get.offAllNamed<void>(AppRouter.home);
    }
  }
}

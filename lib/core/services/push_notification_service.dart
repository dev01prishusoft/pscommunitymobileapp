import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.i('Handling a background message: ${message.messageId}');
}

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Log the FCM token on startup for testing
      final token = await _firebaseMessaging.getToken();
      AppLogger.d('=== DEVICE TOKEN (on Startup) ===\n$token');

      // Request permissions for iOS and Android 13+
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Set up local notifications for foreground display
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

      // Create Android channel for high importance
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // name
        description: 'This channel is used for important notifications.', // description
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Configure foreground presentation options for iOS
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        AppLogger.i('Foreground message received: ${message.messageId}');
        _showLocalNotification(message, channel);
      });

      // Handle when the app is opened from a background state
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        AppLogger.i('Message opened app: ${message.messageId}');
        _handleMessageTap(message);
      });

      // Check if the app was opened from a terminated state
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        AppLogger.i('Message opened app from terminated state: ${initialMessage.messageId}');
        _handleMessageTap(initialMessage);
      }

      _isInitialized = true;
      AppLogger.i('Push notifications initialized successfully');
    } catch (e, stack) {
      AppLogger.e('Failed to initialize push notifications', e, stack);
    }
  }

  void _showLocalNotification(RemoteMessage message, AndroidNotificationChannel channel) {
    final notification = message.notification;

    // We only show a local notification if the FCM payload includes a notification object.
    // Data-only messages should be handled silently or with custom UI.
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
        // Create a dummy RemoteMessage to handle routing based on data
        final message = RemoteMessage(data: data);
        _handleMessageTap(message);
      } catch (e) {
        AppLogger.e('Error decoding notification payload', e);
      }
    }
  }

  void _handleMessageTap(RemoteMessage message) {
    AppLogger.i('Tapped notification data: ${message.data}');
    
    // Handle navigation based on message.data route and arguments
    if (message.data.containsKey('route')) {
      final route = message.data['route'] as String;
      final arguments = message.data['arguments'];
      
      Get.toNamed<void>(route, arguments: arguments);
    }
  }
}

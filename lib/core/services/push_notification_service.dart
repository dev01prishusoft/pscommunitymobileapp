import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:pscommunitymobileapp/core/utils/secure_storage_service.dart';
import 'package:pscommunitymobileapp/core/utils/token_manager.dart';
import 'package:pscommunitymobileapp/features/home/controllers/home_controller.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationService {
  PushNotificationService(this._apiClient);

  final ApiClient _apiClient;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _notificationPromptedKey = 'ps_community_notification_prompted';
  static const _syncedTokenKey = 'fcm_token_synced';

  bool _isInitialized = false;
  RemoteMessage? _initialMessageToHandle;
  StreamSubscription<String>? _tokenRefreshSub;

  bool get hasInitialMessage => _initialMessageToHandle != null;

  void handleInitialMessage() {
    if (_initialMessageToHandle != null) {
      _handleMessageTap(_initialMessageToHandle!);
      _initialMessageToHandle = null;
    }
  }

  /// Runs during DI bootstrap, before the first frame. Must not show any
  /// system dialog: the permission prompt lives in [requestPermissionIfNeeded].
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      const androidInitSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      // Permissions are requested explicitly after login, not on plugin init.
      const iosInitSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
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
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      _tokenRefreshSub = _firebaseMessaging.onTokenRefresh.listen(
        syncDeviceToken,
      );
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // iOS already presents foreground notifications itself (see
        // setForegroundNotificationPresentationOptions above); showing a local
        // one as well would produce two banners. Android does not show FCM
        // notifications while the app is in the foreground.
        if (Platform.isAndroid) {
          _showLocalNotification(message, channel);
        }
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchUnreadNotificationCount();
        }
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // If the Navigator is ready (app was active/in foreground), handle immediately.
        // If splash screen is still showing (app was in background), store it
        // so SplashController can consume it after the splash animation finishes.
        if (Get.currentRoute == AppRouter.postLoginSplash ||
            Get.currentRoute == AppRouter.login) {
          _initialMessageToHandle = message;
        } else {
          _handleMessageTap(message);
        }
      });
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _initialMessageToHandle = initialMessage;
      } else {
        // When the app is terminated, FCM data-only messages are shown as LOCAL
        // notifications via flutter_local_notifications. When the user taps such
        // a local notification, the app cold-starts but getInitialMessage() is null.
        // We must check getNotificationAppLaunchDetails() instead.
        final launchDetails = await _localNotifications
            .getNotificationAppLaunchDetails();
        if (launchDetails?.didNotificationLaunchApp ?? false) {
          final payload = launchDetails?.notificationResponse?.payload;
          if (payload != null) {
            try {
              final data = jsonDecode(payload) as Map<String, dynamic>;
              _initialMessageToHandle = RemoteMessage(data: data);
            } catch (e, stack) {
              CrashReporter.recordError(
                e,
                stack,
                reason:
                    'PushNotificationService: failed to decode launch payload',
              );
            }
          }
        }
      }

      _isInitialized = true;
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'PushNotificationService.init failed',
      );
    }
  }

  /// Asks for notification permission once, from a visible screen after login.
  /// The flag lives in secure storage, which logout clears, so a new login may
  /// be asked once more (the OS itself stops re-prompting after a denial).
  Future<void> requestPermissionIfNeeded(SecureStorageService storage) async {
    try {
      if (await storage.getBool(_notificationPromptedKey)) return;
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await storage.setBool(_notificationPromptedKey, true);
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'PushNotificationService.requestPermissionIfNeeded failed',
      );
    }
  }

  /// Uploads the current FCM token for the logged-in member. Called on every
  /// token rotation and once per Home visit; skips the request when the token
  /// has not changed since the last successful upload.
  Future<void> syncDeviceToken([String? refreshedToken]) async {
    try {
      if (!Get.isRegistered<TokenManager>() ||
          !Get.find<TokenManager>().hasToken) {
        return;
      }
      if (Platform.isIOS && await _firebaseMessaging.getAPNSToken() == null) {
        return; // onTokenRefresh fires once APNs registration completes.
      }
      final token = refreshedToken ?? await _firebaseMessaging.getToken();
      if (token == null || token.isEmpty) return;

      final storage = Get.find<SecureStorageService>();
      if (await storage.read(_syncedTokenKey) == token) return;

      await _apiClient.post(
        ApiEndpoints.memberDeviceToken,
        data: {
          'deviceToken': token,
          'deviceType': Platform.isIOS ? 'ios' : 'android',
        },
      );
      await storage.write(_syncedTokenKey, token);
    } on NotFoundFailure {
      // Endpoint not deployed yet on this backend; retried on the next call.
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'PushNotificationService.syncDeviceToken failed',
      );
    }
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
  }

  void _showLocalNotification(
    RemoteMessage message,
    AndroidNotificationChannel channel,
  ) {
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
      } catch (e, stack) {
        CrashReporter.recordError(
          e,
          stack,
          reason:
              'PushNotificationService: failed to decode tapped notification payload',
        );
      }
    }
  }

  void _handleMessageTap(RemoteMessage message) async {
    final pageText = (message.data['pageText'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final String memberNotificationId =
        message.data['memberNotificationId']?.toString() ?? '';

    if (memberNotificationId.isNotEmpty && memberNotificationId != 'null') {
      final id = int.tryParse(memberNotificationId);
      if (id != null) {
        // Fire and forget — we don't block navigation on marking a notification read
        Future(() async {
          try {
            await _apiClient.post(
              ApiEndpoints.markNotificationRead(id),
              cancelToken: CancelToken(),
            );
          } catch (e, stack) {
            CrashReporter.recordError(
              e,
              stack,
              reason:
                  'PushNotificationService: failed to mark notification read ($id)',
            );
          }
        });
      }
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
        return;
      }
      Get.toNamed<void>(targetRoute);
    } else {
      if (Get.currentRoute != AppRouter.home) {
        Get.offAllNamed<void>(AppRouter.home);
      }
    }
  }
}

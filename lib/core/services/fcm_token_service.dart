import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:permission_handler/permission_handler.dart';

/// Fetches and logs the device push token (FCM on Android, FCM/APNs on iOS).
class FcmTokenService {
  FcmTokenService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Requests notification permission, then logs the current device token.
  static Future<String?> logDeviceToken({bool requestPermission = true}) async {
    try {
      debugPrint('[FCM] ────────────────────────────────────────');
      debugPrint('[FCM] Platform: ${defaultTargetPlatform.name}');
      if (!kIsWeb) {
        debugPrint('[FCM] OS: ${Platform.operatingSystem}');
      }

      if (requestPermission) {
        await _ensureNotificationPermission();
      }

      if (!kIsWeb && Platform.isIOS) {
        debugPrint('[FCM] Fetching APNs token...');
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null && apnsToken.isNotEmpty) {
          debugPrint('[FCM] APNs token: $apnsToken');
        } else {
          debugPrint(
            '[FCM] APNs token: not available yet (simulator or permission pending)',
          );
        }
      }

      debugPrint('[FCM] Fetching FCM device token...');
      final token = await _messaging
          .getToken()
          .timeout(const Duration(seconds: 20));
      if (token != null && token.isNotEmpty) {
        debugPrint('[FCM] DEVICE TOKEN (copy for backend):');
        debugPrint('[FCM] $token');
        debugPrint('[FCM] Token length: ${token.length}');
      } else {
        debugPrint('[FCM] DEVICE TOKEN: null (check Firebase setup / google-services)');
      }
      debugPrint('[FCM] ────────────────────────────────────────');
      return token;
    } on TimeoutException {
      debugPrint(
        '[FCM] getToken() timed out after 20s. '
        'Try cold restart (R) or a physical device with Google Play.',
      );
      return null;
    } catch (e, st) {
      debugPrint('[FCM] Failed to get device token: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  static Future<void> _ensureNotificationPermission() async {
    if (kIsWeb) return;

    if (Platform.isIOS) {
      debugPrint('[FCM] Requesting iOS notification permission...');
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('[FCM] iOS permission: ${settings.authorizationStatus.name}');
      return;
    }

    if (Platform.isAndroid) {
      debugPrint('[FCM] Requesting Android POST_NOTIFICATIONS...');
      final status = await Permission.notification.request();
      debugPrint('[FCM] Android notification permission: $status');
    }
  }

  /// Call once at startup to log token + listen for refreshes.
  static Future<void> setupAndListen() async {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] ── TOKEN REFRESHED ──');
      debugPrint('[FCM] $newToken');
    });

    await logDeviceToken(requestPermission: true);
  }

  /// Registers listeners immediately; fetches token after first frame (non-blocking).
  static void setupAfterFirstFrame() {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] ── TOKEN REFRESHED ──');
      debugPrint('[FCM] $newToken');
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      unawaited(logDeviceToken(requestPermission: true));
    });
  }
}

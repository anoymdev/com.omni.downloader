import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logDownloadStarted({
    required String videoUrl,
    required String format,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'download_started',
        parameters: {
          'video_url': videoUrl,
          'format': format,
        },
      );
    } catch (_) {}
  }

  static Future<void> logDownloadSuccess({
    required String format,
    required int durationMs,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'download_success',
        parameters: {
          'format': format,
          'duration_ms': durationMs,
        },
      );
    } catch (_) {}
  }

  static Future<void> logDownloadFailed({
    required String errorReason,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'download_failed',
        parameters: {
          'error_reason': errorReason,
        },
      );
    } catch (_) {}
  }
}

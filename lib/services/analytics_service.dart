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
          'source_domain': _domainFromUrl(videoUrl),
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

  static String _domainFromUrl(String url) {
    final trimmed = url.trim();
    final parsed = Uri.tryParse(trimmed);
    final withScheme = Uri.tryParse('https://$trimmed');
    final host =
        (parsed?.host.isNotEmpty == true ? parsed!.host : withScheme?.host)
            ?.toLowerCase();

    if (host == null || host.isEmpty) return 'unknown';
    return host.startsWith('www.') ? host.substring(4) : host;
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

/// Progress event emitted by yt-dlp during a direct download.
class YtDlpProgress {
  /// 'downloading' | 'segment_done'
  final String status;
  final int downloaded;
  final int total;
  final double speed;
  final String phase;

  const YtDlpProgress({
    required this.status,
    required this.downloaded,
    required this.total,
    required this.speed,
    required this.phase,
  });

  double get fraction => total > 0 ? downloaded / total : 0.0;
}

/// Thrown when the user cancelled the download.
class YtDlpCancelledException implements Exception {
  const YtDlpCancelledException();
  @override
  String toString() => 'YtDlpCancelledException';
}

/// Service that bridges Flutter ↔ yt-dlp (Python via Chaquopy).
///
/// In addition to URL resolution, it can also **download streams directly**
/// using the same mechanism as the yt-dlp CLI (segmented `&range=` GETs,
/// proper headers, automatic retry) so downloads are not throttled by
/// YouTube.
///
/// NOTE: The MethodChannel only works from the root (main) isolate.
class YtDlpService {
  static const _channel = MethodChannel('com.omni.downloader/ytdlp');

  /// Broadcast stream of progress events from the native downloader.
  static final StreamController<YtDlpProgress> _progressController =
      StreamController<YtDlpProgress>.broadcast();

  static bool _handlerRegistered = false;

  /// Must be called once at app startup before using [downloadStream].
  static void initialize() {
    if (_handlerRegistered) return;
    _handlerRegistered = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onProgress') {
        final args =
            (call.arguments as Map?)?.cast<dynamic, dynamic>() ?? const {};
        _progressController.add(YtDlpProgress(
          status: (args['status'] ?? '').toString(),
          downloaded: _asInt(args['downloaded']),
          total: _asInt(args['total']),
          speed: _asDouble(args['speed']),
          phase: (args['phase'] ?? '').toString(),
        ));
      }
      return null;
    });
  }

  /// Listen to progress events while a download is in flight.
  static Stream<YtDlpProgress> get progressStream =>
      _progressController.stream;

  // -------------------------------------------------------------------------
  // Extract Info (Metadata & Formats)
  // -------------------------------------------------------------------------

  /// Calls yt-dlp to extract video metadata and available formats for any URL.
  ///
  /// Returns the parsed JSON map with keys: id, title, uploader, thumbnail,
  /// duration, formats (list).
  static Future<Map<String, dynamic>> extractInfo(String videoUrl) async {
    final jsonStr = await _channel.invokeMethod<String>(
      'extractInfoJson',
      {'videoUrl': videoUrl},
    );
    if (jsonStr == null || jsonStr.isEmpty) {
      throw Exception('yt-dlp did not return a response.');
    }
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    if (map.containsKey('error')) {
      throw Exception('yt-dlp: ${map['error']}');
    }
    return map;
  }

  // -------------------------------------------------------------------------
  // URL resolution (legacy — still useful for info preview)
  // -------------------------------------------------------------------------

  static Future<ResolvedStream> resolveStreamUrl({
    required String videoUrl,
    required int itag,
  }) async {
    final jsonStr = await _channel.invokeMethod<String>(
      'resolveStreamUrl',
      {'videoUrl': videoUrl, 'itag': itag.toString()},
    );
    if (jsonStr == null || jsonStr.isEmpty) {
      throw Exception('yt-dlp did not return a response.');
    }
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    if (map.containsKey('error')) {
      throw Exception('yt-dlp: ${map['error']}');
    }
    return ResolvedStream(
      url: Uri.parse(map['url'] as String),
      filesize: (map['filesize'] as num?)?.toInt() ?? 0,
      httpHeaders: _parseHeaders(map['http_headers']),
    );
  }

  static Future<ResolvedMergeStreams> resolveBestUrls({
    required String videoUrl,
    required int videoItag,
    required int audioItag,
  }) async {
    final jsonStr = await _channel.invokeMethod<String>(
      'resolveBestUrls',
      {
        'videoUrl': videoUrl,
        'videoItag': videoItag.toString(),
        'audioItag': audioItag.toString(),
      },
    );
    if (jsonStr == null || jsonStr.isEmpty) {
      throw Exception('yt-dlp did not return a response.');
    }
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    if (map.containsKey('error')) {
      throw Exception('yt-dlp: ${map['error']}');
    }
    return ResolvedMergeStreams(
      videoUrl: Uri.parse(map['video_url'] as String),
      videoSize: (map['video_size'] as num?)?.toInt() ?? 0,
      audioUrl: Uri.parse(map['audio_url'] as String),
      audioSize: (map['audio_size'] as num?)?.toInt() ?? 0,
      httpHeaders: _parseHeaders(map['http_headers']),
    );
  }

  // -------------------------------------------------------------------------
  // Direct download via yt-dlp (same as Python CLI)
  // -------------------------------------------------------------------------

  /// Downloads a single stream (by [itag]) directly through yt-dlp.
  ///
  /// [outputTemplate] supports yt-dlp placeholders like `%(ext)s`.
  /// [phase] is echoed back in progress events (e.g. "Downloading Video 1/2").
  ///
  /// Returns the **final file path** yt-dlp wrote (extension resolved).
  /// Throws [YtDlpCancelledException] if the user cancelled.
  static Future<String> downloadStream({
    required String videoUrl,
    required String itag,
    required String outputTemplate,
    String phase = '',
  }) async {
    final jsonStr = await _channel.invokeMethod<String>(
      'downloadStream',
      {
        'videoUrl': videoUrl,
        'itag': itag,
        'outputTemplate': outputTemplate,
        'phase': phase,
      },
    );
    if (jsonStr == null || jsonStr.isEmpty) {
      throw Exception('yt-dlp did not return a response.');
    }
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    if (map.containsKey('error')) {
      final err = map['error'].toString();
      if (err == 'cancelled') throw const YtDlpCancelledException();
      throw Exception('yt-dlp: $err');
    }
    final path = map['path'] as String?;
    if (path == null || path.isEmpty) {
      throw Exception('Downloaded file path is empty.');
    }
    return path;
  }

  /// Request cancellation of the in-flight download. Safe to call anytime.
  static Future<void> cancelDownload() async {
    try {
      await _channel.invokeMethod<void>('cancelDownload');
    } catch (_) {}
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  static Map<String, String> _parseHeaders(dynamic headers) {
    if (headers == null) return {};
    if (headers is Map) {
      return headers.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return {};
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}

/// A resolved stream URL from yt-dlp.
class ResolvedStream {
  final Uri url;
  final int filesize;
  final Map<String, String> httpHeaders;

  const ResolvedStream({
    required this.url,
    required this.filesize,
    required this.httpHeaders,
  });
}

/// Resolved video + audio URLs for merge downloads.
class ResolvedMergeStreams {
  final Uri videoUrl;
  final int videoSize;
  final Uri audioUrl;
  final int audioSize;
  final Map<String, String> httpHeaders;

  const ResolvedMergeStreams({
    required this.videoUrl,
    required this.videoSize,
    required this.audioUrl,
    required this.audioSize,
    required this.httpHeaders,
  });
}

import 'dart:async';
import 'dart:io';

import '../utils/formatters.dart';

/// Callback signature for download progress updates.
typedef ProgressCallback = void Function(DownloadProgress progress);

/// Immutable snapshot of download progress at a point in time.
class DownloadProgress {
  final int downloadedBytes;
  final int totalBytes;
  final double speed;
  final bool isStalled;

  const DownloadProgress({
    required this.downloadedBytes,
    required this.totalBytes,
    required this.speed,
    required this.isStalled,
  });

  double get fraction => totalBytes > 0 ? downloadedBytes / totalBytes : 0.0;
}

/// Thrown when the pre-resolved URL has expired (HTTP 403/410).
class StreamUrlExpiredException implements Exception {
  final int statusCode;
  StreamUrlExpiredException(this.statusCode);
  @override
  String toString() =>
      'StreamUrlExpiredException: HTTP $statusCode (URL has likely expired)';
}

/// Downloads a file using YouTube-native `&range=` URL parameter segments,
/// the same technique yt-dlp uses internally.
///
/// YouTube throttles downloads that request the entire file at once, but
/// serves each `&range=start-end` segment at full speed. By downloading
/// sequential ~10 MB segments appended as URL query parameters, we achieve
/// the same throughput as the yt-dlp CLI.
///
/// For non-YouTube URLs (no `googlevideo.com` host), falls back to a
/// standard single HTTP GET.
class ChunkDownloader {
  /// Segment size matching yt-dlp's default (~10 MB).
  static const int _segmentSize = 10 * 1024 * 1024;
  static const Duration _inactivityTimeout = Duration(seconds: 30);

  HttpClient? _httpClient;
  StreamSubscription<List<int>>? _activeSubscription;
  bool _isCancelled = false;

  /// Shared byte counter updated in real-time by segment callbacks.
  /// The speed timer reads this every second to compute speed accurately.
  int _downloaded = 0;

  /// Cancel the in-progress download. Safe to call multiple times.
  void cancel() {
    _isCancelled = true;
    _activeSubscription?.cancel();
    _activeSubscription = null;
    try {
      _httpClient?.close(force: true);
    } catch (_) {}
    _httpClient = null;
  }

  /// Downloads from [url] to [filePath], reporting progress via [onProgress].
  ///
  /// Throws [StreamUrlExpiredException] on HTTP 403/410.
  Future<void> download({
    required Uri url,
    required String filePath,
    required int totalBytes,
    required ProgressCallback onProgress,
    Map<String, String> httpHeaders = const {},
  }) async {
    _isCancelled = false;

    final file = File(filePath);
    await file.parent.create(recursive: true);

    final isYouTube = url.host.contains('googlevideo.com');

    if (isYouTube && totalBytes > 0) {
      await _downloadYouTubeSegmented(
        url: url,
        filePath: filePath,
        totalBytes: totalBytes,
        httpHeaders: httpHeaders,
        onProgress: onProgress,
      );
    } else {
      await _downloadStandard(
        url: url,
        filePath: filePath,
        totalBytes: totalBytes,
        httpHeaders: httpHeaders,
        onProgress: onProgress,
      );
    }
  }

  bool get wasCancelled => _isCancelled;

  // -----------------------------------------------------------------------
  // YouTube segmented download using &range= URL parameter
  // -----------------------------------------------------------------------

  /// Downloads a YouTube stream by requesting sequential ~10 MB segments
  /// via the `&range=start-end` URL query parameter. Each segment is served
  /// at full speed — this is exactly what yt-dlp does internally.
  ///
  /// Uses a single shared [_downloaded] counter that both the speed timer
  /// and per-packet progress callbacks update, so progress and speed are
  /// always consistent and never jump.
  Future<void> _downloadYouTubeSegmented({
    required Uri url,
    required String filePath,
    required int totalBytes,
    required Map<String, String> httpHeaders,
    required ProgressCallback onProgress,
  }) async {
    _downloaded = 0;
    var lastSpeedBytes = 0;
    var stallSeconds = 0;
    double speed = 0;
    var hadError = false;
    var segmentNumber = 0;

    final raf = await File(filePath).open(mode: FileMode.write);
    var rafClosed = false;

    // Speed timer — fires every second using the shared _downloaded counter.
    final speedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      speed = (_downloaded - lastSpeedBytes).toDouble();
      stallSeconds = speed <= 0 ? stallSeconds + 1 : 0;
      lastSpeedBytes = _downloaded;
      onProgress(DownloadProgress(
        downloadedBytes: _downloaded,
        totalBytes: totalBytes,
        speed: speed,
        isStalled: stallSeconds >= 5,
      ));
    });

    try {
      while (_downloaded < totalBytes && !_isCancelled) {
        final start = _downloaded;
        final end = (start + _segmentSize - 1).clamp(0, totalBytes - 1);

        final segmentUrl = _buildSegmentUrl(url, start, end, segmentNumber);
        segmentNumber++;

        final segmentBytes = await _downloadSegment(
          url: segmentUrl,
          raf: raf,
          httpHeaders: httpHeaders,
          totalBytes: totalBytes,
          speed: () => speed,
          onProgress: onProgress,
        );

        // If server returned fewer bytes than requested, we've reached EOF.
        if (segmentBytes < (end - start + 1)) break;
      }
    } catch (_) {
      hadError = true;
      rethrow;
    } finally {
      speedTimer.cancel();
      _activeSubscription = null;
      try {
        _httpClient?.close(force: true);
      } catch (_) {}
      _httpClient = null;
      if (!rafClosed) {
        try {
          await raf.close();
        } catch (_) {}
        rafClosed = true;
      }
      if ((_isCancelled || hadError) && await File(filePath).exists()) {
        try {
          await File(filePath).delete();
        } catch (_) {}
      }
    }
  }

  /// Constructs a YouTube URL with `&range=` and `&rn=` query parameters.
  Uri _buildSegmentUrl(Uri originalUrl, int start, int end, int requestNum) {
    final params = Map<String, String>.from(originalUrl.queryParameters);
    params['range'] = '$start-$end';
    params['rn'] = '$requestNum';
    return originalUrl.replace(queryParameters: params);
  }

  /// Downloads one segment, writing directly to [raf] at its current
  /// position. Updates the shared [_downloaded] counter in real-time so
  /// the speed timer always sees accurate bytes. Returns the number of
  /// bytes written in this segment.
  Future<int> _downloadSegment({
    required Uri url,
    required RandomAccessFile raf,
    required Map<String, String> httpHeaders,
    required int totalBytes,
    required double Function() speed,
    required ProgressCallback onProgress,
  }) async {
    if (_isCancelled) return 0;

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);
    _httpClient = client;

    var segmentDownloaded = 0;
    final completer = Completer<int>();
    Timer? inactivityTimer;

    void resetTimer() {
      inactivityTimer?.cancel();
      inactivityTimer = Timer(_inactivityTimeout, () {
        _activeSubscription?.cancel();
        try {
          client.close(force: true);
        } catch (_) {}
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException(
            'No data received for ${_inactivityTimeout.inSeconds} seconds '
            'at position ${formatBytes(_downloaded)}'
            '/${formatBytes(totalBytes)}',
          ));
        }
      });
    }

    try {
      final request =
          await client.getUrl(url).timeout(const Duration(seconds: 15));

      for (final entry in httpHeaders.entries) {
        request.headers.set(entry.key, entry.value);
      }

      final response =
          await request.close().timeout(const Duration(seconds: 15));

      if (response.statusCode == 403 || response.statusCode == 410) {
        await response.drain<void>();
        throw StreamUrlExpiredException(response.statusCode);
      }
      if (response.statusCode != 200 && response.statusCode != 206) {
        await response.drain<void>();
        throw Exception('HTTP ${response.statusCode}: Download failed');
      }

      resetTimer();

      late StreamSubscription<List<int>> subscription;
      subscription = response.listen(
        (data) {
          if (_isCancelled) {
            subscription.cancel();
            inactivityTimer?.cancel();
            if (!completer.isCompleted) completer.complete(segmentDownloaded);
            return;
          }
          subscription.pause();
          raf.writeFrom(data).then((_) {
            if (_isCancelled) {
              if (!completer.isCompleted) {
                completer.complete(segmentDownloaded);
              }
              return;
            }
            segmentDownloaded += data.length;
            _downloaded += data.length; // Update shared counter for speed timer.
            resetTimer();
            onProgress(DownloadProgress(
              downloadedBytes: _downloaded,
              totalBytes: totalBytes,
              speed: speed(),
              isStalled: false,
            ));
            if (subscription.isPaused) subscription.resume();
          }).catchError((Object e) {
            if (!completer.isCompleted) completer.completeError(e);
          });
        },
        onDone: () {
          inactivityTimer?.cancel();
          if (!completer.isCompleted) completer.complete(segmentDownloaded);
        },
        onError: (Object e) {
          inactivityTimer?.cancel();
          if (!completer.isCompleted) completer.completeError(e);
        },
        cancelOnError: true,
      );

      _activeSubscription = subscription;
      if (_isCancelled) {
        subscription.cancel();
        inactivityTimer?.cancel();
        if (!completer.isCompleted) completer.complete(segmentDownloaded);
      }

      return await completer.future;
    } finally {
      inactivityTimer?.cancel();
      try {
        client.close(force: true);
      } catch (_) {}
    }
  }

  // -----------------------------------------------------------------------
  // Standard single-connection download (non-YouTube)
  // -----------------------------------------------------------------------

  Future<void> _downloadStandard({
    required Uri url,
    required String filePath,
    required int totalBytes,
    required Map<String, String> httpHeaders,
    required ProgressCallback onProgress,
  }) async {
    var total = totalBytes;
    var downloaded = 0;
    var lastSpeedBytes = 0;
    var stallSeconds = 0;
    double speed = 0;
    var hadError = false;

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);
    _httpClient = client;

    final raf = await File(filePath).open(mode: FileMode.write);
    final completer = Completer<void>();
    Timer? inactivityTimer;
    var rafClosed = false;

    final speedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      speed = (downloaded - lastSpeedBytes).toDouble();
      stallSeconds = speed <= 0 ? stallSeconds + 1 : 0;
      lastSpeedBytes = downloaded;
      onProgress(DownloadProgress(
        downloadedBytes: downloaded,
        totalBytes: total,
        speed: speed,
        isStalled: stallSeconds >= 5,
      ));
    });

    void resetTimer() {
      inactivityTimer?.cancel();
      inactivityTimer = Timer(_inactivityTimeout, () {
        _activeSubscription?.cancel();
        try {
          client.close(force: true);
        } catch (_) {}
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException(
            'No data received for ${_inactivityTimeout.inSeconds} seconds '
            'at position ${formatBytes(downloaded)}/${formatBytes(total)}',
          ));
        }
      });
    }

    try {
      final request =
          await client.getUrl(url).timeout(const Duration(seconds: 15));
      for (final e in httpHeaders.entries) {
        request.headers.set(e.key, e.value);
      }
      final response =
          await request.close().timeout(const Duration(seconds: 15));

      if (response.statusCode == 403 || response.statusCode == 410) {
        await response.drain<void>();
        throw StreamUrlExpiredException(response.statusCode);
      }
      if (response.statusCode != 200 && response.statusCode != 206) {
        await response.drain<void>();
        throw Exception('HTTP ${response.statusCode}: Download failed');
      }
      final cl = response.contentLength;
      if (cl > 0) total = cl;

      resetTimer();

      late StreamSubscription<List<int>> subscription;
      subscription = response.listen(
        (data) {
          if (_isCancelled) {
            subscription.cancel();
            inactivityTimer?.cancel();
            if (!completer.isCompleted) completer.complete();
            return;
          }
          subscription.pause();
          raf.writeFrom(data).then((_) {
            if (_isCancelled) {
              if (!completer.isCompleted) completer.complete();
              return;
            }
            downloaded += data.length;
            resetTimer();
            onProgress(DownloadProgress(
              downloadedBytes: downloaded,
              totalBytes: total,
              speed: speed,
              isStalled: false,
            ));
            if (subscription.isPaused) subscription.resume();
          }).catchError((Object e) {
            if (!completer.isCompleted) completer.completeError(e);
          });
        },
        onDone: () {
          inactivityTimer?.cancel();
          if (!completer.isCompleted) completer.complete();
        },
        onError: (Object e) {
          inactivityTimer?.cancel();
          if (!completer.isCompleted) completer.completeError(e);
        },
        cancelOnError: true,
      );

      _activeSubscription = subscription;
      if (_isCancelled) {
        subscription.cancel();
        inactivityTimer?.cancel();
        if (!completer.isCompleted) completer.complete();
      }
      await completer.future;
    } catch (_) {
      hadError = true;
      rethrow;
    } finally {
      speedTimer.cancel();
      inactivityTimer?.cancel();
      _activeSubscription = null;
      try {
        client.close(force: true);
      } catch (_) {}
      _httpClient = null;
      if (!rafClosed) {
        try {
          await raf.close();
        } catch (_) {}
        rafClosed = true;
      }
      if ((_isCancelled || hadError) && await File(filePath).exists()) {
        try {
          await File(filePath).delete();
        } catch (_) {}
      }
    }
  }
}

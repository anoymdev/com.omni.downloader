import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:omni_downloader/l10n/app_localizations.dart';
import '../app.dart';
import '../models/video_metadata.dart';

import '../models/download_option.dart';
import '../services/analytics_service.dart';
import '../services/foreground_task_handler.dart';
import '../services/config_service.dart';
import '../services/stream_resolver.dart';
import '../services/ytdlp_service.dart';
import '../utils/formatters.dart';
import 'widgets/download_progress_card.dart';
import 'widgets/save_location_card.dart';

import 'widgets/stream_list.dart';
import 'widgets/url_input_card.dart';
import 'widgets/video_info_card.dart';

/// Terminal status of the most recent download attempt — drives the color
/// of [StatusMessageCard] so an error after a finished download phase
/// (e.g. FFmpeg failure) does not render as a green success.


/// Main screen of the app — URL input, stream selection, download progress.
class DownloaderScreen extends StatefulWidget {
  const DownloaderScreen({super.key});

  @override
  State<DownloaderScreen> createState() => _DownloaderScreenState();
}

class _DownloaderScreenState extends State<DownloaderScreen> {
  static const String _donateUrl = 'https://saweria.co/anoymdev';
  static const String _defaultSaveDir = '/storage/emulated/0/Download/OmniDownloader';
  static const String _prefKeySaveDir = 'save_directory';

  final _urlController = TextEditingController();
  // Video & stream state.
  VideoMetadata? _videoInfo;
  List<DownloadOption> _streamOptions = [];
  DownloadOption? _selectedStream;

  // Save directory.
  String _saveDirectory = _defaultSaveDir;

  // UI state.
  bool _isFetching = false;
  bool _isDownloading = false;
  double _progress = 0.0;
  double _downloadSpeed = 0.0;
  int _downloadedBytes = 0;
  int _totalBytes = 0;

  String _currentPhase = '';
  bool _isStalled = false;


  DateTime? _downloadStartTime;
  String _downloadFormat = '';

  Timer? _stopServiceTimer;
  StreamSubscription<YtDlpProgress>? _progressSub;

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
    _loadSaveDirectory();
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);
    // Subscribe to native yt-dlp progress events.
    _progressSub = YtDlpService.progressStream.listen(_onYtDlpProgress);
    // Best-effort early request so the notification can be shown when a
    // download is eventually started. Result is irrelevant at this point.
    Future.microtask(() async {
      try {
        await FlutterForegroundTask.requestNotificationPermission();
      } catch (_) {}
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkDisclaimer();
      if (mounted) {
        _checkUpdate();
      }
    });
  }

  @override
  void dispose() {
    _stopServiceTimer?.cancel();
    _progressSub?.cancel();
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    _urlController.dispose();

    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Foreground task setup
  // -------------------------------------------------------------------------

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'omni_download_channel',
        channelName: 'Download Progress',
        channelDescription: 'Displays video download progress',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        showWhen: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Data from foreground service
  // -------------------------------------------------------------------------

  void _onTaskData(Object data) {
    if (data is! String || !mounted) return;
    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      final status = map['status'] as String?;

      setState(() {
        switch (status) {
          case 'fetching':
            _currentPhase = AppLocalizations.of(context)!.preparing;
            break;
          case 'downloading':
            _isDownloading = true;
            _currentPhase = map['phase'] as String? ?? '';
            _progress = (map['progress'] as num?)?.toDouble() ?? 0.0;
            _downloadedBytes = (map['downloaded'] as num?)?.toInt() ?? 0;
            _totalBytes = (map['total'] as num?)?.toInt() ?? 0;
            _downloadSpeed = (map['speed'] as num?)?.toDouble() ?? 0.0;
            _isStalled = map['stalled'] == true;
            break;
          case 'merging':
            _currentPhase = map['phase'] as String? ?? AppLocalizations.of(context)!.merging;
            _progress = 0.0;
            _totalBytes = 0;
            break;
          case 'done':
            _isDownloading = false;
            _progress = 1.0;
            _currentPhase = '';
            _isStalled = false;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showStatusDialog(
                isSuccess: true,
                message: map['message'] as String? ?? AppLocalizations.of(context)!.downloadSucceeded,
              );
            });
            break;
          case 'error':
            _isDownloading = false;
            _currentPhase = '';
            _isStalled = false;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showStatusDialog(
                isSuccess: false,
                message: _friendlyError(map['message'] as String? ?? 'Error'),
              );
            });
            break;
          case 'cancelled':
            _isDownloading = false;
            _currentPhase = '';
            _isStalled = false;

            break;
        }
      });

      // Auto-stop service after terminal states. Cancel any previously-
      // scheduled stop first so a new download doesn't get killed.
      if (status == 'done' || status == 'error' || status == 'cancelled') {
        _stopServiceTimer?.cancel();
        _stopServiceTimer = Timer(const Duration(seconds: 3), () {
          FlutterForegroundTask.stopService();
        });
      }
    } catch (_) {}
  }

  Future<void> _checkDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasAccepted = prefs.getBool('hasAcceptedDisclaimer') ?? false;

    if (hasAccepted || !mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            contentPadding: EdgeInsets.all(16),
            insetPadding: EdgeInsets.all(20),
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
                const SizedBox(width: 10),
                Text(AppLocalizations.of(context)!.disclaimerTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.disclaimerIntro, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildDisclaimerBullet(Icons.person_rounded, AppLocalizations.of(context)!.disclaimerPoint1),
                  _buildDisclaimerBullet(Icons.cloud_upload_rounded, AppLocalizations.of(context)!.disclaimerPoint2),
                  _buildDisclaimerBullet(Icons.public_rounded, AppLocalizations.of(context)!.disclaimerPoint3),
                  _buildDisclaimerBullet(Icons.offline_pin_rounded, AppLocalizations.of(context)!.disclaimerPoint4),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent.withAlpha(76)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.disclaimerWarning,
                            style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.disclaimerResponsibility,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  await prefs.setBool('hasAcceptedDisclaimer', true);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                ),
                child: Text(AppLocalizations.of(context)!.disclaimerAccept),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisclaimerBullet(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00BCD4)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkUpdate() async {
    final status = await ConfigData.checkUpdate();
    if (status == AppVersionType.upToDate) return;
    if (!mounted) return;

    final isForceUpdate = status == AppVersionType.expired;

    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (ctx) {
        return PopScope(
          canPop: !isForceUpdate,
          onPopInvokedWithResult: (didPop, _) {
            if (isForceUpdate && !didPop) {
              SystemNavigator.pop();
            }
          },
          child: AlertDialog(
            title: Text(AppLocalizations.of(context)!.updateAvailable),
            content: Text(
              isForceUpdate
                  ? AppLocalizations.of(context)!.updateOutdated
                  : AppLocalizations.of(context)!.updateNewVersion,
            ),
            actions: [
              if (!isForceUpdate)
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(AppLocalizations.of(context)!.updateLater),
                ),
              if (isForceUpdate)
                TextButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: Text(AppLocalizations.of(context)!.updateExit),
                ),
              ElevatedButton(
                onPressed: () async {
                  final url = ConfigData.getValue('updateUrl');
                  if (url.isNotEmpty) {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  } else {
                    // Fallback to the github release link if url is empty
                    await launchUrl(Uri.parse('https://github.com/anoymdev/com.anoym.ytdownloader/releases/latest'), 
                        mode: LaunchMode.externalApplication);
                  }
                  if (!ctx.mounted) return;
                  if (isForceUpdate) {
                    SystemNavigator.pop();
                  } else {
                    Navigator.of(ctx).pop();
                  }
                },
                child: Text(AppLocalizations.of(context)!.updateButton),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  Future<void> _fetchStreams() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.pleaseEnterUrl);
      return;
    }

    setState(() {
      _isFetching = true;
      _videoInfo = null;
      _streamOptions = [];
      _selectedStream = null;
      _progress = 0.0;

    });

    try {
      final resolver = StreamResolver();
      final (metadata, options) = await resolver.resolve(url);
      if (!mounted) return;

      setState(() {
        _videoInfo = metadata;
        _streamOptions = options;
        _selectedStream = options.isNotEmpty ? options.first : null;
        _isFetching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetching = false;

      });
      _showStatusDialog(
        isSuccess: false,
        message: _friendlyError(e.toString()),
      );
    }
  }

  Future<void> _startDownload() async {
    if (_selectedStream == null || _videoInfo == null) return;
    final opt = _selectedStream!;

    // Cancel any pending service-stop from a previous download.
    _stopServiceTimer?.cancel();

    // Request notification permission (Android 13+).
    try {
      await FlutterForegroundTask.requestNotificationPermission();
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _downloadedBytes = 0;
      _totalBytes = 0;
      _downloadSpeed = 0.0;
      _currentPhase = AppLocalizations.of(context)!.preparing;
      _isStalled = false;

    });

    // Start the foreground service as a simple "keep-alive" so the OS
    // doesn't kill our process when the user backgrounds the app. The
    // actual download runs here in the main isolate via yt-dlp/Chaquopy.
    try {
      await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: AppLocalizations.of(context)!.appTitle,
        notificationText: AppLocalizations.of(context)!.downloadStarting,
        callback: startCallback,
      );
    } catch (_) {}

    final videoUrl = _urlController.text.trim();

    _downloadStartTime = DateTime.now();
    _downloadFormat = opt.tag;
    AnalyticsService.logDownloadStarted(
      videoUrl: videoUrl,
      format: _downloadFormat,
    );

    try {
      final saveDir = await _resolveSaveDirectory();
      final cleanTitle = _sanitizeFileName(_videoInfo!.title);
      String ext = opt.ext;
      if (opt.isAudioOnly && ext == 'mp4') {
        ext = 'm4a';
      }

      if (opt.needsMerge && opt.audioFormatId != null) {
        // Download video-only + audio-only in sequence via yt-dlp, then
        // merge with FFmpeg.
        final ts = DateTime.now().millisecondsSinceEpoch;
        final tempVideoTemplate =
            '${saveDir.path}/tmp_v_$ts.%(ext)s';
        final tempAudioTemplate =
            '${saveDir.path}/tmp_a_$ts.%(ext)s';
        final finalPath = _uniquePath(
          saveDir.path,
          '$cleanTitle-${opt.tag}',
          ext,
        );

        String? videoFile;
        String? audioFile;
        try {
          if (!mounted) return;
          setState(() => _currentPhase = AppLocalizations.of(context)!.downloadingVideo);
          _updateNotification(
              AppLocalizations.of(context)!.appTitle, AppLocalizations.of(context)!.downloadingVideo);

          videoFile = await YtDlpService.downloadStream(
            videoUrl: videoUrl,
            itag: opt.formatId,
            outputTemplate: tempVideoTemplate,
            phase: 'Downloading Video (1/2)',
          );

          if (!mounted) return;
          setState(() {
            _currentPhase = AppLocalizations.of(context)!.downloadingAudio;
            _downloadedBytes = 0;
            _totalBytes = 0;
            _downloadSpeed = 0.0;
            _progress = 0.0;
          });
          _updateNotification(
              AppLocalizations.of(context)!.appTitle, AppLocalizations.of(context)!.downloadingAudio);

          audioFile = await YtDlpService.downloadStream(
            videoUrl: videoUrl,
            itag: opt.audioFormatId!,
            outputTemplate: tempAudioTemplate,
            phase: 'Downloading Audio (2/2)',
          );

          if (!mounted) return;
          setState(() {
            _currentPhase = AppLocalizations.of(context)!.mergingVideoAudio;
            _progress = 0.0;
            _totalBytes = 0;
            _downloadSpeed = 0.0;
          });
          _updateNotification(
              AppLocalizations.of(context)!.appTitle, AppLocalizations.of(context)!.mergingVideoAudio);

          final session = await FFmpegKit.executeWithArguments([
            '-y',
            '-i', videoFile,
            '-i', audioFile,
            '-c', 'copy',
            finalPath,
          ]);
          final rc = await session.getReturnCode();
          if (!ReturnCode.isSuccess(rc)) {
            throw Exception('FFmpeg failed to merge files.');
          }
        } finally {
          if (videoFile != null) await _cleanupFile(videoFile);
          if (audioFile != null) await _cleanupFile(audioFile);
        }

        _onDownloadSuccess(finalPath, cleanTitle);
      } else {
        // Muxed or audio-only: one shot.
        final outputTemplate =
            '${saveDir.path}/$cleanTitle-${opt.tag}.%(ext)s';

        if (!mounted) return;
        setState(() => _currentPhase = AppLocalizations.of(context)!.downloading);
        _updateNotification(AppLocalizations.of(context)!.appTitle, AppLocalizations.of(context)!.downloading);

        final finalFile = await YtDlpService.downloadStream(
          videoUrl: videoUrl,
          itag: opt.formatId,
          outputTemplate: outputTemplate,
          phase: 'Mengunduh',
        );

        _onDownloadSuccess(finalFile, cleanTitle);
      }
    } on YtDlpCancelledException {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _currentPhase = '';
        _isStalled = false;

      });
      _updateNotification(AppLocalizations.of(context)!.downloadCancelled, '');
      _scheduleServiceStop();
    } catch (e) {
      AnalyticsService.logDownloadFailed(errorReason: e.toString());
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _currentPhase = '';
        _isStalled = false;

      });
      _updateNotification(AppLocalizations.of(context)!.downloadFailed, _friendlyError(e.toString()));
      _scheduleServiceStop();
      _showStatusDialog(
        isSuccess: false,
        message: _friendlyError(e.toString()),
      );
    }
  }

  void _onYtDlpProgress(YtDlpProgress p) {
    if (!mounted || !_isDownloading) return;
    setState(() {
      _currentPhase = p.phase.isNotEmpty ? p.phase : _currentPhase;
      _downloadedBytes = p.downloaded;
      _totalBytes = p.total;
      _downloadSpeed = p.speed;
      _progress = p.fraction;
      _isStalled = p.status == 'downloading' && p.speed == 0;
    });
    // Throttled notification update (every ~second is fine; speed timer
    // on native side emits at yt-dlp's natural pace).
    _updateNotification(
      '${p.phase} ${(p.fraction * 100).toStringAsFixed(0)}%',
      '${formatBytes(p.downloaded)}/${formatBytes(p.total)} • '
          '${formatSpeed(p.speed)}',
    );
  }

  void _onDownloadSuccess(String filePath, String title) {
    final durationMs = _downloadStartTime != null
        ? DateTime.now().difference(_downloadStartTime!).inMilliseconds
        : 0;
    AnalyticsService.logDownloadSuccess(
      format: _downloadFormat,
      durationMs: durationMs,
    );

    if (!mounted) return;
    setState(() {
      _isDownloading = false;
      _progress = 1.0;
      _currentPhase = '';
      _isStalled = false;

    });
    _showStatusDialog(
      isSuccess: true,
      message: '${AppLocalizations.of(context)!.downloadSucceeded}\n\nSaved to:\n$filePath',
    );
    _updateNotification(AppLocalizations.of(context)!.downloadCompleted, title);
    _scheduleServiceStop();
  }

  void _scheduleServiceStop() {
    _stopServiceTimer?.cancel();
    _stopServiceTimer = Timer(const Duration(seconds: 3), () {
      try {
        FlutterForegroundTask.stopService();
      } catch (_) {}
    });
  }

  void _updateNotification(String title, String text) {
    try {
      FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: text,
      );
    } catch (_) {}
  }

  // -------------------------------------------------------------------------
  // Save directory management
  // -------------------------------------------------------------------------

  Future<void> _loadSaveDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKeySaveDir);
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() => _saveDirectory = saved);
    }
  }

  Future<void> _persistSaveDirectory(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeySaveDir, path);
  }

  Future<void> _pickSaveDirectory() async {
    // Request storage permission on Android.
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        if (!mounted) return;
        _showSnackBar(AppLocalizations.of(context)!.storagePermission);
        return;
      }
    }

    final selectedDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: AppLocalizations.of(context)!.chooseSaveLocation,
      initialDirectory: _saveDirectory,
    );

    if (selectedDir == null || !mounted) return;

    // Verify the directory is writable.
    final dir = Directory(selectedDir);
    try {
      if (!await dir.exists()) await dir.create(recursive: true);
      final probe = File('${dir.path}/.write_probe');
      await probe.writeAsString('ok', flush: true);
      await probe.delete();
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.folderNotWritable);
      return;
    }

    if (!mounted) return;
    setState(() => _saveDirectory = selectedDir);
    await _persistSaveDirectory(selectedDir);
    if (!mounted) return;
    _showSnackBar(AppLocalizations.of(context)!.saveLocationUpdated);
  }

  // -------------------------------------------------------------------------
  // File helpers
  // -------------------------------------------------------------------------

  Future<Directory> _resolveSaveDirectory() async {
    final dir = Directory(_saveDirectory);
    try {
      if (!await dir.exists()) await dir.create(recursive: true);
      final probe = File('${dir.path}/.write_probe');
      await probe.writeAsString('ok', flush: true);
      await probe.delete();
      return dir;
    } catch (_) {}
    // Fallback if the selected directory is not writable.
    if (Platform.isAndroid) {
      final fallback = Directory(_defaultSaveDir);
      try {
        if (!await fallback.exists()) await fallback.create(recursive: true);
        return fallback;
      } catch (_) {}
    }
    return await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
  }

  String _sanitizeFileName(String name) {
    var cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_');
    cleaned = cleaned.replaceAll(RegExp(r'[. ]+$'), '').trim();
    if (cleaned.isEmpty) cleaned = 'video';
    if (cleaned.length > 150) cleaned = cleaned.substring(0, 150);
    return cleaned;
  }

  String _uniquePath(String dir, String base, String ext) {
    var candidate = '$dir/$base.$ext';
    var i = 1;
    while (File(candidate).existsSync()) {
      candidate = '$dir/$base ($i).$ext';
      i++;
    }
    return candidate;
  }

  Future<void> _cleanupFile(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  void _cancelDownload() {
    YtDlpService.cancelDownload();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // -------------------------------------------------------------------------
  // Status dialog (replaces the old bottom card)
  // -------------------------------------------------------------------------

  void _showStatusDialog({
    required bool isSuccess,
    required String message,
  }) {
    if (!mounted) return;
    final color = isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFFF5252);
    final icon = isSuccess
        ? Icons.check_circle_rounded
        : Icons.error_rounded;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 52),
              const SizedBox(height: 16),
              Text(
                isSuccess ? AppLocalizations.of(context)!.success : AppLocalizations.of(context)!.failed,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withValues(alpha: 0.15),
                  foregroundColor: color,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.ok,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Converts raw technical error strings into user-friendly messages.
  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();

    if (lower.contains('timed out') || lower.contains('timeout')) {
      return AppLocalizations.of(context)!.connectionLost;
    }
    if (lower.contains('no internet') ||
        lower.contains('socketexception') ||
        lower.contains('network is unreachable') ||
        lower.contains('failed host lookup')) {
      return AppLocalizations.of(context)!.noInternet;
    }
    if (lower.contains('ssl') || lower.contains('handshake')) {
      return AppLocalizations.of(context)!.sslError;
    }
    if (lower.contains('unsupported url') ||
        lower.contains('no video formats') ||
        lower.contains('is not a valid url')) {
      return AppLocalizations.of(context)!.unsupportedUrl;
    }
    if (lower.contains('private video') ||
        lower.contains('login required') ||
        lower.contains('sign in')) {
      return AppLocalizations.of(context)!.privateVideo;
    }
    if (lower.contains('copyright') || lower.contains('blocked')) {
      return AppLocalizations.of(context)!.copyrightBlocked;
    }
    if (lower.contains('age') && lower.contains('restrict')) {
      return AppLocalizations.of(context)!.ageRestricted;
    }
    if (lower.contains('ffmpeg')) {
      return AppLocalizations.of(context)!.mergeFailed;
    }

    // Strip common prefixes for a cleaner display
    var cleaned = raw;
    cleaned = cleaned.replaceFirst(RegExp(r'^Exception:\s*'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'^yt-dlp:\s*'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'^ERROR:\s*', caseSensitive: false), '');
    return cleaned;
  }

  // -------------------------------------------------------------------------
  // Donate dialog
  // -------------------------------------------------------------------------

  Future<void> _openLink(String urlString) async {
    final uri = Uri.parse(urlString);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      _showSnackBar(AppLocalizations.of(context)!.unableToOpenLink);
    }
  }

  Future<void> _showInfoDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          title: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Color(0xFF7C4DFF), size: 22),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.donateTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.donateDesc,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openLink('https://wa.me/6287854874512'),
                      icon: const Icon(Icons.chat_rounded, size: 16),
                      label: const Text('WhatsApp', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openLink('https://t.me/anoymdev'),
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Telegram', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0088cc),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.donateTitle,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF7C4DFF)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: Color(0xFF7C4DFF), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SelectableText(
                        _donateUrl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () => _openLink(_donateUrl),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(AppLocalizations.of(context)!.donateButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(AppLocalizations.of(context)!.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(AppLocalizations.of(context)!.systemDefault),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('languageCode');
                  if (!ctx.mounted) return;
                  MyApp.setLocale(ctx, null);
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.english),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('languageCode', 'en');
                  if (!ctx.mounted) return;
                  MyApp.setLocale(ctx, const Locale('en'));
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.indonesian),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('languageCode', 'id');
                  if (!ctx.mounted) return;
                  MyApp.setLocale(ctx, const Locale('id'));
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar.
          SliverAppBar(
            expandedHeight: 110,
            pinned: true,
            actions: [
              IconButton(
                tooltip: AppLocalizations.of(context)!.language,
                icon: const Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                ),
                onPressed: _showLanguageDialog,
              ),
              IconButton(
                tooltip: 'Developer Info',
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                ),
                onPressed: _showInfoDialog,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset('assets/images/app_icon.png', width: 24, height: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.appTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFF00BCD4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // Content.
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // URL input.
                UrlInputCard(
                  controller: _urlController,
                  enabled: !_isFetching && !_isDownloading,
                  isLoading: _isFetching,
                  onSearch:
                      (_isFetching || _isDownloading) ? null : _fetchStreams,
                ),

                // Video info.
                if (_videoInfo != null) ...[
                  const SizedBox(height: 12),
                  VideoInfoCard(video: _videoInfo!),
                ],

                // Stream selection + download button.
                if (_streamOptions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SaveLocationCard(
                    directoryPath: _saveDirectory,
                    enabled: !_isDownloading,
                    onPickDirectory: _pickSaveDirectory,
                  ),
                  const SizedBox(height: 12),
                  StreamList(
                    options: _streamOptions,
                    selected: _selectedStream,
                    isDownloading: _isDownloading,
                    onSelect: (opt) => setState(() => _selectedStream = opt),
                    onDownload:
                        (_isDownloading || _selectedStream == null)
                            ? null
                            : _startDownload,
                    onCancel: _cancelDownload,
                  ),
                ],

                // Download progress.
                if (_isDownloading) ...[
                  const SizedBox(height: 16),
                  DownloadProgressCard(
                    phase: _currentPhase,
                    progress: _progress,
                    downloadedBytes: _downloadedBytes,
                    totalBytes: _totalBytes,
                    speed: _downloadSpeed,
                    isStalled: _isStalled,
                  ),
                ],


              ]),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'services/config_service.dart';
import 'services/ytdlp_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final analyticsEnabled =
      prefs.getBool('analytics_crash_reporting_enabled') ?? true;
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
    analyticsEnabled,
  );
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    analyticsEnabled,
  );

  // Initialize Remote Config
  await ConfigData.initialize();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  FlutterForegroundTask.initCommunicationPort();
  // Register the MethodChannel listener that receives yt-dlp progress
  // events from the native side. Must be called from the main isolate.
  YtDlpService.initialize();

  runApp(const MyApp());
}

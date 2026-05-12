# Flutter plugins
-keep class io.flutter.plugins.** { *; }

# FFmpegKit
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.antonkarpenko.ffmpegkit.** { *; }

# SharedPreferences
-keep class dev.flutter.pigeon.shared_preferences_android.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# General Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Ignore warnings for optional dependencies
-dontwarn com.google.android.play.core.**

# Keep MainActivity for Chaquopy JNI/Reflection
-keep class com.omni.downloader.MainActivity { *; }
-keep class com.omni.downloader.MainActivity$** { *; }

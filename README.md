# Omni Downloader

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://www.android.com/)
[![yt-dlp](https://img.shields.io/badge/yt--dlp-Latest-red.svg)](https://github.com/yt-dlp/yt-dlp)

**Download videos from 1000+ platforms - YouTube, Instagram, TikTok, Twitter, and more!**

Built with Flutter + yt-dlp + FFmpeg

[Features](#features) • [Supported Platforms](#supported-platforms) • [Installation](#installation) • [Usage](#usage) • [Architecture](#architecture)

</div>

---

## 📋 Table of Contents

- [About](#about)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Building](#building)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Support](#support)
- [License](#license)

---

## About

**Omni Downloader** is a powerful and versatile Flutter application that enables downloading videos from **1000+ platforms** worldwide. Powered by **yt-dlp** and **FFmpeg**, it supports YouTube, Instagram, TikTok, Twitter/X, Facebook, Vimeo, and countless other video hosting services. Built with Material Design 3, it delivers a seamless user experience with real-time download tracking, background task support, and intelligent format selection.

Unlike platform-specific solutions, Omni Downloader uses a unified backend (yt-dlp) that automatically adapts to any supported platform, ensuring comprehensive compatibility and automatic updates as new platforms are added.

### Key Highlights

- 🌍 **1000+ Platforms**: Download from YouTube, Instagram, TikTok, Twitter, Facebook, Vimeo, and more
- 🎯 **Smart Format Selection**: Automatically lists all available quality/format combinations per platform
- 🔄 **Background Downloads**: Continue downloading even when the app is minimized with foreground service
- 📊 **Real-time Progress**: Live download speed, progress percentage, and phase tracking
- 🎬 **Video + Audio Merging**: Download best quality video & audio separately, then merge with FFmpeg
- 🔔 **Download Notifications**: Foreground notification for active downloads and progress status
- 📱 **Material Design 3**: Modern, intuitive dark-themed UI
- 🛡️ **Robust Error Handling**: Firebase Crashlytics for automatic error tracking
- 📈 **Usage Analytics**: Firebase Analytics integration

---

## ✨ Features

### Universal Platform Support
- ✅ **YouTube** - All formats, playlists, age-restricted content
- ✅ **Instagram** - Reels, stories, posts, and IGTV
- ✅ **TikTok** - Videos without watermark
- ✅ **Twitter/X** - Videos, live streams, and moments
- ✅ **Facebook** - Videos and live streams
- ✅ **Vimeo** - High-quality videos
- ✅ **1000+ Other Platforms** - Automatically supported via yt-dlp

### Core Functionality
- ✅ **Universal URL Input** - Paste any supported URL to fetch metadata
- ✅ **Metadata Display** - View title, author, thumbnail, duration (platform-agnostic)
- ✅ **Format Selection** - List ALL available formats for optimal downloads
- ✅ **Smart Quality Options** - Download in various resolutions (auto-selects best available)
- ✅ **Audio Extraction** - Extract to MP3, M4A, or other audio formats
- ✅ **Video/Audio Merging** - Download separate streams and intelligently merge
- ✅ **Custom Save Location** - Choose where to save downloaded files
- ✅ **Download Management** - Track multiple downloads with real-time stats
- ✅ **FFmpeg Processing** - Professional-grade video/audio post-processing

### Technical Features
- 🔐 **Permission Management** - Handles storage and notification permissions
- 🔄 **Foreground Service** - Background downloads with persistent notification
- 💾 **Preference Storage** - Saves user settings and download history
- 📡 **Remote Configuration** - Dynamic feature control via Firebase Remote Config
- 🐛 **Crash Reporting** - Automatic error tracking and diagnostics
- 📊 **Usage Analytics** - Anonymous analytics for app improvement
- 🐍 **Python Bridge** - Chaquopy-powered yt-dlp integration for reliability

---

## 🌐 Supported Platforms

Omni Downloader supports **1000+ video platforms** through yt-dlp. Here are the most popular ones:

### Popular Services
| Platform | Support | Features |
|----------|---------|----------|
| 📺 **YouTube** | ✅ Full | Videos, playlists, streams, shorts |
| 📸 **Instagram** | ✅ Full | Reels, posts, IGTV, stories |
| 🎵 **TikTok** | ✅ Full | Videos, no watermark |
| 🐦 **Twitter/X** | ✅ Full | Videos, GIFs, live streams |
| 👥 **Facebook** | ✅ Full | Videos, live streams |
| 🎬 **Vimeo** | ✅ Full | High-quality videos |
| 🎤 **Twitch** | ✅ Full | VODs, clips, streams |
| 🎙️ **Dailymotion** | ✅ Full | Videos, playlists |
| 📹 **Bilibili** | ✅ Full | Chinese video platform |
| 🎯 **Reddit** | ✅ Full | Videos, GIFs |
| **1000+ More** | ✅ Supported | See [yt-dlp supported sites](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md) |

### How It Works
Omni Downloader uses **yt-dlp** — a maintained fork of youtube-dl with support for 1000+ sites. When you paste a URL:
1. App sends URL to Python backend (via Chaquopy)
2. yt-dlp automatically detects the platform and extracts metadata
3. Available formats are displayed
4. Download uses yt-dlp's direct stream access for optimal speed
5. FFmpeg merges video/audio if needed

**New platforms are automatically supported** as yt-dlp adds extractors!

---

### Minimum Requirements
- **Flutter**: 3.10.4 or higher
- **Dart**: 3.10.4 or higher
- **Android**: API Level 24 (Android 7.0) or higher
- **Storage**: At least 500MB free space for downloads

### Development Requirements
- Android Studio or VS Code with Flutter extension
- Android SDK Build Tools 34.0.0 or higher
- Gradle 8.0 or higher
- JDK 11 or higher

### Runtime Requirements
- Internet connection for video fetching
- Storage permissions for saving files
- Notification permissions (optional, for download alerts)

---

## 🚀 Installation

### Prerequisites
Ensure you have Flutter installed and configured:

```bash
# Check Flutter installation
flutter --version

# Get Flutter dependencies
flutter pub get

# Accept Android licenses
flutter doctor --android-licenses
```

### Clone the Repository

```bash
git clone https://github.com/yourusername/omni-downloader.git
cd omni-downloader
```

### Setup Development Environment

```bash
# Install Flutter dependencies
flutter pub get

# Generate native build files
flutter pub get

# For Android setup
cd android
./gradlew clean
cd ..
```

### Install on Device/Emulator

```bash
# List connected devices
flutter devices

# Run the app
flutter run

# Run in release mode
flutter run --release

# Run on specific device
flutter run -d <device-id>
```

---

## ⚙️ Configuration

### Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project named "omni-downloader"
   - Add Android app to project

2. **Download Configuration File**
   - Download `google-services.json`
   - Place it in `android/app/` directory

3. **Initialize Firebase**
   - Firebase Crashlytics will be auto-initialized
   - Enable Remote Config in Firebase Console
   - Set up Remote Config parameters (optional)

### Android Configuration

**android/app/build.gradle.kts:**
- Ensure minSdkVersion is 24 or higher
- Check that dependencies are properly aligned

**android/app/AndroidManifest.xml:**
- Required permissions:
  ```xml
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
  ```

### Local Configuration

The app stores preferences in shared_preferences:
- **Save Directory**: User's custom download folder
- **User Preferences**: Stored locally and persisted

---

## 💻 Usage

### Basic Workflow

1. **Launch the App**
   ```bash
   flutter run
   ```

2. **Paste Any URL**
   - Open the app and paste URL from ANY supported platform
   - Works with: YouTube, Instagram, TikTok, Twitter, Facebook, etc.

3. **View Metadata**
   - App displays title, author, thumbnail, duration (if available)
   - Metadata extraction works universally across all platforms

4. **Select Best Format**
   - App lists ALL available video/audio quality combinations
   - Formats vary by platform (e.g., Instagram limits quality more than YouTube)
   - Smart suggestion shows recommended format

5. **Choose Save Location**
   - Use default location or customize
   - Auto-names files based on title and format
   - Default: `/storage/emulated/0/Download/OmniDownloader`

6. **Start Download**
   - Tap the download button
   - Monitor real-time progress (speed, percentage, ETA)
   - Can minimize app - download continues in background

7. **Access Downloaded Files**
   - Files saved to selected directory with proper extensions
   - Auto-converts container format (e.g., mp4 → m4a for audio-only)

### Platform-Specific Examples

**YouTube Video:**
```
https://www.youtube.com/watch?v=dQw4w9WgXcQ
```
→ Download with choices: 4K, 1080p, 720p + separate audio options

**Instagram Reel:**
```
https://www.instagram.com/reel/ABC123XYZ/
```
→ Download without watermark in available quality

**TikTok Video:**
```
https://www.tiktok.com/@username/video/1234567890
```
→ Download without TikTok watermark

**Twitter Video:**
```
https://twitter.com/username/status/1234567890
```
→ Download video or GIF in best quality

**Facebook Video:**
```
https://www.facebook.com/watch/?v=1234567890
```
→ Download with audio if available

### Advanced Features

- **Format Selection**: Choose specific codec combinations (e.g., AV1 video + opus audio)
- **Audio Extraction**: Select audio-only to save as MP3, M4A, or opus
- **Multiple Downloads**: Queue multiple URLs for sequential downloading
- **Background Processing**: FFmpeg processes merge while you use other apps
- **Error Recovery**: Automatic retry on platform rate-limits or connection failures
- **Metadata Caching**: Faster re-downloads from same source

---

## 📁 Project Structure

```
omni-downloader/
├── lib/
│   ├── main.dart                          # App entry point & Firebase init
│   ├── app.dart                           # Root Material App widget
│   ├── firebase_options.dart              # Firebase configuration
│   │
│   ├── models/
│   │   ├── video_metadata.dart            # Video info model (universal)
│   │   └── download_option.dart           # Download format/quality model
│   │
│   ├── screens/
│   │   ├── downloader_screen.dart         # Main UI screen
│   │   └── widgets/
│   │       ├── url_input_card.dart        # URL input (any platform)
│   │       ├── video_info_card.dart       # Metadata display
│   │       ├── stream_list.dart           # Format selection
│   │       ├── download_progress_card.dart# Download progress
│   │       └── save_location_card.dart    # Save folder picker
│   │
│   ├── services/
│   │   ├── ytdlp_service.dart             # yt-dlp wrapper & Chaquopy bridge
│   │   ├── stream_resolver.dart           # Stream format resolution
│   │   ├── chunk_downloader.dart          # Chunked download manager
│   │   ├── foreground_task_handler.dart   # Background task handler
│   │   ├── config_service.dart            # Firebase Remote Config
│   │   └── analytics_service.dart         # Firebase Analytics wrapper
│   │
│   └── utils/
│       └── formatters.dart                # Formatting utilities
│
├── android/
│   ├── app/
│   │   ├── src/
│   │   │   ├── main/
│   │   │   │   └── python/
│   │   │   │       └── ytdlp_bridge.py    # ⭐ Python bridge for yt-dlp
│   │   │   ├── build.gradle.kts
│   │   │   └── google-services.json       # Firebase config (add this)
│   │   └── src/
│   ├── build.gradle.kts
│   └── settings.gradle.kts
│
├── pubspec.yaml                           # Flutter dependencies
├── analysis_options.yaml                  # Linter rules
├── firebase.json                          # Firebase CLI config
├── README.md                              # This file
└── .gitignore                             # Git ignore rules
```

### Core Files Description

| File | Purpose |
|------|---------|
| **ytdlp_service.dart** | Dart wrapper that calls native Python bridge via Method Channels |
| **ytdlp_bridge.py** | Python script that executes yt-dlp commands and relays progress |
| **stream_resolver.dart** | Parses yt-dlp format JSON and creates UI-friendly format list |
| **chunk_downloader.dart** | Manages multi-threaded downloads with resumability |
| **foreground_task_handler.dart** | Android foreground service for background downloads |
| **config_service.dart** | Firebase Remote Config for feature management |
| **analytics_service.dart** | Firebase Analytics event tracking |

### Why This Structure?

- **Separation of Concerns**: UI (Dart), bridge (Kotlin/Python), downloader (yt-dlp)
- **Platform Agnostic**: Service layer handles different video sources
- **Maintainability**: Changes to yt-dlp don't affect Flutter code
- **Reusability**: Services can be extracted for other apps

---

## 🏗️ Architecture

### Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **UI Framework** | Flutter 3.10+ with Material Design 3 | Cross-platform mobile UI |
| **State Management** | StatefulWidget | UI state management |
| **Local Storage** | shared_preferences, path_provider | User preferences & file paths |
| **Video Processing** | FFmpeg Kit Flutter (4.1.0) | Video/audio merging & conversion |
| **Backend** | Firebase | Crashlytics, Analytics, Remote Config |
| **Notifications** | flutter_foreground_task | Foreground download notification & background service |
| **Python Runtime** | Chaquopy | Python interpreter on Android |
| **Downloader Engine** | yt-dlp | Universal video extraction & downloading |
| **Native Bridge** | Method Channels (Dart ↔ Kotlin ↔ Python) | Inter-process communication |

### Data Flow Architecture

```
┌─────────────────────────────────────────────────────┐
│         Flutter UI (Dart)                           │
│  - URL input, format selection, progress display    │
└──────────────┬──────────────────────────────────────┘
               │
               ↓ (Method Channel)
┌─────────────────────────────────────────────────────┐
│    Android Native Layer (Kotlin)                    │
│  - Platform channel communication                   │
│  - File system access                               │
│  - Notification display                             │
└──────────────┬──────────────────────────────────────┘
               │
               ↓ (Chaquopy Bridge)
┌─────────────────────────────────────────────────────┐
│    Python Runtime (Chaquopy)                        │
│  - ytdlp_bridge.py executes yt-dlp                  │
│  - Metadata extraction                              │
│  - Stream resolution & URL generation               │
│  - Progress event relay                             │
└──────────────┬──────────────────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────────────────┐
│    yt-dlp + Dependencies                            │
│  - Auto-detects platform from URL                   │
│  - Extracts metadata (title, author, formats)       │
│  - Generates direct download URLs                   │
│  - Handles platform-specific authentication         │
└──────────────┬──────────────────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────────────────┐
│    Download Manager                                 │
│  - Chunk downloader for reliability                 │
│  - Stream merging logic                             │
│  - Bandwidth management                             │
└──────────────┬──────────────────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────────────────┐
│    FFmpeg Processing                                │
│  - Video/audio merging                              │
│  - Format conversion                                │
│  - Container remuxing                               │
└──────────────┬──────────────────────────────────────┘
               │
               ↓
        [ Saved File ]
```

### Key Services

1. **YtDlpService** (ytdlp_service.dart)
   - Wraps native method channel calls
   - Manages Python runtime communication
   - Executes yt-dlp operations from Dart

2. **StreamResolver** (stream_resolver.dart)
   - Parses yt-dlp's format list response
   - Filters formats by platform capabilities
   - Recommends best quality/codec combinations

3. **ChunkDownloader** (chunk_downloader.dart)
   - Implements resumable downloads
   - Manages bandwidth throttling
   - Handles retry logic for failed chunks

4. **ForegroundTaskHandler** (foreground_task_handler.dart)
   - Runs download task as Android foreground service
   - Updates persistent notification
   - Handles app lifecycle (pause/resume/cancel)

5. **ConfigService** (config_service.dart)
   - Manages Firebase Remote Config
   - Feature flags for experiments
   - Platform-specific behavior tuning

6. **AnalyticsService** (analytics_service.dart)
   - Tracks download events
   - Monitors platform popularity
   - Reports errors via Crashlytics

### Why This Architecture?

- **Universality**: yt-dlp automatically adapts to new platforms
- **Maintainability**: No need to rewrite extractors for each site
- **Reliability**: Proven downloader with 1000+ extractors
- **Performance**: Direct stream URLs bypass rate-limiting
- **Offline**: Python runtime bundled with app - works without yt-dlp server
- **Security**: Runs locally, no external proxies needed

---

## 🏗️ Building

### Debug Build

```bash
# Build debug APK
flutter build apk --debug

# Build and install
flutter install --debug
```

### Release Build

```bash
# Create release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk

# Create release AAB (Google Play)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Build Flavors (Optional)

For development/production variants, configure in `pubspec.yaml`:

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor prod -t lib/main_prod.dart
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Build Fails: "google-services.json not found"
**Solution:**
- Download `google-services.json` from Firebase Console
- Place in `android/app/`
- Run: `flutter clean && flutter pub get && flutter run`

#### 2. Platform Exception: "Python bridge error" or "yt-dlp call failed"
**Solution:**
- Verify Chaquopy is properly initialized in Android build
- Check that Python dependencies (yt-dlp) are bundled
- Ensure Android SDK API level 24+
- Try: `flutter clean && flutter run`

#### 3. "URL Not Supported" Error
**Solution:**
- Verify the platform is on [yt-dlp supported sites list](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md)
- Some platforms may require login (e.g., age-restricted YouTube)
- Update yt-dlp: Update app to latest version for new extractor support
- Check if URL is correct (no typos in domain)

#### 4. Download Stalls or Fails
**Solution:**
- Check internet connection - some platforms are region-blocked
- Verify storage permissions and sufficient disk space
- Try different quality option (some formats are platform-restricted)
- Some platforms limit concurrent downloads - retry after delay
- Check if platform requires VPN or has rate limits

#### 5. "Platform has rate limit" Warning
**Solution:**
- This is normal - platform detected you're downloading
- Wait a few minutes before retrying from same platform
- Try with different URL/format to bypass limits
- Use different network (WiFi vs mobile) if available

#### 6. Firebase Not Initializing
**Solution:**
- Verify Firebase project is created and enabled
- Check `google-services.json` is properly formatted
- Enable required Firebase services (Crashlytics, Analytics)
- Verify `build.gradle` dependencies are aligned

#### 7. Foreground Task Not Running
**Solution:**
- Grant notification permission when prompted
- Check "Disable battery optimization" for Omni Downloader in settings
- Verify `flutter_foreground_task` is initialized in main.dart
- Some ROMs (MIUI, OneUI) need manual whitelist - add app to battery saver whitelist

#### 8. FFmpeg Processing Fails
**Solution:**
- Ensure both video and audio streams downloaded successfully
- FFmpeg requires sufficient storage space
- Check file permissions in save directory
- Try with audio-only format to bypass FFmpeg

### Debug Logs

Enable verbose logging:

```dart
// Add to main.dart
import 'dart:developer' as developer;

void logDebug(String message) {
  developer.log(message, name: 'OmniDownloader');
}
```

### Platform-Specific Troubleshooting

**YouTube:**
- Age-restricted content requires login in yt-dlp config
- Playlist downloads supported - add to URL

**Instagram:**
- Private accounts cannot be downloaded
- Stories expire after 24 hours

**TikTok:**
- Watermark removal works, but some regions block extractors
- Use VPN if TikTok is geo-blocked

**Twitter/X:**
- Requires internet for extraction (login not needed)
- Some videos may be deleted or unavailable

**Facebook:**
- May require login for private/restricted content
- Video quality depends on uploader's settings

---

## 🤝 Contributing

Contributions are welcome! This is a multi-platform downloader, so we accept improvements for any supported service.

### Development Workflow

1. **Fork the Repository**
   ```bash
   git clone https://github.com/yourusername/com.omni.downloader.git
   cd com.omni.downloader
   ```

2. **Create Feature Branch**
   ```bash
   git checkout -b feature/amazing-feature
   # For platform support: feature/improve-instagram-format
   # For UI: feature/dark-mode-toggle
   # For performance: feat/optimize-chunk-download
   ```

3. **Make Changes**
   - Follow Flutter style guide (Effective Dart)
   - For Python changes, test with Chaquopy environment
   - For new platforms: test with 5+ different video sources
   - Add comments for complex logic
   - Run linter: `flutter analyze`

4. **Test Thoroughly**
   ```bash
   flutter test
   flutter run
   # Manual test on real device with different platforms
   ```

5. **Commit with Descriptive Messages**
   ```bash
   git commit -m "feat: add Instagram audio extraction support"
   git commit -m "fix: resolve TikTok format detection issue"
   git commit -m "perf: optimize FFmpeg merge performance"
   ```

6. **Push to Branch**
   ```bash
   git push origin feature/amazing-feature
   ```

7. **Submit Pull Request**
   - Clear title describing changes
   - Platform(s) affected: YouTube, Instagram, TikTok, etc.
   - Test results on different platforms
   - Screenshots if UI changes
   - Reference related issues

### Contribution Ideas

- **New Platform Support**: Add extractors or optimize existing ones
- **UI Improvements**: Better format selection, progress visualization
- **Performance**: Faster downloads, better FFmpeg usage
- **Localization**: Translate UI to multiple languages
- **Testing**: Write tests for different platform scenarios
- **Documentation**: Improve README, API docs, troubleshooting guide

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable names
- Add documentation comments for public APIs
- Keep functions focused and testable
- Max line length: 80 characters for readability

### Platform Testing Checklist

When adding platform support, test with:
- ✅ Public videos (standard case)
- ✅ Private videos (should fail gracefully)
- ✅ Different quality options
- ✅ Audio-only extraction
- ✅ Video + audio merging
- ✅ Different network speeds

### Reporting Bugs

Use GitHub Issues with:
- **Title**: Clear, specific issue (not "app broken")
- **Platform**: Which URL/service caused it (YouTube, Instagram, etc.)
- **Steps**: Exact URL and steps to reproduce
- **Expected**: What should happen
- **Actual**: What actually happened
- **Device**: Phone model, Android version, app version
- **Logs**: Any error messages or Flutter logs
- **Screenshots**: Visual evidence if applicable

### Questions?

- Comment on existing issues
- Create a discussion for ideas
- Join Flutter/yt-dlp communities
- Contact maintainer directly

---

## 💬 Support

### Getting Help

- **Supported Platforms**: Check [yt-dlp supported sites list](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md)
- **Platform Issues**: Search existing GitHub issues first
- **Documentation**: Check [Flutter Docs](https://flutter.dev/docs)
- **Community**: Join Flutter/yt-dlp communities
- **Email**: Contact project maintainer

### Additional Resources

- [Flutter Documentation](https://flutter.dev)
- [yt-dlp Documentation](https://github.com/yt-dlp/yt-dlp) - Core downloader engine
- [yt-dlp Extractors](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md) - Complete platform list
- [Firebase Documentation](https://firebase.google.com/docs)
- [Chaquopy - Python for Android](https://chaquo.com/chaquopy/)
- [FFmpeg Documentation](https://ffmpeg.org/documentation.html)
- [Material Design 3](https://m3.material.io)

### Quick Links

- **Report Bug**: [GitHub Issues](https://github.com/anoymdev/com.omni.downloader/issues)
- **Request Feature**: [GitHub Discussions](https://github.com/anoymdev/com.omni.downloader/discussions)
- **View Changes**: [GitHub Commits](https://github.com/anoymdev/com.omni.downloader/commits)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

MIT License permits:
- ✅ Commercial use
- ✅ Modification
- ✅ Distribution
- ✅ Private use

With conditions:
- ⚠️ License and copyright notice required
- ⚠️ No warranty provided

---

## 👨‍💻 Author & Acknowledgments

**Omni Downloader** is an open-source project built with passion by developers like you.

### Special Credits

This project stands on the shoulders of giants:

- **[yt-dlp](https://github.com/yt-dlp/yt-dlp)** - The universal video downloader with 1000+ platform support
- **[Flutter Team](https://flutter.dev)** - Amazing cross-platform framework
- **[Chaquopy](https://chaquo.com/chaquopy/)** - Python runtime for Android
- **[FFmpeg Kit](https://github.com/tanersener/ffmpeg-kit)** - Powerful video processing
- **[Firebase](https://firebase.google.com)** - Backend services and analytics
- **[Material Design 3](https://m3.material.io)** - Beautiful design system

### Why This Matters

Omni Downloader demonstrates:
- How to integrate Python with Flutter/Android (Chaquopy)
- Cross-platform video downloading architecture
- Firebase + Flutter best practices
- Handling complex native integration

### Get Involved

If you find this project useful:
- ⭐ **Star** the repository to show support
- 🐛 **Report bugs** and suggest features
- 💡 **Contribute** improvements and new platform support
- 📢 **Share** with friends and communities
- 💬 **Discuss** ideas in GitHub Discussions

### Inspired By

- youtube-dl ecosystem
- NewPipe project
- Open-source philosophy

---

## 📞 Contact & Community

- **Report Bugs**: [GitHub Issues](https://github.com/anoymdev/com.omni.downloader/issues)
- **Discussions**: [GitHub Discussions](https://github.com/anoymdev/com.omni.downloader/discussions)
- **View Code**: [GitHub Repository](https://github.com/anoymdev/com.omni.downloader)
- **Supported Platforms**: [yt-dlp Extractors](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md)

### Social & Community

- Join [Flutter Community](https://flutter.dev/community)
- Follow [yt-dlp Project](https://github.com/yt-dlp/yt-dlp)
- Contribute to [Open Source](https://github.com)

---

<div align="center">

**Made with ❤️ using Flutter & Python**

Supporting **1000+ video platforms** worldwide

[⬆ back to top](#omni-downloader)

</div>

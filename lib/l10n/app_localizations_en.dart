// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Omni Downloader';

  @override
  String get videoUrlLabel => 'Video URL';

  @override
  String get videoUrlHint => 'Paste a video link from any platform...';

  @override
  String get fetchingData => 'Fetching Data...';

  @override
  String get fetchInfo => 'Fetch Info';

  @override
  String get saveLocation => 'SAVE LOCATION';

  @override
  String get changeLocation => 'Change';

  @override
  String get selectQuality => 'SELECT QUALITY';

  @override
  String get downloading => 'Downloading...';

  @override
  String get download => 'Download';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateOutdated =>
      'Your app version is outdated. Please update to continue using the app.';

  @override
  String get updateNewVersion =>
      'A new app version is available. Would you like to update now?';

  @override
  String get updateLater => 'Later';

  @override
  String get updateExit => 'Exit';

  @override
  String get updateButton => 'Update';

  @override
  String get downloadSucceeded => 'Download succeeded!';

  @override
  String get failed => 'Failed';

  @override
  String get success => 'Success!';

  @override
  String get preparing => 'Preparing...';

  @override
  String get merging => 'Merging...';

  @override
  String get downloadCompleted => 'Download completed ✓';

  @override
  String get donateTitle => 'Support the Developer';

  @override
  String get donateDesc =>
      'If you find this app useful, consider buying me a coffee to keep this project alive!';

  @override
  String get donateButton => 'Donate via Saweria';

  @override
  String get pleaseEnterUrl => 'Please enter a video URL first.';

  @override
  String get ok => 'OK';

  @override
  String get connectionLost =>
      'Connection lost or too slow.\nCheck your internet connection and try again.';

  @override
  String get noInternet =>
      'No internet connection.\nCheck your WiFi or mobile data.';

  @override
  String get sslError =>
      'Failed to establish a secure connection (SSL).\nCheck your network or try again later.';

  @override
  String get unsupportedUrl =>
      'The URL is unsupported or invalid.\nMake sure your video link is correct.';

  @override
  String get privateVideo =>
      'This video is private or requires login.\nIt cannot be downloaded.';

  @override
  String get copyrightBlocked =>
      'This video is blocked due to copyright.\nIt cannot be downloaded.';

  @override
  String get ageRestricted =>
      'This video is age-restricted and requires login.\nIt cannot be downloaded.';

  @override
  String get mergeFailed =>
      'Failed to merge video and audio.\nTry a different format.';

  @override
  String get storagePermission =>
      'Storage permission is required to select a folder.';

  @override
  String get chooseSaveLocation => 'Choose Save Location';

  @override
  String get folderNotWritable =>
      'Folder is not writable. Please choose another location.';

  @override
  String get saveLocationUpdated => 'Save location updated.';

  @override
  String get downloadingVideo => 'Downloading Video (1/2)...';

  @override
  String get downloadingAudio => 'Downloading Audio (2/2)...';

  @override
  String get mergingVideoAudio => 'Merging Video & Audio...';

  @override
  String get unableToOpenLink => 'Unable to open the link.';

  @override
  String get downloadStarting => 'Starting download...';

  @override
  String get downloadFailed => 'Download Failed';

  @override
  String get downloadCancelled => 'Download Cancelled';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get english => 'English';

  @override
  String get indonesian => 'Indonesian';
}

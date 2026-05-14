import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Omni Downloader'**
  String get appTitle;

  /// No description provided for @videoUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Video URL'**
  String get videoUrlLabel;

  /// No description provided for @videoUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a video link from any platform...'**
  String get videoUrlHint;

  /// No description provided for @fetchingData.
  ///
  /// In en, this message translates to:
  /// **'Fetching Data...'**
  String get fetchingData;

  /// No description provided for @fetchInfo.
  ///
  /// In en, this message translates to:
  /// **'Fetch Info'**
  String get fetchInfo;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'SAVE LOCATION'**
  String get saveLocation;

  /// No description provided for @changeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeLocation;

  /// No description provided for @selectQuality.
  ///
  /// In en, this message translates to:
  /// **'SELECT QUALITY'**
  String get selectQuality;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @updateOutdated.
  ///
  /// In en, this message translates to:
  /// **'Your app version is outdated. Please update to continue using the app.'**
  String get updateOutdated;

  /// No description provided for @updateNewVersion.
  ///
  /// In en, this message translates to:
  /// **'A new app version is available. Would you like to update now?'**
  String get updateNewVersion;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get updateExit;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// No description provided for @downloadSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Download succeeded!'**
  String get downloadSucceeded;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get preparing;

  /// No description provided for @merging.
  ///
  /// In en, this message translates to:
  /// **'Merging...'**
  String get merging;

  /// No description provided for @downloadCompleted.
  ///
  /// In en, this message translates to:
  /// **'Download completed ✓'**
  String get downloadCompleted;

  /// No description provided for @donateTitle.
  ///
  /// In en, this message translates to:
  /// **'Support the Developer'**
  String get donateTitle;

  /// No description provided for @donateDesc.
  ///
  /// In en, this message translates to:
  /// **'If you find this app useful, consider buying me a coffee to keep this project alive!'**
  String get donateDesc;

  /// No description provided for @donateButton.
  ///
  /// In en, this message translates to:
  /// **'Donate via Saweria'**
  String get donateButton;

  /// No description provided for @pleaseEnterUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a video URL first.'**
  String get pleaseEnterUrl;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @connectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection lost or too slow.\nCheck your internet connection and try again.'**
  String get connectionLost;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.\nCheck your WiFi or mobile data.'**
  String get noInternet;

  /// No description provided for @sslError.
  ///
  /// In en, this message translates to:
  /// **'Failed to establish a secure connection (SSL).\nCheck your network or try again later.'**
  String get sslError;

  /// No description provided for @unsupportedUrl.
  ///
  /// In en, this message translates to:
  /// **'The URL is unsupported or invalid.\nMake sure your video link is correct.'**
  String get unsupportedUrl;

  /// No description provided for @privateVideo.
  ///
  /// In en, this message translates to:
  /// **'This video is private or requires login.\nIt cannot be downloaded.'**
  String get privateVideo;

  /// No description provided for @copyrightBlocked.
  ///
  /// In en, this message translates to:
  /// **'This video is blocked due to copyright.\nIt cannot be downloaded.'**
  String get copyrightBlocked;

  /// No description provided for @ageRestricted.
  ///
  /// In en, this message translates to:
  /// **'This video is age-restricted and requires login.\nIt cannot be downloaded.'**
  String get ageRestricted;

  /// No description provided for @mergeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to merge video and audio.\nTry a different format.'**
  String get mergeFailed;

  /// No description provided for @storagePermission.
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required to select a folder.'**
  String get storagePermission;

  /// No description provided for @chooseSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose Save Location'**
  String get chooseSaveLocation;

  /// No description provided for @folderNotWritable.
  ///
  /// In en, this message translates to:
  /// **'Folder is not writable. Please choose another location.'**
  String get folderNotWritable;

  /// No description provided for @saveLocationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Save location updated.'**
  String get saveLocationUpdated;

  /// No description provided for @downloadingVideo.
  ///
  /// In en, this message translates to:
  /// **'Downloading Video (1/2)...'**
  String get downloadingVideo;

  /// No description provided for @downloadingAudio.
  ///
  /// In en, this message translates to:
  /// **'Downloading Audio (2/2)...'**
  String get downloadingAudio;

  /// No description provided for @mergingVideoAudio.
  ///
  /// In en, this message translates to:
  /// **'Merging Video & Audio...'**
  String get mergingVideoAudio;

  /// No description provided for @unableToOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the link.'**
  String get unableToOpenLink;

  /// No description provided for @downloadStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting download...'**
  String get downloadStarting;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download Failed'**
  String get downloadFailed;

  /// No description provided for @downloadCancelled.
  ///
  /// In en, this message translates to:
  /// **'Download Cancelled'**
  String get downloadCancelled;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerIntro.
  ///
  /// In en, this message translates to:
  /// **'Omni Downloader is intended exclusively for:'**
  String get disclaimerIntro;

  /// No description provided for @disclaimerPoint1.
  ///
  /// In en, this message translates to:
  /// **'Downloading your own content'**
  String get disclaimerPoint1;

  /// No description provided for @disclaimerPoint2.
  ///
  /// In en, this message translates to:
  /// **'Backing up your uploaded videos'**
  String get disclaimerPoint2;

  /// No description provided for @disclaimerPoint3.
  ///
  /// In en, this message translates to:
  /// **'Creative Commons / Public Domain content'**
  String get disclaimerPoint3;

  /// No description provided for @disclaimerPoint4.
  ///
  /// In en, this message translates to:
  /// **'Personal & offline use'**
  String get disclaimerPoint4;

  /// No description provided for @disclaimerWarning.
  ///
  /// In en, this message translates to:
  /// **'It is strictly prohibited to use this app to redistribute, commercialize, or download content you do not own without the copyright owner\'s permission.'**
  String get disclaimerWarning;

  /// No description provided for @disclaimerResponsibility.
  ///
  /// In en, this message translates to:
  /// **'The user takes full responsibility for the use of this app.'**
  String get disclaimerResponsibility;

  /// No description provided for @disclaimerAccept.
  ///
  /// In en, this message translates to:
  /// **'I Understand & Agree'**
  String get disclaimerAccept;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Transparency'**
  String get privacyTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'This page explains what app services are used and what is not collected.'**
  String get privacyIntro;

  /// No description provided for @privacyAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Firebase Analytics is used for basic usage analytics, such as feature use and app health signals.'**
  String get privacyAnalytics;

  /// No description provided for @privacyCrashlytics.
  ///
  /// In en, this message translates to:
  /// **'Firebase Crashlytics is used for crash reports so we can diagnose stability problems.'**
  String get privacyCrashlytics;

  /// No description provided for @privacyRemoteConfig.
  ///
  /// In en, this message translates to:
  /// **'Firebase Remote Config is used for update checks and app configuration.'**
  String get privacyRemoteConfig;

  /// No description provided for @privacyRemoteConfigLimits.
  ///
  /// In en, this message translates to:
  /// **'Remote Config is not used to bypass user consent, hide behavior, or download executable code.'**
  String get privacyRemoteConfigLimits;

  /// No description provided for @privacyNoContent.
  ///
  /// In en, this message translates to:
  /// **'The app does not collect downloaded files, media content, or raw video URLs.'**
  String get privacyNoContent;

  /// No description provided for @privacyNoUpload.
  ///
  /// In en, this message translates to:
  /// **'The app does not upload user-downloaded media to our server.'**
  String get privacyNoUpload;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyBody.
  ///
  /// In en, this message translates to:
  /// **'Omni Downloader processes video links on your device to fetch metadata and download selected media. Basic analytics and crash reporting are enabled by default to improve reliability, and you can turn them off below. Remote Config may provide update/version settings, but it is not used to add hidden behavior or executable code. Downloaded files and media content stay on your device unless you choose to share them outside this app.'**
  String get privacyPolicyBody;

  /// No description provided for @analyticsCrashToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics and crash reporting'**
  String get analyticsCrashToggleTitle;

  /// No description provided for @analyticsCrashToggleDesc.
  ///
  /// In en, this message translates to:
  /// **'Enabled by default. Turn this off to stop Firebase Analytics and Crashlytics collection on this device.'**
  String get analyticsCrashToggleDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

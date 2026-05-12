import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum AppVersionType {
  expired,
  haveUpdate,
  upToDate,
}

class ConfigData {
  ConfigData._();

  static final remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    try {
      await remoteConfig.setDefaults(const {
        'appName': 'Omni Downloader',
        'maxVersion': 1,
        'minVersion': 1,
        'updateUrl': 'https://github.com/anoymdev/com.omni.downloader/releases/latest',
      });

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: const Duration(minutes: 1),
      ));

      await remoteConfig.fetchAndActivate();
    } catch (e) {
      log('Remote config init error: $e');
    }
  }

  static String getValue(String key) {
    return remoteConfig.getValue(key).asString();
  }

  static Future<AppVersionType> checkUpdate() async {
    try {
      final maxVersion = remoteConfig.getInt('maxVersion');
      final minVersion = remoteConfig.getInt('minVersion');

      final packageInfo = await PackageInfo.fromPlatform();

      // buildNumber string usually maps to the integer version code
      final nowVersion = int.tryParse(packageInfo.buildNumber) ?? 1;

      log('''
        NOW VERSION : $nowVersion
        MIN VERSION : $minVersion
        MAX VERSION : $maxVersion
      ''', name: 'VERSION APP');

      if (nowVersion < minVersion) {
        return AppVersionType.expired;
      } else if (nowVersion < maxVersion) {
        return AppVersionType.haveUpdate;
      } else {
        return AppVersionType.upToDate;
      }
    } catch (e) {
      log('Check update error: $e');
      return AppVersionType.upToDate; // default to upToDate on error
    }
  }
}

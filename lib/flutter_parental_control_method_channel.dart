import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_parental_control_platform_interface.dart';

class MethodChannelFlutterParentalControl
    extends FlutterParentalControlPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_parental_control_method');

  @visibleForTesting
  final eventChannel = const EventChannel('flutter_parental_control_event');

  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final result = await methodChannel.invokeMethod('getDeviceInfoMethod');
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<List<Map<String, dynamic>>> getAppUsageInfo() async {
    final List<dynamic> data =
        await methodChannel.invokeMethod('getAppUsageInfoMethod');
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<void> setListAppBlocked(List<String> listApp) async {
    await methodChannel.invokeMethod('blockAppMethod', {'blockApps': listApp});
  }

  @override
  Future<void> setListWebBlocked(List<String> listWeb) async {
    await methodChannel
        .invokeMethod('blockWebsiteMethod', {'blockWebsites': listWeb});
  }

  @override
  Future<void> startService() async {
    await methodChannel.invokeMethod('startServiceMethod');
  }

  @override
  Stream<Map<String, dynamic>> listenAppInstalled() {
    return eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event));
  }

  @override
  Future<void> checkParentControlPermission() async {
    await methodChannel.invokeMethod('checkPermissionMethod');
  }

  @override
  Future<void> scheduleMonitorSettings(bool isMonitoring, int startHour,
      int startMinute, int endHour, int endMinute) async {
    final Map<String, dynamic> args = {
      'isMonitoring': isMonitoring,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
    };
    await methodChannel.invokeMethod('toggleMonitoring', args);
  }

  @override
  Future<void> limitedApp() async {
    await methodChannel.invokeMethod('limitAppMethod');
  }

  @override
  Future<void> settingMonitor({
    bool? requireAutomaticDateAndTime,
    bool? lockAccounts,
    bool? lockPasscode,
    bool? denySiri,
    bool? lockAppCellularData,
    bool? lockESIM,
    bool? denyInAppPurchases,
    int? maximumRating,
    bool? requirePasswordForPurchases,
    bool? denyExplicitContent,
    bool? denyMusicService,
    bool? denyBookstoreErotica,
    int? maximumMovieRating,
    int? maximumTVShowRating,
    bool? denyMultiplayerGaming,
    bool? denyAddingFriends,
  }) async {
    final settings = <String, dynamic>{
      'requireAutomaticDateAndTime': requireAutomaticDateAndTime,
      'lockAccounts': lockAccounts,
      'lockPasscode': lockPasscode,
      'denySiri': denySiri,
      'lockAppCellularData': lockAppCellularData,
      'lockESIM': lockESIM,
      'denyInAppPurchases': denyInAppPurchases,
      'maximumRating': maximumRating,
      'requirePasswordForPurchases': requirePasswordForPurchases,
      'denyExplicitContent': denyExplicitContent,
      'denyMusicService': denyMusicService,
      'denyBookstoreErotica': denyBookstoreErotica,
      'maximumMovieRating': maximumMovieRating,
      'maximumTVShowRating': maximumTVShowRating,
      'denyMultiplayerGaming': denyMultiplayerGaming,
      'denyAddingFriends': denyAddingFriends,
    };

    // Gọi method channel với Map vừa tạo
    await methodChannel.invokeMethod('settingMonitorMethod', settings);
  }
}

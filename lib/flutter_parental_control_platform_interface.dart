import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_parental_control_method_channel.dart';

abstract class FlutterParentalControlPlatform extends PlatformInterface {
  FlutterParentalControlPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterParentalControlPlatform _instance =
      MethodChannelFlutterParentalControl();

  static FlutterParentalControlPlatform get instance => _instance;

  static set instance(FlutterParentalControlPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, dynamic>> getDeviceInfo() {
    throw UnimplementedError('getDeviceInfo() has not been implemented.');
  }

  Future<List<Map<String, dynamic>>> getAppUsageInfo() {
    throw UnimplementedError('getAppUsageInfo() has not been implemented.');
  }

  Future<void> setListAppBlocked(List<String> listApp) {
    throw UnimplementedError('setListAppBlocked() has not been implemented.');
  }

  Future<void> setListWebBlocked(List<String> listWeb) {
    throw UnimplementedError('setListWebBlocked() has not been implemented.');
  }

  Future<void> startService() {
    throw UnimplementedError('startService() has not been implemented.');
  }

  Stream<Map<String, dynamic>> listenAppInstalled() {
    throw UnimplementedError('listenAppInstalled() has not been implemented.');
  }

  /// các phần chỉ dùng được trên [Ios]
  Future<void> checkParentControlPermission() {
    throw UnimplementedError(
        'checkParentControlPermission() has not been implemented.');
  }

  Future<void> scheduleMonitorSettings(bool isMonitoring, int startHour,
      int startMinute, int endHour, int endMinute) {
    throw UnimplementedError(
        'scheduleMonitorSettings() has not been implemented.');
  }

  Future<void> limitedApp() {
    throw UnimplementedError('limitedApp() has not been implemented.');
  }

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
  }) {
    throw UnimplementedError('settingMonitor() has not been implemented.');
  }
}

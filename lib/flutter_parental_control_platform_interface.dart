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

  /// Các phần hiện tại đang chỉ hỗ trợ cho [Android]
  Future<bool> requestPermission(int type) {
    throw UnimplementedError('requestPermission() has not been implemented.');
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

  Future<void> askParent() {
    throw 'askParent() has not been implemented.';
  }

  Stream<Map<String, dynamic>> listenAppInstalled() {
    throw UnimplementedError('listenAppInstalled() has not been implemented.');
  }

  Future<List<Map<String, dynamic>>> getWebHistory() {
    throw UnimplementedError('getWebHistory() has not been implemented.');
  }

  Future<void> setOverlayView(bool id, String overlayView,
      {String? backBtnId, String? askParentBtnId}) {
    throw UnimplementedError('setOverlayView() has not been implemented.');
  }

  /// Các phần chỉ dùng được trên [Ios]
  /// Hàm kiểm tra quyền kiểm soát của phụ huynh
  Future<void> checkParentControlPermission() {
    throw UnimplementedError(
        'checkParentControlPermission() has not been implemented.');
  }

  /// Thiết lập thời gian giám sát thiết bị
  Future<void> scheduleMonitorSettings(bool isMonitoring,
      {int? startHour, int? startMinute, int? endHour, int? endMinute}) {
    throw UnimplementedError(
        'scheduleMonitorSettings() has not been implemented.');
  }

  /// Giới hạn ứng dụng
  Future<void> limitedApp() {
    throw UnimplementedError('limitedApp() has not been implemented.');
  }

  /// Cài đặt giám sát thiết bị
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

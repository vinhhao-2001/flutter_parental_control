library parental_control;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../core/app_constants.dart';
import 'flutter_parental_control_platform_interface.dart';

class MethodChannelFlutterParentalControl
    extends FlutterParentalControlPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(AppConstants.methodChannel);

  /// Event channel
  @visibleForTesting
  final eventChannel = const EventChannel(AppConstants.eventChannel);

  /// Lấy các thông tin thiết bị
  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final result = await methodChannel.invokeMethod(AppConstants.deviceMethod);
    return Map<String, dynamic>.from(result);
  }

  /// Lấy danh sách chứa thông tin các ứng dụng
  @override
  Future<List<Map<String, dynamic>>> getAppDetailInfo() async {
    final List<dynamic> data =
        await methodChannel.invokeMethod(AppConstants.appDetailMethod);
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Lấy thời gian sử dụng của thiết bị
  @override
  Future<int> getDeviceUsage() async {
    final data =
        await methodChannel.invokeMethod(AppConstants.deviceUsageMethod);
    return data;
  }

  /// Lấy thông tin vị trí của thiết bị
  @override
  Future<Map<String, dynamic>> getLocation() async {
    final result =
        await methodChannel.invokeMethod(AppConstants.locationMethod);
    return Map<String, dynamic>.from(result);
  }

  /// Yêu cầu các quyền dành cho [Android]
  @override
  Future<bool> requestPermission(int type) async {
    final result = await methodChannel.invokeMethod(
        AppConstants.permissionMethod, {AppConstants.typePermission: type});
    return result ?? false;
  }

  /// Sự kiện hỏi ý kiến của phụ huynh
  @override
  Future<void> askParent(Function function) async {
    methodChannel.setMethodCallHandler((MethodCall call) async {
      if (call.method == AppConstants.askParentMethod) () => function;
    });
  }

  /// Lấy thông tin thời gian sử dụng các ứng dụng
  @override
  Future<Map<String, dynamic>> getAppUsageInfo({day}) async {
    final result = await methodChannel
        .invokeMethod(AppConstants.appUsageMethod, {AppConstants.day: day});
    return Map<String, dynamic>.from(result);
  }

  /// Tạo danh sách các ứng dụng bị chặn
  @override
  Future<void> setListAppBlocked(List<Map<String, dynamic>> listApp) async {
    await methodChannel.invokeMethod(
        AppConstants.blockAppMethod, {AppConstants.blockApps: listApp});
  }

  /// Tạo danh sách các trang web bị chặn
  @override
  Future<void> setListWebBlocked(List<String> listWeb) async {
    await methodChannel.invokeMethod(
        AppConstants.blockWebMethod, {AppConstants.blockWeb: listWeb});
  }

  /// Khởi động dịch vụ lắng nghe ứng dụng gỡ bỏ hoặc cài đặt
  @override
  Future<void> startService() async {
    await methodChannel.invokeMethod(AppConstants.startServiceMethod);
  }

  /// Lắng nghe ứng dụng gỡ bỏ hoặc cài đặt
  @override
  Stream<Map<String, dynamic>> listenAppInstalled() {
    return eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event));
  }

  @override
  Future<List<Map<String, dynamic>>> getWebHistory() async {
    final List<dynamic> data =
        await methodChannel.invokeMethod(AppConstants.getWebHistory);
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<void> setOverlayView(bool id, String overlayView,
      {String? backBtnId, String? askParentBtnId}) async {
    await methodChannel.invokeMethod(AppConstants.overlayMethod, {
      AppConstants.id: id,
      AppConstants.overlayView: overlayView,
      AppConstants.backBtn: backBtnId,
      AppConstants.askParentBtn: askParentBtnId,
    });
  }

  /// các sự kiện trên [ios]
  /// Kiểm tra quyền kiểm soát của phụ huynh
  @override
  Future<void> checkParentControlPermission() async {
    await methodChannel.invokeMethod(AppConstants.permissionMethod);
  }

  /// Thiết lập thời gian giới hạn trên thiết bị ios
  @override
  Future<void> scheduleMonitorSettings(bool isMonitoring,
      {int? startHour, int? startMinute, int? endHour, int? endMinute}) async {
    final Map<String, dynamic> args = {
      AppConstants.isMonitoring: isMonitoring,
      AppConstants.startHour: startHour,
      AppConstants.startMinute: startMinute,
      AppConstants.endHour: endHour,
      AppConstants.endMinute: endMinute,
    };
    await methodChannel.invokeMethod(AppConstants.scheduleMethod, args);
  }

  /// Giới hạn các ứng dụng trên thiết bị ios
  @override
  Future<void> limitedApp() async {
    await methodChannel.invokeMethod(AppConstants.limitAppMethod);
  }

  /// Cài đặt giám sát thiết bị ios
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
      AppConstants.requireAutoTime: requireAutomaticDateAndTime,
      AppConstants.lockAccounts: lockAccounts,
      AppConstants.lockPasscode: lockPasscode,
      AppConstants.denySiri: denySiri,
      AppConstants.lockAppCellularData: lockAppCellularData,
      AppConstants.lockESIM: lockESIM,
      AppConstants.denyInAppPurchases: denyInAppPurchases,
      AppConstants.maximumRating: maximumRating,
      AppConstants.requirePasswordForPurchases: requirePasswordForPurchases,
      AppConstants.denyExplicitContent: denyExplicitContent,
      AppConstants.denyMusicService: denyMusicService,
      AppConstants.denyBookstoreErotica: denyBookstoreErotica,
      AppConstants.maximumMovieRating: maximumMovieRating,
      AppConstants.maximumTVShowRating: maximumTVShowRating,
      AppConstants.denyMultiplayerGaming: denyMultiplayerGaming,
      AppConstants.denyAddingFriends: denyAddingFriends,
    };

    // Gọi method channel với Map vừa tạo
    await methodChannel.invokeMethod(
        AppConstants.settingMonitorMethod, settings);
  }
}
import 'dart:convert';
import 'dart:typed_data';
import 'constants/app_constants.dart';
import 'flutter_parental_control_platform_interface.dart';

part 'model/app_usage_info.dart';
part 'model/device_info.dart';
part 'model/app_installed_info.dart';
part 'model/web_history.dart';

class ParentalControl {
  /// Lấy thông tin thiết bị, có sự khác nhau giữa Android và Ios
  static Future<DeviceInfo> getDeviceInfo() async {
    final data = await FlutterParentalControlPlatform.instance.getDeviceInfo();
    return DeviceInfo.fromMap(data);
  }

  /// các phần chỉ dùng được trên [Android]
  /// Lắng nghe khi có có sự kiện nhấn nút hỏi phụ huynh
  /// [askParent] Bị mất kết nối khi chạy ở nền
  static Future<void> askParent() async {
    await FlutterParentalControlPlatform.instance.askParent();
  }

  /// Kiểm tra các quyền trợ năng
  static Future<bool> requestPermission(Permission type) async {
    final result = await FlutterParentalControlPlatform.instance
        .requestPermission(permissionInt(type));
    return result;
  }

  /// Lấy thời gian sử dụng trong thiết bị
  static Future<List<AppUsageInfo>> getAppUsageInfo() async {
    final data =
        await FlutterParentalControlPlatform.instance.getAppUsageInfo();
    return data.map((app) => AppUsageInfo.fromMap(app)).toList();
  }

  /// Thiết lập danh sách ứng dụng bị giới hạn
  static Future<void> setListAppBlocked(List<String> listApp) async {
    await FlutterParentalControlPlatform.instance.setListAppBlocked(listApp);
  }

  /// Thiết lập danh sách nội dung web bị giới hạn
  static Future<void> setListWebBlocked(List<String> listWeb) async {
    await FlutterParentalControlPlatform.instance.setListWebBlocked(listWeb);
  }

  /// Khởi chạy dịch vụ lắng nghe ứng dụng được cài đặt hoặc gỡ bỏ
  static Future<void> startService() async {
    await FlutterParentalControlPlatform.instance.startService();
  }

  /// Lắng nghe và lấy thông tin ứng dụng bị cài đặt hoặc gỡ bỏ
  static Stream<AppInstalledInfo> listenAppInstalledInfo() {
    final result = FlutterParentalControlPlatform.instance.listenAppInstalled();
    return result.map((data) => AppInstalledInfo.map(data));
  }

  /// Lấy lịch sử duyệt web trên trình duyệt
  static Future<List<WebHistory>> getWebHistory() async {
    final result =
        await FlutterParentalControlPlatform.instance.getWebHistory();
    return result.map((app) => WebHistory.fromMap(app)).toList();
  }

  /// các phần chỉ dùng được trên [Ios]
  /// Kiểm tra quyền kiểm soát của phụ huynh
  static Future<void> checkPermission() async {
    try {
      FlutterParentalControlPlatform.instance.checkParentControlPermission();
    } catch (e) {
      rethrow;
    }
  }

  /// Lập lịch thời gian giám sát thiết bị
  static Future<void> scheduleMonitorSettings(bool isMonitoring, int startHour,
      int startMinute, int endHour, int endMinute) async {
    FlutterParentalControlPlatform.instance.scheduleMonitorSettings(
        isMonitoring, startHour, startMinute, endHour, endMinute);
  }

  /// Mở giao diện chọn danh sách ứng dụng bị giới hạn
  static Future<void> limitedApp() async {
    FlutterParentalControlPlatform.instance.limitedApp();
  }

  /// Cài đặt thiết bị
  static Future<void> settingMonitor({
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
    FlutterParentalControlPlatform.instance.settingMonitor(
      requireAutomaticDateAndTime: requireAutomaticDateAndTime,
      lockAccounts: lockAccounts,
      lockPasscode: lockPasscode,
      denySiri: denySiri,
      lockAppCellularData: lockAppCellularData,
      lockESIM: lockESIM,
      denyInAppPurchases: denyInAppPurchases,
      maximumRating: maximumRating,
      requirePasswordForPurchases: requireAutomaticDateAndTime,
      denyExplicitContent: denyExplicitContent,
      denyBookstoreErotica: denyBookstoreErotica,
      maximumMovieRating: maximumMovieRating,
      maximumTVShowRating: maximumTVShowRating,
      denyMultiplayerGaming: denyMultiplayerGaming,
      denyAddingFriends: denyAddingFriends,
    );
  }
}

///  Tạo enum cho các trường hợp xin quyền trên [Android]
int permissionInt(Permission type) {
  switch (type) {
    case Permission.accessibility:
      return 1;
    case Permission.overlay:
      return 2;
    case Permission.usageState:
      return 3;
    case Permission.location:
      return 4;
  }
}

enum Permission { accessibility, overlay, usageState, location }

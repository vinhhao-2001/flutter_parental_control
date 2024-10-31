import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_parental_control/core/app_constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'flutter_parental_control_platform_interface.dart';

part 'model/app_usage_info.dart';
part 'model/device_info.dart';
part 'model/app_detail.dart';
part 'model/app_installed_info.dart';
part 'model/web_history.dart';
part 'model/app_block.dart';
part 'model/schedule.dart';
part 'model/monitor_setting.dart';

class ParentalControl {
  /// Lấy thông tin thiết bị, có sự khác nhau giữa Android và Ios
  static Future<DeviceInfo> getDeviceInfo() async {
    try {
      final data =
          await FlutterParentalControlPlatform.instance.getDeviceInfo();
      return DeviceInfo.fromMap(data);
    } catch (_) {
      rethrow;
    }
  }

  /// Lấy vị trí của trẻ
  static Future<Position> getLocation() async {
    try {
      final locationPermission = await _locationPermission();
      if (locationPermission) {
        return await Geolocator.getCurrentPosition(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.best));
      } else {
        throw AppConstants.locationError;
      }
    } catch (_) {
      rethrow;
    }
  }

  /// Hàm kiểm tra trẻ có trong phạm vi an toàn không
  Future<bool> checkChildLocation(
      LatLng childLocation, List<LatLng> polygonPoints) async {
    if (polygonPoints.length < 3) throw 'Vùng an toàn phải có 3 điểm trở lên';
    int intersections = 0;

    /// Kiểm tra xem điểm có nằm trong vùng an toàn không
    /// Dùng thuật toán Ray-casting để kiểm tra
    for (int i = 0; i < polygonPoints.length; i++) {
      var p1 = polygonPoints[i],
          p2 = polygonPoints[(i + 1) % polygonPoints.length];
      if (((p1.latitude <= childLocation.latitude &&
                  childLocation.latitude < p2.latitude) ||
              (p2.latitude <= childLocation.latitude &&
                  childLocation.latitude < p1.latitude)) &&
          (childLocation.longitude <
              (p2.longitude - p1.longitude) *
                      (childLocation.latitude - p1.latitude) /
                      (p2.latitude - p1.latitude) +
                  p1.longitude)) {
        intersections++;
      }
    }

    return intersections.isOdd;
  }

  /// các phần chỉ dùng được trên [Android]
  /// Lắng nghe khi có có sự kiện nhấn nút hỏi phụ huynh
  /// [askParent] Bị mất kết nối khi chạy ở nền
  static Future<void> askParent(Function function) async {
    try {
      _checkPlatform(false);
      await FlutterParentalControlPlatform.instance.askParent(function);
    } catch (_) {
      rethrow;
    }
  }

  /// Lấy danh sách chứa thông tin của các ứng dụng
  static Future<List<AppDetail>> getListAppDetail() async {
    try {
      _checkPlatform(false);
      final result =
          await FlutterParentalControlPlatform.instance.getAppDetailInfo();
      return result.map((app) => AppDetail.fromMap(app)).toList();
    } catch (_) {
      rethrow;
    }
  }

  /// Kiểm tra các quyền trợ năng
  static Future<bool> requestPermission(Permission type) async {
    try {
      _checkPlatform(false);
      final result = await FlutterParentalControlPlatform.instance
          .requestPermission(_permissionInt(type));
      return result;
    } catch (_) {
      rethrow;
    }
  }

  /// Lấy thời gian sử dụng trong thiết bị
  static Future<List<AppUsageInfo>> getAppUsageInfo() async {
    try {
      _checkPlatform(false);
      final data =
          await FlutterParentalControlPlatform.instance.getAppUsageInfo();
      List<AppUsageInfo> listApp = data.entries.map((entry) {
        String packageName = entry.key;
        Map<int, int> usageMap = Map<int, int>.from(entry.value);
        List<DailyUsage> usageTime = usageMap.entries.map((usageEntry) {
          return DailyUsage(date: usageEntry.key, timeUsed: usageEntry.value);
        }).toList();

        return AppUsageInfo(packageName: packageName, usageTime: usageTime);
      }).toList();
      return listApp;
    } catch (_) {
      rethrow;
    }
  }

  /// Thiết lập danh sách ứng dụng bị giới hạn
  static Future<void> setListAppBlocked(List<AppBlock> listApp) async {
    try {
      _checkPlatform(false);
      final listAppBlock = listApp.map((app) => app.toMap()).toList();
      await FlutterParentalControlPlatform.instance
          .setListAppBlocked(listAppBlock);
    } catch (_) {
      rethrow;
    }
  }

  /// Thiết lập danh sách nội dung web bị giới hạn
  static Future<void> setListWebBlocked(List<String> listWeb) async {
    try {
      _checkPlatform(false);
      await FlutterParentalControlPlatform.instance.setListWebBlocked(listWeb);
    } catch (_) {
      rethrow;
    }
  }

  /// Khởi chạy dịch vụ lắng nghe ứng dụng được cài đặt hoặc gỡ bỏ
  static Future<void> startService() async {
    try {
      _checkPlatform(false);
      await FlutterParentalControlPlatform.instance.startService();
    } catch (_) {
      rethrow;
    }
  }

  /// Lắng nghe và lấy thông tin ứng dụng bị cài đặt hoặc gỡ bỏ
  static Stream<AppInstalledInfo> listenAppInstalledInfo() {
    try {
      _checkPlatform(false);
      final result =
          FlutterParentalControlPlatform.instance.listenAppInstalled();
      return result.map((data) => AppInstalledInfo.fromMap(data));
    } catch (_) {
      rethrow;
    }
  }

  /// Lấy lịch sử duyệt web trên trình duyệt
  static Future<List<WebHistory>> getWebHistory() async {
    try {
      _checkPlatform(false);
      final result =
          await FlutterParentalControlPlatform.instance.getWebHistory();
      return result.map((app) => WebHistory.fromMap(app)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Thiết view của người dùng plugin cho ứng dụng đó
  /// Sử dụng khi ứng dụng được khởi tạo hoặc trước khi bật dịch vụ trợ năng
  static Future<void> setOverlayView(bool id, String overlayView,
      {String? backBtnId, String? askParentBtnId}) async {
    try {
      _checkPlatform(false);
      await FlutterParentalControlPlatform.instance.setOverlayView(
        id,
        overlayView,
        backBtnId: backBtnId,
        askParentBtnId: askParentBtnId,
      );
    } catch (_) {
      rethrow;
    }
  }

  /// các phần chỉ dùng được trên [Ios]
  /// Kiểm tra quyền kiểm soát của phụ huynh
  static Future<void> parentalControlPermission() async {
    try {
      _checkPlatform(true);
      FlutterParentalControlPlatform.instance.checkParentControlPermission();
    } catch (e) {
      rethrow;
    }
  }

  /// Lập lịch thời gian giám sát thiết bị
  static Future<void> scheduleMonitorSettings(Schedule schedule) async {
    try {
      _checkPlatform(true);
      await FlutterParentalControlPlatform.instance.scheduleMonitorSettings(
          schedule.isMonitoring,
          startHour: schedule.startHour,
          startMinute: schedule.startMinute,
          endHour: schedule.endHour,
          endMinute: schedule.endMinute);
    } catch (_) {
      rethrow;
    }
  }

  /// Mở giao diện chọn danh sách ứng dụng bị giới hạn
  static Future<void> limitedApp() async {
    try {
      _checkPlatform(true);
      await FlutterParentalControlPlatform.instance.limitedApp();
    } catch (_) {
      rethrow;
    }
  }

  /// Cài đặt thiết bị
  static Future<void> settingMonitor(MonitorSetting monitorSettings) async {
    try {
      _checkPlatform(true);
      FlutterParentalControlPlatform.instance.settingMonitor(
        requireAutomaticDateAndTime:
            monitorSettings.requireAutomaticDateAndTime,
        lockAccounts: monitorSettings.lockAccounts,
        lockPasscode: monitorSettings.lockPasscode,
        denySiri: monitorSettings.denySiri,
        lockAppCellularData: monitorSettings.lockAppCellularData,
        lockESIM: monitorSettings.lockESIM,
        denyInAppPurchases: monitorSettings.denyInAppPurchases,
        maximumRating: monitorSettings.maximumRating,
        requirePasswordForPurchases:
            monitorSettings.requireAutomaticDateAndTime,
        denyExplicitContent: monitorSettings.denyExplicitContent,
        denyBookstoreErotica: monitorSettings.denyBookstoreErotica,
        maximumMovieRating: monitorSettings.maximumMovieRating,
        maximumTVShowRating: monitorSettings.maximumTVShowRating,
        denyMultiplayerGaming: monitorSettings.denyMultiplayerGaming,
        denyAddingFriends: monitorSettings.denyAddingFriends,
      );
    } catch (_) {
      rethrow;
    }
  }

  /// Các hàm chỉ dùng trong [plugin]
  /// Hàm kiểm tra xem platform có phải ios hoặc android không
  static void _checkPlatform(bool isIos) {
    if ((isIos && !Platform.isIOS) || (!isIos && !Platform.isAndroid)) {
      throw isIos
          ? AppConstants.iosPlatformError
          : AppConstants.androidPlatformError;
    }
  }

  /// Các trường hợp xin quyền trong native Android
  static int _permissionInt(Permission type) {
    switch (type) {
      case Permission.accessibility:
        return 1;
      case Permission.overlay:
        return 2;
      case Permission.usageState:
        return 3;
    }
  }

  /// Hàm kiểm tra quyền truy cập vị trí
  static Future<bool> _locationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }
    return false;
  }
}

///  Tạo enum cho các trường hợp xin quyền trên [Android]
enum Permission {
  accessibility,
  overlay,
  usageState,
}

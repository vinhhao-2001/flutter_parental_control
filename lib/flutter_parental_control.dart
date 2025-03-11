library parental_control;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_parental_control/src/channel/flutter_parental_control_platform_interface.dart';
import 'package:flutter_parental_control/src/core/app_constants.dart';

part 'src/model/app_block.dart';
part 'src/model/app_detail.dart';
part 'src/model/app_installed_info.dart';
part 'src/model/app_usage.dart';
part 'src/model/device_info.dart';
part 'src/model/monitor_setting.dart';
part 'src/model/schedule.dart';
part 'src/model/time_usage_for_app.dart';
part 'src/model/web_history.dart';

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

  /// Lấy thông tin lượng pin, độ sáng màn hình và âm lượng
  static Future<DeviceInfo> getDeviceState() async {
    try {
      final data =
          await FlutterParentalControlPlatform.instance.getDeviceState();
      return DeviceInfo.fromDeviceState(data);
    } catch (_) {
      rethrow;
    }
  }

  /// Lấy chuỗi định dạng duy nhất của thiết bị
  static Future<String> getDeviceIdentify() async {
    try {
      return await FlutterParentalControlPlatform.instance.getDeviceIdentify();
    } catch (_) {
      rethrow;
    }
  }

  /// các phần chỉ dùng được trên [Android]
  /// Kiểm tra và xin các quyền cho ứng dụng
  /// Permission.accessibility: Quyền trợ năng
  /// Permission.overlay: Quyền hiển thị trên ứng dụng khác
  /// Permission.usageState: Quyền lấy thời gian sử dụng
  /// Permission.deviceAdmin: Quyền quản lý thiết bị, sử dụng cho tắt màn hình
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

  /// Lấy danh sách các thông tin cơ bản của các ứng dụng
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

  /// Cần cấp quyền [Permission.usageState] để sử dụng các hàm thời gian sử dụng:
  /// Lấy thời gian sử dụng của thiết bị
  /// Thời gian trả về [millisecond]
  static Future<int> getDeviceUsage() async {
    try {
      _checkPlatform(false);
      final deviceUsage =
          await FlutterParentalControlPlatform.instance.getDeviceUsage();
      return deviceUsage;
    } catch (_) {
      rethrow;
    }
  }

  /// Lấy thời gian sử dụng của các ứng dụng trong 1 khoảng thời gian
  /// Trả về số [millisecond] sử dụng trong mỗi 15 phút
  static Future<List<TimeUsageForApp>> getUsageTimeQuarterHour(
      int startTime, int endTime) async {
    try {
      _checkPlatform(false);
      final data = await FlutterParentalControlPlatform.instance
          .getUsageTimeQuarterHour(startTime, endTime);
      return data.entries.map((entry) {
        return TimeUsageForApp.fromMap(
          entry.key,
          Map<int, int>.from(entry.value),
        );
      }).toList();
    } catch (_) {
      rethrow;
    }
  }

  /// Lấy tổng thời gian sử dụng của các ứng dụng
  /// [day] là số ngày lấy thời gian sử dụng, mặc định là ngày hiện tại
  /// Giá trị trả về [millisecond]
  static Future<List<AppUsage>> getAppUsageInfoForDay({int? day}) async {
    _checkPlatform(false);
    final data =
        await FlutterParentalControlPlatform.instance.getAppUsageInfo(day: day);
    return data.entries
        .map((entry) => AppUsage(packageName: entry.key, timeUsed: entry.value))
        .toList();
  }

  /// Cần cấp quyền [Permission.accessibility] để có thể thực thi các cài đặt
  /// Và quyền [Permission.overlay] để hiển thị màn hình chặn
  /// Cài đặt thời gian và khoảng thời gian sử dụng cho thiết bị
  /// [timeAllowed] là phút, [listTimePeriod] dạng : [{"startTime":0,"endTime":60},{}..]
  static Future<void> setTimeAllowDevice(
      {int? timeAllowed, List<Map<String, dynamic>>? listTimePeriod}) async {
    try {
      _checkPlatform(false);
      await FlutterParentalControlPlatform.instance.setTimeAllowDevice(
          timeAllowed: timeAllowed, listTimePeriod: listTimePeriod);
    } catch (_) {
      rethrow;
    }
  }

  /// Thiết lập danh sách ứng dụng bị giới hạn
  /// [addNew] cho biết có thêm mới không hay là thay thế
  static Future<void> setListAppBlocked(List<AppBlock> listApp,
      {bool addNew = false}) async {
    try {
      _checkPlatform(false);
      final listAppBlock = listApp.map((app) => app.toMap()).toList();
      await FlutterParentalControlPlatform.instance
          .setListAppBlocked(listAppBlock, addNew: addNew);
    } catch (_) {
      rethrow;
    }
  }

  /// Thiết lập danh sách nội dung web bị giới hạn
  /// [addNew] cho biết có thêm mới không hay là thay thế
  static Future<void> setListWebBlocked(List<String> listWeb,
      {bool addNew = false}) async {
    try {
      _checkPlatform(false);
      await FlutterParentalControlPlatform.instance
          .setListWebBlocked(listWeb, addNew: addNew);
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

  /// Lắng nghe khi có có sự kiện nhấn nút hỏi phụ huynh
  /// [askParent] Bị mất kết nối khi chạy ở nền
  /// ParentalControl.askParent((packageName, appName) async {
  /// function...
  /// });
  static Future<void> askParent(
      Function(String packageName, String appName) function) async {
    try {
      _checkPlatform(false);
      await FlutterParentalControlPlatform.instance.askParent(function);
    } catch (_) {
      rethrow;
    }
  }

  /// Khoá màn hình thiết bị
  /// Cần cấp quyền [Permission.deviceAdmin]
  static Future<void> lockDevice() async {
    try {
      _checkPlatform(false);
      await FlutterParentalControlPlatform.instance.lockDevice();
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
  /// Chỉ hoạt động sau khi gọi [startService]
  /// ParentalControl.listenAppInstalledInfo().listen((app) {
  ///    code
  /// });
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

  /// Tạo overlay khi chặn ứng dụng hoặc cấm gỡ bỏ ứng dụng
  /// Sử dụng khi ứng dụng được khởi tạo hoặc trước khi bật dịch vụ trợ năng
  static Future<void> setOverlayView(
    /// isBlock = true là giao diện chặn sử dụng ứng dụng
    /// isBlock = false là giao diện chặn xoá ứng dụng
    bool isBlock,

    /// tên của màn hình chặn, không lấy phần .xml
    String overlayView, {
    /// id của nút thoát màn hình chặn = về home
    String? backBtnId,

    /// id nút hỏi phụ huynh
    String? askParentBtnId,
  }) async {
    try {
      _checkPlatform(false);
      await FlutterParentalControlPlatform.instance.setOverlayView(
        isBlock,
        overlayView,
        backBtnId: backBtnId,
        askParentBtnId: askParentBtnId,
      );
    } catch (_) {
      rethrow;
    }
  }

  /// các phần chỉ dùng được trên [iOS]
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

  /// Các hàm private của [flutter_parental_control.dart]
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
      case Permission.deviceAdmin:
        return 4;
    }
  }
}

///  Tạo enum cho các trường hợp xin quyền trên [Android]
enum Permission { accessibility, overlay, usageState, deviceAdmin }

/// Hàm chạy dưới nền
@pragma('vm:entry-point')
Future<dynamic> listenAppBlock() async {
  WidgetsFlutterBinding.ensureInitialized();
  const methodChannel = MethodChannel('background_safekids_channel');
  methodChannel.setMethodCallHandler((call) async {
    if (call.method == 'openAppBlock') {
      return call.arguments;
    }
    return null;
  });
}

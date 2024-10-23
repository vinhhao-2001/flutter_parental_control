part of 'package:flutter_parental_control/flutter_parental_control.dart';

/// Thông tin thời gian sử dụng các ứng dụng
class AppUsageInfo {
  final String appName;
  final String packageName;
  final String appIcon;
  final int usageTime;

  AppUsageInfo({
    required this.appName,
    required this.packageName,
    required this.appIcon,
    required this.usageTime,
  });

  /// Chuyển đổi dữ liệu nhận được thành đối tượng
  /// Xử lý cho 2 trường hợp của [appIcon]
  factory AppUsageInfo.fromMap(Map<String, dynamic> map) {
    String iconBase64;
    if (map[AppConstants.appIcon] is List<int>) {
      /// Xử lý khi lấy dữ liệu trong native android
      iconBase64 = base64Encode(
          Uint8List.fromList(map[AppConstants.appIcon].cast<int>()));
    } else {
      /// Xử lý khi icon đã được định dạng thành base64
      iconBase64 = map[AppConstants.appIcon];
    }
    return AppUsageInfo(
      appName: map[AppConstants.appName],
      packageName: map[AppConstants.packageName],
      appIcon: iconBase64,
      usageTime: map[AppConstants.usageTime],
    );
  }

  /// Chuyển đổi đối tượng thành map
  Map<String, dynamic> toMap() {
    return {
      AppConstants.appName: appName,
      AppConstants.packageName: packageName,
      AppConstants.appIcon: appIcon,
      AppConstants.usageTime: usageTime,
    };
  }
}

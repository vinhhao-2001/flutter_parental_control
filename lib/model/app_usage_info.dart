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

  factory AppUsageInfo.fromMap(Map<String, dynamic> map) {
    String iconBase64 =
        base64Encode(Uint8List.fromList(map[AppConstants.appIcon].cast<int>()));
    return AppUsageInfo(
      appName: map[AppConstants.appName],
      packageName: map[AppConstants.packageName],
      appIcon: iconBase64,
      usageTime: map[AppConstants.usageTime],
    );
  }
}

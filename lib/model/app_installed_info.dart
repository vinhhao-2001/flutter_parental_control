part of 'package:flutter_parental_control/flutter_parental_control.dart';

/// thông tin ứng dụng cài đặt hoặc gỡ bỏ
class AppInstalledInfo {
  final bool isInstalled;
  final String packageName;
  final String appName;
  final String appIcon;

  AppInstalledInfo({
    required this.isInstalled,
    required this.packageName,
    required this.appName,
    required this.appIcon,
  });

  factory AppInstalledInfo.map(Map<String, dynamic> map) {
    String iconBase64 =
        base64Encode(Uint8List.fromList(map[AppConstants.appIcon].cast<int>()));
    return AppInstalledInfo(
      appName: map[AppConstants.appName],
      packageName: map[AppConstants.packageName],
      isInstalled: map[AppConstants.isInstalled],
      appIcon: iconBase64,
    );
  }
}

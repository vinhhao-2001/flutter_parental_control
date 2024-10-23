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

  /// Chuyển đổi dữ liệu nhận được thành đối tượng
  /// Xử lý cho 2 trường hợp của [appIcon]
  factory AppInstalledInfo.fromMap(Map<String, dynamic> map) {
    String iconBase64;
    if (map[AppConstants.appIcon] is List<int>) {
      /// Xử lý khi lấy dữ liệu trong native android
      iconBase64 = base64Encode(
          Uint8List.fromList(map[AppConstants.appIcon].cast<int>()));
    } else {
      /// Xử lý khi icon đã được định dạng thành base64
      iconBase64 = map[AppConstants.appIcon];
    }
    return AppInstalledInfo(
      isInstalled: map[AppConstants.isInstalled],
      appName: map[AppConstants.appName],
      packageName: map[AppConstants.packageName],
      appIcon: iconBase64,
    );
  }

  /// Chuyển đổi đối tượng thành map
  Map<String, dynamic> toMap() {
    return {
      AppConstants.isInstalled: isInstalled,
      AppConstants.appName: appName,
      AppConstants.packageName: packageName,
      AppConstants.appIcon: appIcon,
    };
  }
}

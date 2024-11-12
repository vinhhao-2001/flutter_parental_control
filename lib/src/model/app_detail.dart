part of 'package:flutter_parental_control/flutter_parental_control.dart';

/// Thông tin thời gian sử dụng các ứng dụng
class AppDetail {
  final String packageName;
  final String appName;
  final String appIcon;
  final String versionName;
  final int versionCode;
  final int timeInstall;
  final int timeUpdate;

  AppDetail({
    required this.packageName,
    required this.appName,
    required this.appIcon,
    required this.versionCode,
    required this.versionName,
    required this.timeInstall,
    required this.timeUpdate,
  });

  /// Chuyển đổi dữ liệu nhận được thành đối tượng
  /// Xử lý cho 2 trường hợp của [appIcon]
  factory AppDetail.fromMap(Map<String, dynamic> map) {
    String iconBase64;
    if (map[AppConstants.appIcon] is List<int>) {
      /// Xử lý khi lấy icon trong native android
      iconBase64 = base64Encode(
          Uint8List.fromList(map[AppConstants.appIcon].cast<int>()));
    } else {
      /// Xử lý khi icon đã được định dạng thành base64
      iconBase64 = map[AppConstants.appIcon];
    }
    return AppDetail(
      packageName: map[AppConstants.packageName],
      appName: map[AppConstants.appName],
      appIcon: iconBase64,
      versionName: map[AppConstants.versionName],
      versionCode: map[AppConstants.versionCode],
      timeInstall: map[AppConstants.timeInstall],
      timeUpdate: map[AppConstants.timeUpdate],
    );
  }

  /// Chuyển đổi đối tượng thành map
  Map<String, dynamic> toMap() {
    return {
      AppConstants.appName: appName,
      AppConstants.packageName: packageName,
      AppConstants.appIcon: appIcon,
      AppConstants.versionName: versionName,
      AppConstants.versionCode: versionCode,
      AppConstants.timeInstall: timeInstall,
      AppConstants.timeUpdate: timeUpdate,
    };
  }

  /// Danh sách keys
  static List<String> get keys => [
        AppConstants.appName,
        AppConstants.packageName,
        AppConstants.appIcon,
        AppConstants.versionName,
        AppConstants.versionCode,
        AppConstants.timeInstall,
        AppConstants.timeUpdate,
      ];
}
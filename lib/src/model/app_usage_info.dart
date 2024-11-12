part of 'package:flutter_parental_control/flutter_parental_control.dart';

/// Thông tin thời gian sử dụng các ứng dụng
class AppUsageInfo {
  final String packageName;
  final List<DailyUsage> usageTime;

  AppUsageInfo({
    required this.packageName,
    required this.usageTime,
  });

  /// Chuyển danh sách thời gian sử dụng theo ngày thành map

  /// Chuyển đổi dữ liệu nhận được thành đối tượng
  factory AppUsageInfo.fromMap(Map<String, dynamic> map) {
    return AppUsageInfo(
      packageName: map[AppConstants.packageName],
      usageTime: map[AppConstants.usageTime],
    );
  }

  /// Chuyển đổi đối tượng thành map
  Map<String, dynamic> toMap() {
    return {
      AppConstants.packageName: packageName,
      AppConstants.usageTime: usageTime.map((time) {
        return time.toMap();
      }),
    };
  }

  /// chuyển đổi thời gian sử dụng thành Map
  Map<String, int> toUsageMap() {
    return {
      for (var dailyUsage in usageTime)
        dailyUsage.date.toString(): dailyUsage.timeUsed,
    };
  }

  /// Tạo danh sách key
  static List<String> get keys => [
        AppConstants.packageName,
        AppConstants.usageTime,
      ];
}

/// Thời gian sử dụng trong 1 ngày
class DailyUsage {
  final int date;
  final int timeUsed;

  DailyUsage({
    required this.date,
    required this.timeUsed,
  });
  Map<String, dynamic> toMap() {
    return {date.toString(): timeUsed};
  }
}

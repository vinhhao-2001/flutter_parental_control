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
      AppConstants.usageTime: usageTime,
    };
  }

  Map<int, int> toUsageMap() {
    return {
      for (var dailyUsage in usageTime) dailyUsage.date: dailyUsage.timeUsed
    };
  }
}

/// Thời gian sử dụng trong 1 ngày
class DailyUsage {
  final int date;
  final int timeUsed;

  DailyUsage({
    required this.date,
    required this.timeUsed,
  });
}

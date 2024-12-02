part of 'package:flutter_parental_control/flutter_parental_control.dart';

/// Thông tin thời gian sử dụng các ứng dụng
class TodayUsage {
  final String packageName;
  final List<TimeUsage> usageTime;

  TodayUsage({
    required this.packageName,
    required this.usageTime,
  });

  /// Chuyển đổi dữ liệu nhận được thành đối tượng
  factory TodayUsage.fromMap(String packageName, Map<int, int> usageMap) {
    List<TimeUsage> usageTime = usageMap.entries.map((entry) {
      return TimeUsage(time: entry.key, timeUsed: entry.value);
    }).toList();

    return TodayUsage(
      packageName: packageName,
      usageTime: usageTime,
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
        dailyUsage.time.toString(): dailyUsage.timeUsed,
    };
  }

  /// Tạo danh sách key
  static List<String> get keys => [
        AppConstants.packageName,
        AppConstants.usageTime,
      ];
}

/// Thời gian sử dụng trong khoảng thời gian
class TimeUsage {
  final int time;
  final int timeUsed;

  TimeUsage({
    required this.time,
    required this.timeUsed,
  });
  Map<String, dynamic> toMap() {
    return {time.toString(): timeUsed};
  }
}

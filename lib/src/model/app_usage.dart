part of 'package:flutter_parental_control/flutter_parental_control.dart';

class AppUsage {
  final String packageName;
  final int timeUsed;

  AppUsage({
    required this.packageName,
    required this.timeUsed,
  });
  factory AppUsage.fromMap(Map<String, dynamic> map) {
    return AppUsage(
      packageName: map[AppConstants.packageName],
      timeUsed: map[AppConstants.timeUsed],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      AppConstants.packageName: packageName,
      AppConstants.timeUsed: timeUsed,
    };
  }

  static List<String> get keys => [
        AppConstants.packageName,
        AppConstants.timeUsed,
      ];
}

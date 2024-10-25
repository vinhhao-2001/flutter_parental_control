part of 'package:flutter_parental_control/flutter_parental_control.dart';

class Schedule {
  final bool isMonitoring;
  final int? startHour;
  final int? startMinute;
  final int? endHour;
  final int? endMinute;

  Schedule({
    required this.isMonitoring,
    this.startHour,
    this.startMinute,
    this.endHour,
    this.endMinute,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      isMonitoring: map[AppConstants.isMonitoring],
      startHour: map[AppConstants.startHour],
      startMinute: map[AppConstants.startMinute],
      endHour: map[AppConstants.endHour],
      endMinute: map[AppConstants.endMinute],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      AppConstants.isMonitoring: isMonitoring,
      AppConstants.startHour: startHour,
      AppConstants.startMinute: startMinute,
      AppConstants.endHour: endHour,
      AppConstants.endMinute: endMinute,
    };
  }
}

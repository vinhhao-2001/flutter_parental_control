part of 'package:flutter_parental_control/flutter_parental_control.dart';

class AppBlock {
  final String packageName;
  final int? timeLimit; // minutes

  AppBlock({
    required this.packageName,
    this.timeLimit = 0,
  });

  factory AppBlock.fromMap(Map<String, dynamic> map) {
    return AppBlock(
      packageName: map[AppConstants.packageName],
      timeLimit: map[AppConstants.timeLimit],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      AppConstants.packageName: packageName,
      AppConstants.timeLimit: timeLimit,
    };
  }

  static List<String> get keys=>[
    AppConstants.packageName,
    AppConstants.timeLimit,
  ];
}

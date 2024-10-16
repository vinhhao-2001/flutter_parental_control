part of 'package:flutter_parental_control/flutter_parental_control.dart';

/// Lịch sử tìm kiếm trên trình duyệt
class WebHistory {
  final String searchQuery;
  final int visitedTime;

  WebHistory({
    required this.searchQuery,
    required this.visitedTime,
  });

  factory WebHistory.fromMap(Map<String, dynamic> map) {
    return WebHistory(
      searchQuery: map[AppConstants.searchQuery],
      visitedTime: map[AppConstants.visitedTime],
    );
  }
}

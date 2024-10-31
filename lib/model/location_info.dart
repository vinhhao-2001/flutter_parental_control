part of '../parental_control_widget.dart';

class LocationInfo {
  final double latitude;
  final double longitude;
  final DateTime? timestamp;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  factory LocationInfo.fromMap(Map<String, dynamic> map) {
    return LocationInfo(
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: map['timestamp'],
    );
  }
}

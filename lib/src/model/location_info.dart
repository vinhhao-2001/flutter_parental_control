part of '../../children_map.dart';

class LocationInfo extends LatLng {
  final DateTime? timestamp;

  const LocationInfo({
    required double latitude,
    required double longitude,
    this.timestamp,
  }) : super(latitude, longitude);

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

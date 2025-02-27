part of '../../children_map.dart';

class LocationInfo extends LatLng {
  final DateTime timestamp;

  const LocationInfo({
    required double latitude,
    required double longitude,
    required this.timestamp,
  }) : super(latitude, longitude);

  /// Tạo đối tượng từ
  LocationInfo.fromLatLng(LatLng position, DateTime time)
      : timestamp = time,
        super(position.latitude, position.longitude);

  /// Chuyển đối tượng thành map
  Map<String, dynamic> toMap() {
    return {
      'lat': latitude,
      'long': longitude,
      'tmp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// Chuyển map thành đối tượng
  factory LocationInfo.fromMap(Map<String, dynamic> map) {
    return LocationInfo(
      latitude: map['lat'],
      longitude: map['long'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['tmp']),
    );
  }
}

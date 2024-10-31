part of '../parental_control_widget.dart';

/// Thông tin phạm vi an toàn hiển thị trên bản đồ
class SafeZoneInfo {
  final String? safeZoneName;
  final Uint8List? safeZoneIcon;
  /// Phạm vi an toàn
  final List<LatLng>? safeZone;
  final double? iconSize;

  SafeZoneInfo({
    this.safeZoneName,
    this.safeZoneIcon,
    this.safeZone,
    this.iconSize,
  });
}

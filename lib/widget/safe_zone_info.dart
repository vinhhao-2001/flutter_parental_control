part of 'parental_control_widget.dart';

class SafeZoneInfo {
  final String? safeZoneName;
  final Uint8List? safeZoneIcon;
  final List<LatLng>? safeZone;
  final double? iconSize;

  SafeZoneInfo({
    this.safeZoneName,
    this.safeZoneIcon,
    this.safeZone,
    this.iconSize,
  });
}

part of '../../children_map.dart';

/// Thông tin phạm vi an toàn hiển thị trên bản đồ
class SafeZoneInfo {
  SafeZoneInfo({
    this.safeZoneButton,
    this.safeZoneName,
    this.safeZoneIcon,
    this.safeZone,
    this.iconSize,
  });

  /// Button phạm vi an toàn trên bản đồ
  final SafeZoneButton? safeZoneButton;

  /// tên của phạm vi an toàn
  final String? safeZoneName;

  /// Phạm vi an toàn
  final List<LatLng>? safeZone;

  /// icon các điểm khi vẽ
  final Uint8List? safeZoneIcon;

  final double? iconSize;
}

/// Thông tin button vẽ phạm vi an toàn
class SafeZoneButton {
  /// Tên button vẽ
  final String drawBtn;

  /// Tên button phạm vi an toàn
  final String safeZoneBtn;

  SafeZoneButton({
    required this.drawBtn,
    required this.safeZoneBtn,
  });
}

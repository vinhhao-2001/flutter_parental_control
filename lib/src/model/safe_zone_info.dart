part of '../../children_map.dart';

/// Thông tin phạm vi an toàn hiển thị trên bản đồ
class SafeZoneInfo {
  SafeZoneInfo({
    this.safeZoneName,
    this.safeZoneIcon,
    this.safeZone,
    this.iconSize,
  });

  /// Tên của phạm vi an toàn
  /// Trường bắt buộc để hiển thị phạm vi an toàn
  final String? safeZoneName;

  /// Phạm vi an toàn
  final List<LatLng>? safeZone;

  /// icon các điểm khi vẽ
  final Uint8List? safeZoneIcon;

  final double? iconSize;
}

/// Thông tin button vẽ phạm vi an toàn
class SafeZoneButton {
  /// Tên button phạm vi an toàn
  final String safeZoneBtn;

  /// Tên button vẽ
  final String confirmButton;

  /// Tên button khi huỷ bỏ
  final String cancelButton;

  SafeZoneButton({
    required this.safeZoneBtn,
    required this.confirmButton,
    required this.cancelButton,
  });
}

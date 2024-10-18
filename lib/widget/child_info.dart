part of 'parental_control_widget.dart';

/// Thông tin hiển thị của trẻ trong bản đồ
class ChildInfo {
  final String? childName;
  final Uint8List? childIcon;
  final LatLng? childLocation;
  final double? iconSize;

  ChildInfo({
    this.childName,
    this.childIcon,
    this.childLocation,
    this.iconSize,
  });
}

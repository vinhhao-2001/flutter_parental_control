part of '../parental_control_widget.dart';

/// Thông tin hiển thị của trẻ trong bản đồ
class ChildInfo {
  final String? childName;
  final Uint8List? childIcon;
  final double? iconSize;
  final String? routeName;
  final List<LocationInfo>? childRoute;

  ChildInfo({
    this.childName,
    this.childIcon,
    this.iconSize,
    this.routeName,
    this.childRoute,
  });
}

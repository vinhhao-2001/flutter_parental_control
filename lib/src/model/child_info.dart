part of '../../children_map.dart';

/// Thông tin hiển thị của trẻ trong bản đồ
class ChildInfo {
  /// Tên của trẻ
  final String? childName;

  /// icon của trẻ
  final Uint8List? childIcon;

  /// độ lớn icon
  final double? iconSize;

  /// tên của tuyến đường (Không cần thiết vì chỉ có 1 tuyến đường)
  final String? routeName;

  /// Danh sách các điểm trên tuyến đường nếu nhập vào là [List]
  /// Hoặc là vị trí của trẻ nếu nhập vào là 1 đối tượng [LocationInfo]
  final List<LocationInfo>? childRoute;

  ChildInfo({
    this.childName,
    this.childIcon,
    this.iconSize,
    this.routeName,
    dynamic childLocation,
  }) : childRoute = (childLocation is List<LocationInfo>)

            ///Tuyến đường hoạt động
            ? childLocation

            /// Vị trí của trẻ
            : (childLocation != null ? [childLocation] : null);
}

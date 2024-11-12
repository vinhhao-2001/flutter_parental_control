library parental_control;

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_parental_control/src/core/app_constants.dart';
import 'package:flutter_parental_control/src/core/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

part 'src/model/address.dart';
part 'src/model/child_info.dart';
part 'src/model/safe_zone_info.dart';
part 'src/model/location_info.dart';

/// Widget là bản đồ hiển thị  vị trí của trẻ
/// Hiển thị phạm vi an toàn của trẻ
class ChildLocationWidget extends StatefulWidget {
  const ChildLocationWidget({
    super.key,
    this.childInfo,
    this.safeZoneInfo,
    this.updateButton,
    this.safeZoneButton,
    this.childLocationFunc,
    this.safeZonePointsFunc,
  });

  /// Thông tin của trẻ
  final ChildInfo? childInfo;

  /// Thông tin của phạm vi an toàn
  final SafeZoneInfo? safeZoneInfo;

  /// Thông tin của button cập nhật vị trí
  final String? updateButton;

  /// Thông tin của button vẽ phạm vi an toàn
  final SafeZoneButton? safeZoneButton;

  /// Hàm cập nhật vị trí của trẻ
  final Future<LocationInfo> Function()? childLocationFunc;

  /// Hàm trả về các điểm của phạm vi an toàn
  final Function(List<LatLng>)? safeZonePointsFunc;

  @override
  State<ChildLocationWidget> createState() => _ChildLocationWidgetState();
}

class _ChildLocationWidgetState extends State<ChildLocationWidget> {
  /// Điều khiển camera bằng [_mapController]
  GoogleMapController? _mapController;

  /// Vị trí hiện tại của trẻ dùng để: Cập nhật vị trí camera, đánh dấu vị trí trên bản đồ
  late LocationInfo _childLocation;

  /// Phạm vi an toàn trên bản đồ
  final Set<Polygon> _polygons = {};

  /// Các điểm an toàn
  final List<LatLng> _polygonPoints = [];

  /// Tuyến đường hoạt động
  final Set<Polyline> _polyLine = {};

  /// Các điểm của tuyến đường
  /// Điểm cuối cùng của [_polyLinesPoints] là vị trí của trẻ
  final List<LocationInfo> _polyLinesPoints = [];

  /// Giá trị cho biết đang vẽ phạm vi an toàn không
  bool _isDrawing = false;

  /// Thực hiện khi widget được khởi tạo
  @override
  void initState() {
    super.initState();

    /// vẽ phạm vi an toàn
    _initSafeZone(widget.safeZoneInfo?.safeZone);

    /// vẽ tuyến đường hoạt động của trẻ
    _initChildRoute(widget.childInfo?.childRoute);
  }

  /// Vẽ và hiển thị phạm vi an toàn [_initSafeZone] và [_drawSafeZone]
  /// Lấy phạm vi an toàn lúc khởi tạo map
  Future<void> _initSafeZone(List<LatLng>? safeZonePoints) async {
    if (safeZonePoints?.isNotEmpty ?? false) {
      _drawSafeZone(safeZonePoints!);
    }
  }

  /// Vẽ phạm vi an toàn của trẻ
  void _drawSafeZone(List<LatLng> listPoint) {
    _polygons.add(Polygon(
      polygonId:
          PolygonId(widget.safeZoneInfo?.safeZoneName ?? AppConstants.empty),
      points: listPoint,
      strokeColor: Colors.blue,
      strokeWidth: 2,
      fillColor: Colors.blue.withOpacity(0.5),
    ));
  }

  /// Vẽ và hiển thị phạm vi an toàn [_initChildRoute] và [_drawRoute]
  /// Lấy tuyến đường hoạt động của trẻ lúc khởi tạo Map
  void _initChildRoute(List<LocationInfo>? childRoutePoints) {
    if (childRoutePoints?.isNotEmpty ?? false) {
      _polyLinesPoints.addAll(childRoutePoints!);
      _childLocation = childRoutePoints.last;
      _drawRoute(_polyLinesPoints);
    } else {
      _childLocation = const LocationInfo(latitude: 0.0, longitude: 0.0);
    }
  }

  /// Vẽ tuyến đường trên bản đồ
  void _drawRoute(List<LocationInfo> listPoint) {
    setState(() {
      _polyLine.add(Polyline(
        polylineId:
            PolylineId(widget.childInfo?.routeName ?? AppConstants.empty),
        points: listPoint,
        color: Colors.blue,
      ));
    });
  }

  /// Xử lý khi nhấn 1 điểm trên bản đồ
  void _onMapTap(LatLng point) {
    if (_isDrawing) {
      /// Vẽ phạm vi an toàn của trẻ
      setState(() {
        _polygonPoints.add(point);
      });
    } else {}
  }

  /// Vẽ phạm vi an toàn từ các điểm được chọn trên map
  void _toggleDrawingMode() {
    if (_isDrawing && _polygonPoints.length > 2) {
      List<LatLng> convexHullPoints = Utils().getConvexHull(_polygonPoints);
      _drawSafeZone(convexHullPoints);
      if (widget.safeZonePointsFunc != null) {
        /// Trả các điểm an toàn ra để người dùng xử lý
        widget.safeZonePointsFunc!(convexHullPoints);
      }
    }
    _polygonPoints.clear();
    _isDrawing = !_isDrawing;
    setState(() {});
  }

  /// Cập nhật vị trí của trẻ
  Future<void> _updateChildLocation() async {
    if (widget.childLocationFunc != null) {
      LocationInfo newPosition = await widget.childLocationFunc!();
      setState(() {
        _childLocation = newPosition;
        _polyLinesPoints.add(newPosition);
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: _childLocation,
            zoom: 15.0,
          ),
          markers: {
            Marker(
              markerId:
                  MarkerId(widget.childInfo?.childName ?? AppConstants.empty),
              position: _childLocation,
              icon: Utils().iconPosition(
                widget.childInfo?.childIcon,
                widget.childInfo?.iconSize,
              ),
            ),
            for (int i = 0; i < _polygonPoints.length; i++)
              Marker(
                markerId: MarkerId(i.toString()),
                position: _polygonPoints[i],
                icon: Utils().iconPosition(
                  widget.safeZoneInfo?.safeZoneIcon,
                  widget.safeZoneInfo?.iconSize,
                ),
              ),
          },
          polygons: _polygons,
          polylines: _polyLine,
          onTap: _onMapTap,
        ),
        Positioned(
          bottom: 30,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _toggleDrawingMode,
                child: Text(
                    _isDrawing
                        ? widget.safeZoneButton?.drawBtn ?? AppConstants.done
                        : widget.safeZoneButton?.safeZoneBtn ??
                            AppConstants.safeZone,
                    style: const TextStyle(color: Colors.blue)),
              ),
              if (widget.childLocationFunc != null)
                ElevatedButton(
                  onPressed: _updateChildLocation,
                  child: Text(widget.updateButton ?? AppConstants.update,
                      style: const TextStyle(color: Colors.blue)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Thông tin button vẽ phạm vi an toàn
class SafeZoneButton {
  /// Tên button vẽ
  final String drawBtn;

  /// Tên button phạm vi an toàn
  final String safeZoneBtn;

  SafeZoneButton(this.drawBtn, this.safeZoneBtn);
}

/// Hàm kiểm tra trẻ có trong phạm vi an toàn không
Future<bool> checkChildLocation(
    LatLng childLocation, List<LatLng> polygonPoints) async {
  if (polygonPoints.length < 3) throw AppConstants.safeZoneError;
  int intersections = 0;

  /// Kiểm tra xem điểm có nằm trong vùng an toàn không
  /// Dùng thuật toán Ray-casting để kiểm tra
  for (int i = 0; i < polygonPoints.length; i++) {
    var p1 = polygonPoints[i],
        p2 = polygonPoints[(i + 1) % polygonPoints.length];
    if (((p1.latitude <= childLocation.latitude &&
                childLocation.latitude < p2.latitude) ||
            (p2.latitude <= childLocation.latitude &&
                childLocation.latitude < p1.latitude)) &&
        (childLocation.longitude <
            (p2.longitude - p1.longitude) *
                    (childLocation.latitude - p1.latitude) /
                    (p2.latitude - p1.latitude) +
                p1.longitude)) {
      intersections++;
    }
  }

  return intersections.isOdd;
}

/// Lấy thông tin vị trí từ toạ độ trên Google Map
Future<Address> getAddress(LatLng location) async {
  try {
    final placeMarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    if (placeMarks.isNotEmpty) {
      final childAddress = Address.fromPlaceMark(placeMarks[0]);
      return childAddress;
    } else {
      throw AppConstants.addressError;
    }
  } catch (_) {
    rethrow;
  }
}

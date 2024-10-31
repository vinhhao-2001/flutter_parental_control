import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_parental_control/core/app_constants.dart';
import 'package:flutter_parental_control/core/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

part 'model/address.dart';
part 'model/child_info.dart';
part 'model/safe_zone_info.dart';
part 'model/location_info.dart';

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
  final Future<LatLng> Function()? childLocationFunc;

  /// Hàm trả về các điểm của phạm vi an toàn
  final Function(List<LatLng>)? safeZonePointsFunc;

  @override
  State<ChildLocationWidget> createState() => _ChildLocationWidgetState();
}

class _ChildLocationWidgetState extends State<ChildLocationWidget> {
  GoogleMapController? _mapController;
  late LatLng childLocation;
  final Set<Polygon> _polygons = {};
  final List<LatLng> _polygonPoints = [];
  final Set<Polyline> _polyLine = {};
  final List<LatLng> _polyLinesPoints = [];

  bool _isDrawing = false;

  @override
  void initState() {
    /// Thực hiện khi widget được khởi tạo
    super.initState();

    /// vị trí ban đầu của trẻ
    childLocation = widget.childInfo?.childLocation ?? const LatLng(0.0, 0.0);

    /// vẽ phạm vi an toàn
    _initSafeZone(widget.safeZoneInfo?.safeZone);

    /// vẽ tuyến đường hoạt động của trẻ
    _initChildRoute();
  }

  /// Lấy phạm vi an toàn lúc khởi tạo map
  Future<void> _initSafeZone(List<LatLng>? safeZonePoints) async {
    if (safeZonePoints != null) {
      setState(() {
        _polygonPoints.addAll(safeZonePoints);
        if (safeZonePoints.isNotEmpty) {
          _polygons.add(Polygon(
            polygonId: PolygonId(
                widget.safeZoneInfo?.safeZoneName ?? AppConstants.empty),
            points: safeZonePoints,
            strokeColor: Colors.blue,
            strokeWidth: 2,
            fillColor: Colors.blue.withOpacity(0.5),
          ));
        }
      });
    }
  }

  void _initChildRoute() {
    _polyLine.add(
      Polyline(
        polylineId:
            PolylineId(widget.childInfo?.routeName ?? AppConstants.empty),
        points: _polyLinesPoints,
        color: Colors.blue,
        width: 5,
      ),
    );
    setState(() {});
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
    setState(() {
      if (_isDrawing && _polygonPoints.length > 2) {
        List<LatLng> convexHullPoints = Utils().getConvexHull(_polygonPoints);
        _polygons.add(Polygon(
          polygonId: PolygonId(
              widget.safeZoneInfo?.safeZoneName ?? AppConstants.safeZone),
          points: convexHullPoints,
          strokeColor: Colors.blue,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.5),
        ));
        if (widget.safeZonePointsFunc != null) {
          widget.safeZonePointsFunc!(convexHullPoints);
        }
      }
      _polygonPoints.clear();
      _isDrawing = !_isDrawing;
    });
  }

  /// Cập nhật vị trí của trẻ
  Future<void> _updateChildLocation() async {
    updateAddress(childLocation);
    if (widget.childLocationFunc != null) {
      LatLng newPosition = await widget.childLocationFunc!();
      setState(() {
        childLocation = newPosition;
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
            target: childLocation,
            zoom: 15.0,
          ),
          markers: {
            Marker(
              markerId:
                  MarkerId(widget.childInfo?.childName ?? AppConstants.empty),
              position: childLocation,
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

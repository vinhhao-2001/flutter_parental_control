import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_parental_control/core/app_constants.dart';
import 'package:flutter_parental_control/core/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

part 'address.dart';
part 'child_info.dart';
part 'safe_zone_info.dart';

/// Widget là bản đồ hiển thị  vị trí của trẻ
/// Hiển thị phạm vi an toàn của trẻ
class ChildMap extends StatefulWidget {
  final ChildInfo? childInfo;
  final SafeZoneInfo? safeZoneInfo;
  final String? updateButton;
  final SafeZoneButton? safeZoneButton;
  final Future<LatLng> Function()? childLocationFunc;
  final Function(List<LatLng>)? safeZonePointsFunc;

  const ChildMap({
    super.key,
    this.childInfo,
    this.safeZoneInfo,
    this.updateButton,
    this.safeZoneButton,
    this.childLocationFunc,
    this.safeZonePointsFunc,
  });

  @override
  State<ChildMap> createState() => _ChildMapState();
}

class _ChildMapState extends State<ChildMap> {
  GoogleMapController? _mapController;
  late LatLng childLocation;
  final Set<Polygon> _polygons = {};
  final List<LatLng> _polygonPoints = [];
  bool _isDrawing = false;

  @override
  void initState() {
    /// Thực hiện khi widget được khởi tạo
    super.initState();
    childLocation = widget.childInfo?.childLocation ?? const LatLng(0.0, 0.0);
    _loadSafeZone(widget.safeZoneInfo?.safeZone);
  }

  /// Lấy phạm vi an toàn lúc khởi tạo map
  Future<void> _loadSafeZone(List<LatLng>? safeZonePoints) async {
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

  /// Sự kiện khi nhấn 1 điểm trên bản đồ
  void _onMapTap(LatLng point) {
    if (_isDrawing) {
      setState(() {
        _polygonPoints.add(point);
      });
    }
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
                        ? widget.safeZoneButton?.draw ?? AppConstants.done
                        : widget.safeZoneButton?.safeZone ??
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
  final String draw;
  final String safeZone;

  SafeZoneButton(this.draw, this.safeZone);
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChildMap extends StatefulWidget {
  final LatLng initialPosition;
  final BitmapDescriptor? childIcon;
  final List<LatLng> initialSafeZone;
  final Future<LatLng> Function()? getPosition;

  const ChildMap({
    super.key,
    required this.initialPosition,
    this.childIcon,
    this.initialSafeZone = const [],
    this.getPosition,
  });

  @override
  State<ChildMap> createState() => _ChildMapState();
}

class _ChildMapState extends State<ChildMap> {
  GoogleMapController? _mapController;
  LatLng childLocation = const LatLng(0.0, 0.0);
  final Set<Polygon> _polygons = {};
  final List<LatLng> _polygonPoints = [];
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    childLocation = widget.initialPosition;
    _loadSafeZone(widget.initialSafeZone);
  }

  Future<void> getPosition() async {
    if (widget.getPosition != null) {
      childLocation = await widget.getPosition!();
      _mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(childLocation, 10));
    }
  }

  // Hàm tải và vẽ phạm vi an toàn từ danh sách điểm ban đầu
  Future<void> _loadSafeZone(List<LatLng> safeZonePoints) async {
    setState(() {
      _polygonPoints.addAll(safeZonePoints);
      if (safeZonePoints.isNotEmpty) {
        _polygons.add(Polygon(
          polygonId: const PolygonId('safeZone'),
          points: safeZonePoints,
          strokeColor: Colors.blue,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.5),
        ));
      }
    });
  }

  // Bắt sự kiện khi người dùng chạm vào bản đồ
  void _onMapTap(LatLng point) {
    if (_isDrawing) {
      setState(() {
        _polygonPoints.add(point);
      });
    }
  }

  // Bắt đầu hoặc hoàn tất chế độ vẽ phạm vi an toàn
  void _toggleDrawingMode() {
    setState(() {
      if (_isDrawing && _polygonPoints.length > 2) {
        List<LatLng> convexHullPoints = getConvexHull(_polygonPoints);
        _polygons.add(Polygon(
          polygonId: const PolygonId('safeZone'),
          points: convexHullPoints,
          strokeColor: Colors.blue,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.5),
        ));
        _polygonPoints.clear(); // Xóa các điểm sau khi vẽ xong
      }
      _isDrawing = !_isDrawing;
    });
  }

  // Cập nhật vị trí của trẻ và di chuyển camera đến vị trí mới
  Future<void> _updateChildLocation() async {
    if (widget.getPosition != null) {
      LatLng newPosition = await widget.getPosition!();
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
              markerId: const MarkerId("child"),
              position: childLocation,
              icon: widget.childIcon ?? BitmapDescriptor.defaultMarker,
            ),
          },
          polygons: _polygons,
          onTap: _onMapTap,
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _toggleDrawingMode,
                child: Text(_isDrawing ? "Hoàn tất" : "Vẽ phạm vi an toàn"),
              ),
              if (widget.getPosition != null)
                ElevatedButton(
                  onPressed: _updateChildLocation,
                  child: const Text("Cập nhật vị trí"),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Hàm tính toán bao lồi (convex hull) từ danh sách các điểm
  List<LatLng> getConvexHull(List<LatLng> points) {
    points.sort((a, b) {
      if (a.latitude == b.latitude) return a.longitude.compareTo(b.longitude);
      return a.latitude.compareTo(b.latitude);
    });

    List<LatLng> hull = [];

    for (var p in points) {
      while (
          hull.length > 1 && _cross(hull[hull.length - 2], hull.last, p) <= 0) {
        hull.removeLast();
      }
      hull.add(p);
    }

    int t = hull.length + 1;
    for (var i = points.length - 2; i >= 0; i--) {
      LatLng p = points[i];
      while (hull.length >= t &&
          _cross(hull[hull.length - 2], hull.last, p) <= 0) {
        hull.removeLast();
      }
      hull.add(p);
    }

    hull.removeLast();
    return hull;
  }

  // Hàm tính toán giao của 3 điểm
  double _cross(LatLng o, LatLng a, LatLng b) {
    return (a.longitude - o.longitude) * (b.latitude - o.latitude) -
        (a.latitude - o.latitude) * (b.longitude - o.longitude);
  }
}

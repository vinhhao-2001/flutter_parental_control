library parental_control;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parental_control/src/core/app_constants.dart';
import 'package:flutter_parental_control/src/core/app_utils.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'src/model/address.dart';
part 'src/model/child_info.dart';
part 'src/model/location_info.dart';
part 'src/model/safe_zone_info.dart';

/// Widget là bản đồ hiển thị  vị trí của trẻ
/// Hiển thị phạm vi an toàn của trẻ
class ChildrenMapView extends StatefulWidget {
  const ChildrenMapView({
    super.key,
    this.childInfo,
    this.safeZoneInfo,
    this.childLocationFunc,
    this.safeZonePointsFunc,
    this.mapType = MapType.normal,
    this.childLocationButton,
    this.safeZoneButton,
    this.routeVisible = false,
    this.safeZoneVisible = false,
    this.childLocationButtonEnabled = true,
    this.myLocationButtonEnabled = true,
    this.drawSafeZoneButtonEnabled = true,
  });

  /// Thông tin của trẻ
  final ChildInfo? childInfo;

  /// Thông tin của phạm vi an toàn
  final SafeZoneInfo? safeZoneInfo;

  /// Hàm cập nhật vị trí của trẻ
  final Stream<LocationInfo>? childLocationFunc;

  /// Hàm trả về các điểm của phạm vi an toàn
  /// Nhận được mỗi khi tạo phạm vi an toàn
  final Function(List<LatLng>)? safeZonePointsFunc;

  /// Kiểu hiển thị của bản đồ
  /// none: Không hiển thị bản đồ
  /// normal: Bản đồ mặc định.
  /// satellite: Bản đồ vệ tinh.
  /// terrain: Bản đồ địa hình.
  /// hybrid: Kết hợp giữa vệ tinh và thông tin địa lý.
  final MapType mapType;

  /// Hiển thị tuyến đường hoạt động
  final bool routeVisible;

  /// Hiển thị vùng an toàn
  final bool safeZoneVisible;

  /// Button đến vị trí hiện tại của trẻ
  /// Chỉ hiển thị khi giá trị không null
  final bool childLocationButtonEnabled;

  /// Button phạm vi an toàn có hiện không
  final bool drawSafeZoneButtonEnabled;

  /// Button di chuyển đến vị trí của bản thân
  /// Chỉ hiển thị khi đã được cấp quyền vị trí trước đó
  final bool myLocationButtonEnabled;

  /// Tên button di chuyển đến vị trí của trẻ
  final String? childLocationButton;

  /// Tên button phạm vi an toàn trên bản đồ
  final SafeZoneButton? safeZoneButton;

  @override
  State<ChildrenMapView> createState() => _ChildrenMapViewState();
}

class _ChildrenMapViewState extends State<ChildrenMapView> {
  /// Điều khiển camera bằng [_mapController]
  GoogleMapController? _mapController;

  /// Vị trí hiện tại của trẻ dùng để: Cập nhật vị trí camera, đánh dấu vị trí trên bản đồ
  late LocationInfo _childLocation;

  /// Lắng nghe vị trí của trẻ
  late StreamSubscription<LocationInfo>? _locationSubscription;

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

    /// Cập nhật vị trí của trẻ
    _updateChildLocation();

    /// vẽ phạm vi an toàn
    _initSafeZone(widget.safeZoneInfo?.safeZone);

    /// vẽ tuyến đường hoạt động của trẻ
    _initChildRoute(widget.childInfo?.childRoute);
  }

  /// Vẽ và hiển thị phạm vi an toàn [_initSafeZone] và [_drawSafeZone]
  /// Vẽ phạm vi an toàn lúc khởi tạo map
  Future<void> _initSafeZone(List<LatLng>? safeZonePoints) async {
    if (safeZonePoints != null && safeZonePoints.length > 3) {
      _drawSafeZone(safeZonePoints);
    }
  }

  /// Vẽ phạm vi an toàn của trẻ
  void _drawSafeZone(List<LatLng> listPoint) {
    /// TODO: Nên đặt tên vùng an toàn sau khi vẽ xong, để cho phép tạo được nhiều vùng an toàn
    if (!widget.safeZoneVisible) return;
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
      childRoutePoints!.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      _polyLinesPoints.addAll(childRoutePoints);
      _childLocation = childRoutePoints.last;
      _drawRoute(_polyLinesPoints);
    } else {
      _childLocation = LocationInfo(
          latitude: 0.0, longitude: 0.0, timestamp: DateTime.now());
    }
  }

  /// Vẽ tuyến đường trên bản đồ
  void _drawRoute(List<LocationInfo> listPoint) {
    /// Nếu không có tên của tuyến đường thì không vẽ
    if (!widget.routeVisible) return;
    setState(() {
      _polyLine.add(Polyline(
        polylineId:
            PolylineId(widget.childInfo?.routeName ?? AppConstants.empty),
        points: listPoint,
        color: Colors.blue,
      ));
    });
  }

  /// Vẽ phạm vi an toàn từ các điểm được chọn trên map
  void _toggleDrawingMode() {
    // TODO: Xử lý lỗi, hoặc thông báo cho TH 2 điểm
    if (_isDrawing && _polygonPoints.length > 2) {
      List<LatLng> convexHullPoints = Utils.getConvexHull(_polygonPoints);
      _drawSafeZone(convexHullPoints);
      if (widget.safeZonePointsFunc != null) {
        /// Trả về các điểm an toàn để người dùng xử lý
        widget.safeZonePointsFunc!(convexHullPoints);
      }
    }
    _polygonPoints.clear();
    _isDrawing = !_isDrawing;
    setState(() {});
  }

  /// Xử lý khi nhấn 1 điểm trên bản đồ
  void _onMapTap(LatLng point) {
    /// Hiển thị phạm vi an toàn của trẻ
    /// Được thực hiện ở chế độ vẽ
    if (_isDrawing) {
      setState(() {
        _polygonPoints.add(point);
      });
    }

    /// Xử lý cho trường hợp khác khi chạm trên bản đồ (nếu cần)
  }

  /// Cập nhật vị trí của trẻ
  void _updateChildLocation() {
    if (widget.childLocationFunc != null) {
      _locationSubscription = widget.childLocationFunc!.listen((newPosition) {
        setState(() {
          _childLocation = newPosition;
          _polyLinesPoints.add(newPosition);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Bản đồ
        GoogleMap(
          /// Điều khiển vị trí toạ độ hiển thị
          onMapCreated: (controller) {
            _mapController = controller;
          },

          /// Cho phép google map được ưu tiên các cử chỉ màn hình
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer())
          },

          /// Toạ độ hiển thị đầu tiên
          initialCameraPosition: CameraPosition(
            target: _childLocation,
            zoom: 15.0,
          ),
          mapType: widget.mapType,
          markers: {
            /// Vị trí của trẻ
            Marker(
              markerId:
                  MarkerId(widget.childInfo?.childName ?? AppConstants.empty),
              position: _childLocation,
              icon: Utils.iconPosition(
                widget.childInfo?.childIcon,
                widget.childInfo?.iconSize,
              ),
            ),

            /// Các điểm khi vẽ phạm vi an toàn
            for (int i = 0; i < _polygonPoints.length; i++)
              Marker(
                markerId: MarkerId(i.toString()),
                position: _polygonPoints[i],
                icon: Utils.iconPosition(
                  widget.safeZoneInfo?.safeZoneIcon,
                  widget.safeZoneInfo?.iconSize,
                ),
              ),
          },
          mapToolbarEnabled: true, // TODO: Hiển thị điều hướng đến Google Map
          myLocationEnabled: true,
          myLocationButtonEnabled: widget.myLocationButtonEnabled,
          zoomControlsEnabled: false,
          polygons: _polygons,
          polylines: _polyLine,
          onTap: _onMapTap,
        ),

        /// Button di chuyển đến vị trí của trẻ
        if (widget.childLocationButtonEnabled)
          Positioned(
            bottom: 30,
            right: 15,
            child: _buildBlurButton(
              onPressed: () {
                _mapController
                    ?.animateCamera(CameraUpdate.newLatLng(_childLocation));
              },
              icon: const Icon(Icons.location_on_outlined),
              tooltip: widget.childLocationButton,
            ),
          ),

        /// Button SafeKids
        if (widget.drawSafeZoneButtonEnabled)
          Positioned(
            bottom: 30,
            left: 15,
            child: _buildBlurButton(
              onPressed: _toggleDrawingMode,
              icon: _isDrawing
                  ? const Icon(Icons.check, color: Colors.green)
                  : const Icon(Icons.health_and_safety),
              tooltip: _isDrawing
                  ? widget.safeZoneButton?.confirmButton
                  : widget.safeZoneButton?.safeZoneBtn,
            ),
          ),
        if (_isDrawing)
          Positioned(
            bottom: 30,
            left: 70,
            child: _buildBlurButton(
                onPressed: () {
                  /// Huỷ bỏ sự kiện tạo phạm vi an toàn
                  setState(() {
                    _polygonPoints.clear();
                    _isDrawing = !_isDrawing;
                  });
                },
                icon: const Icon(Icons.close, color: Colors.red),
                tooltip: widget.safeZoneButton?.cancelButton),
          ),
      ],
    );
  }

  /// Các button nằm trên bản đồ
  Widget _buildBlurButton({
    required VoidCallback onPressed,
    required Widget icon,
    String? tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7), // Nền mờ
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Tooltip(
        message: tooltip ?? '',
        preferBelow: false,
        // Hiển thị tooltip phía trên button
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: Colors.black),
        child: IconButton(
          icon: icon,
          onPressed: onPressed,
        ),
      ),
    );
  }

  /// Huỷ đăng kí các sự kiện
  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}

/// Các hàm liên quan đến vị trí của trẻ
class MapToolkit {
  /// Hàm lấy vị trí của trẻ
  static Future<Position> getLocation() async {
    try {
      final locationPermission = await _locationPermission();
      if (locationPermission) {
        return await Geolocator.getCurrentPosition(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.high));
      } else {
        throw AppConstants.locationError;
      }
    } catch (_) {
      rethrow;
    }
  }

  /// Hàm kiểm tra trẻ có trong phạm vi an toàn không
  /// Nếu có ít hơn 3 điểm trong phạm vi an toàn thì trả về mặc định là true
  static bool checkChildLocation(LatLng location, List<LatLng> safeZonePoints) {
    if (safeZonePoints.length < 3) return true;
    int intersections = 0;

    /// Kiểm tra xem điểm có nằm trong vùng an toàn không
    /// Dùng thuật toán Ray-casting để kiểm tra
    for (int i = 0; i < safeZonePoints.length; i++) {
      var p1 = safeZonePoints[i],
          p2 = safeZonePoints[(i + 1) % safeZonePoints.length];
      if (((p1.latitude <= location.latitude &&
                  location.latitude < p2.latitude) ||
              (p2.latitude <= location.latitude &&
                  location.latitude < p1.latitude)) &&
          (location.longitude <
              (p2.longitude - p1.longitude) *
                      (location.latitude - p1.latitude) /
                      (p2.latitude - p1.latitude) +
                  p1.longitude)) {
        intersections++;
      }
    }

    return intersections.isOdd;
  }

  /// Lấy thông tin vị trí từ toạ độ trên Google Map
  static Future<Address> getAddress(LatLng location) async {
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

  /// Hàm kiểm tra quyền truy cập vị trí
  static Future<bool> _locationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }
    return false;
  }
}

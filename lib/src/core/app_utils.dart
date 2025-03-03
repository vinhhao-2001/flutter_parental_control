import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Utils {
  /// Chuyển chuỗi UintList thành icon của map
  static BitmapDescriptor iconPosition(Uint8List? icon, double? size) {
    if (icon != null) {
      return BitmapDescriptor.bytes(icon,
          width: size ?? 50, height: size ?? 50);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  /// Vẽ đa giác lồi từ các điểm toạ độ
  static List<LatLng> getConvexHull(List<LatLng> points) {
    // Sắp xếp theo vĩ độ -> kinh độ
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

  /// Nối các điểm toạ độ
  static double _cross(LatLng o, LatLng a, LatLng b) {
    return (a.longitude - o.longitude) * (b.latitude - o.latitude) -
        (a.latitude - o.latitude) * (b.longitude - o.longitude);
  }
}

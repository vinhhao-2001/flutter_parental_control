import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChildMapScreen extends StatefulWidget {
  final LatLng initialPosition;
  final BitmapDescriptor? childIcon;
  final Set<Polygon> polygons;
  final List<LatLng> polygonPoints;
  final Function(LatLng) onMapTap;
  final Function(GoogleMapController) onMapCreated;

  const ChildMapScreen({
    super.key,
    required this.initialPosition,
    required this.onMapTap,
    required this.onMapCreated,
    this.childIcon,
    this.polygons = const {},
    this.polygonPoints = const [],
  });

  @override
  State<ChildMapScreen> createState() => _ChildMapState();
}

class _ChildMapState extends State<ChildMapScreen> {
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: widget.onMapCreated,
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition,
        zoom: 5.0,
      ),
      markers: {
        Marker(
          markerId: const MarkerId("child"),
          position: widget.initialPosition,
          icon: widget.childIcon ?? BitmapDescriptor.defaultMarker,
        ),
        for (int i = 0; i < widget.polygonPoints.length; i++)
          Marker(
            markerId: MarkerId('point_$i'),
            position: widget.polygonPoints[i],
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
      },
      polygons: widget.polygons,
      onTap: widget.onMapTap,
    );
  }
}

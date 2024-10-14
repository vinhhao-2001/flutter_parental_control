import 'package:flutter/material.dart';
import 'package:flutter_parental_control/child_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChildLocationScreen extends StatefulWidget {
  const ChildLocationScreen({super.key});

  @override
  State<ChildLocationScreen> createState() => _ChildLocationScreenState();
}

class _ChildLocationScreenState extends State<ChildLocationScreen> {
  GoogleMapController? _mapController;
  LatLng childLocation = const LatLng(30, 105);
  @override
  void initState() {
    super.initState();
    _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: childLocation)));
    int i = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ChildMap(
              initialPosition: childLocation,
              getPosition: getPosition,
            ),
          ),
        ],
      ),
    );
  }

  Future<LatLng> getPosition() async {
    return const LatLng(21.022459884602593, 105.78758240740606);
  }
}

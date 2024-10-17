import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_parental_control/widget/parental_control_widget.dart';

class ChildLocationScreen extends StatefulWidget {
  const ChildLocationScreen({super.key});

  @override
  State<ChildLocationScreen> createState() => _ChildLocationScreenState();
}

class _ChildLocationScreenState extends State<ChildLocationScreen> {
  GoogleMapController? _mapController;
  LatLng childLocation = const LatLng(30, 105);
  String address = "loading...";

  @override
  void initState() {
    super.initState();
    getChildLocal();
    _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: childLocation)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ChildMap(
              childInfo: ChildInfo(
                childName: 'Trẻ',
                childLocation: childLocation,
                childIcon: base64Decode(icon),
              ),
              safeZoneInfo: SafeZoneInfo(
                safeZoneName: 'Safe Zone',
                safeZone: [
                  const LatLng(21.025693906586127, 105.7975260936253),
                  const LatLng(21.020748573397105, 105.7968015223743),
                  const LatLng(21.02619022753218, 105.8126801997423),
                ],
              ),
              childLocationFunc: getChildLocal,
              //  safeZoneButton: SafeZoneButton('Xác nhận', 'Vùng an toàn'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: Text(
                    address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<LatLng> getChildLocal() async {
    const childLocation = LatLng(21.025693906586127, 105.78575260936253);
    final add = await updateAddress(childLocation);
    setState(() {
      address =
          '${add.subAdminArea}, ${add.adminArea}, ${add.country}';
    });
    return childLocation;
  }

  static const icon =
      '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';
}

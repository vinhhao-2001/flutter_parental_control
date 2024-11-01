import 'package:flutter/material.dart';
import 'package:flutter_parental_control/flutter_parental_control.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_parental_control/parental_control_widget.dart';

class ChildLocationScreen extends StatefulWidget {
  const ChildLocationScreen({super.key});

  @override
  State<ChildLocationScreen> createState() => _ChildLocationScreenState();
}

class _ChildLocationScreenState extends State<ChildLocationScreen> {
  List<LocationInfo> childRoute = [
    const LocationInfo(latitude: 30.5, longitude: 104.5),
    const LocationInfo(latitude: 31, longitude: 106)
  ];
  String address = "loading...";

  @override
  void initState() {
    super.initState();
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
            child: ChildLocationWidget(
              childInfo: ChildInfo(childName: 'Trẻ', childRoute: childRoute),
              safeZoneInfo: SafeZoneInfo(
                safeZoneName: 'Safe Zone',
                safeZone: [
                  const LatLng(20.025693906586127, 105.7975260936253),
                  const LatLng(21.020748573397105, 105.7968015223743),
                  const LatLng(21.02619022753218, 105.8126801997423),
                ],
              ),
              childLocationFunc: updateChildLocationFunc,
              safeZoneButton: SafeZoneButton('Xác nhận', 'Vùng an toàn'),
              safeZonePointsFunc: safeZonePointsFunc,
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

  // hàm demo cập nhật vị trí của trẻ
  Future<LocationInfo> updateChildLocationFunc() async {
    final location = await ParentalControl.getLocation();
    double a = DateTime.now().millisecond.toDouble();
    final childLocation = LocationInfo(
      latitude: location.latitude + a/100,
      longitude: location.longitude - a/150,
      timestamp: location.timestamp,
    );
    final add = await getAddress(childLocation);
    setState(() {
      address = '${add.subAdminArea}, ${add.adminArea}, ${add.country}';
    });
    return childLocation;
  }

  // hàm demo sử dụng các điểm của phạm vi an toàn
  void safeZonePointsFunc(List<LatLng> safeZonePoints) {
    print('Các điểm của vùng an toàn: $safeZonePoints');
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_parental_control/flutter_parental_control.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_parental_control/children_map.dart';

class ChildLocationScreen extends StatefulWidget {
  const ChildLocationScreen({super.key});

  @override
  State<ChildLocationScreen> createState() => _ChildLocationScreenState();
}

class _ChildLocationScreenState extends State<ChildLocationScreen> {
  List<LocationInfo> childLocation = [
    LocationInfo(
      latitude: 21.022419825704425,
      longitude: 105.78732491534295,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
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
            child: ChildrenMapView(
              childInfo: ChildInfo(
                  childName: 'Trẻ',
                  childLocation: LocationInfo(
                    latitude: 21.022419825704425,
                    longitude: 105.78732491534295,
                    timestamp: DateTime.now(),
                  )),
              safeZoneInfo: SafeZoneInfo(
                safeZoneName: 'Safe Zone',
                safeZone: [
                  const LatLng(20.025693906586127, 105.7975260936253),
                  const LatLng(21.020748573397105, 105.7968015223743),
                  const LatLng(21.02619022753218, 105.8126801997423),
                ],
              ),
              childLocationFunc: updateChildLocation(),
              safeZonePointsFunc: safeZonePointsFunc,
              moveCamera: 'Vị trí của trẻ',
              mapType: MapType.normal,
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
  // Hàm cập nhật vị trí của trẻ và lắng nghe mỗi 5 giây
  Stream<LocationInfo> updateChildLocation() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 5)); // Chờ 5 giây
      final location = await ParentalControl.getLocation();
      double a = DateTime.now().second.toDouble();

      final childLocation = LocationInfo(
        latitude: location.latitude + a / 100,
        longitude: location.longitude - a / 150,
        timestamp: location.timestamp,
      );
      final add = await ChildMap.getAddress(childLocation);

      setState(() {
        address = '${add.subAdminArea}, ${add.adminArea}, ${add.country}';
      });

      yield childLocation;
    }
  }

  // hàm demo sử dụng các điểm của phạm vi an toàn
  void safeZonePointsFunc(List<LatLng> safeZonePoints) {
    print('Các điểm của vùng an toàn: $safeZonePoints');
  }
}

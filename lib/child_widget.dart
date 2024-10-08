// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class ChildWidget {
//   Widget childSafeZoneMap(
//       MapCreatedCallback mapCreated,
//       LatLng childLocation,
//       String childName,
//       List<LatLng> childSafeZonePoints,
//       BitmapDescriptor childAvatar) {
//     return GoogleMap(
//       onMapCreated: mapCreated,
//       initialCameraPosition: CameraPosition(target: childLocation),
//       markers: {
//         // đánh dấu vị trí của trẻ
//         Marker(
//           markerId: MarkerId(childName),
//           position: childLocation,
//           icon: childAvatar,
//         ),
//         // các điểm an toàn của trẻ
//         for (int i = 0; i < childSafeZonePoints.length; i++)
//           Marker(
//             markerId: MarkerId("$i"),
//             position: childSafeZonePoints[i],
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//                 BitmapDescriptor.hueGreen),
//           ),
//       },
//       polygons: polygons(childSafeZonePoints),
//     );
//   }
//
//   Set<Polygon> polygons(List<LatLng> polygonPoints) {
//     final Set<Polygon> polygons = {};
//     polygons.add(
//       Polygon(
//         polygonId: const PolygonId('SafeZone'),
//         points: polygonPoints,
//         strokeColor: Colors.blue,
//         strokeWidth: 2,
//         fillColor: Colors.blue.withOpacity(0.5),
//       ),
//     );
//     return polygons;
//   }
// }

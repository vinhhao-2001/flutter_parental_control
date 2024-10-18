part of 'parental_control_widget.dart';

/// Tập hợp các trường địa chỉ của trẻ
class Address {
  final String name;
  final String street;
  final String locality;
  final String subLocality;
  final String subAdminArea;
  final String adminArea;
  final String country;

  Address({
    required this.name,
    required this.street,
    required this.locality,
    required this.subLocality,
    required this.subAdminArea,
    required this.adminArea,
    required this.country,
  });

  factory Address.fromPlaceMark(Placemark place) {
    return Address(
      name: place.name ?? AppConstants.empty,
      street: place.street ?? AppConstants.empty,
      locality: place.locality ?? AppConstants.empty,
      subLocality: place.subLocality ?? AppConstants.empty,
      subAdminArea: place.subAdministrativeArea ?? AppConstants.empty,
      adminArea: place.administrativeArea ?? AppConstants.empty,
      country: place.country ?? AppConstants.empty,
    );
  }

  factory Address.fromMap(Map<String, String> map) {
    return Address(
      name: map[AppConstants.name] ?? AppConstants.empty,
      street: map[AppConstants.street] ?? AppConstants.empty,
      locality: map[AppConstants.locality] ?? AppConstants.empty,
      subLocality: map[AppConstants.subLocality] ?? AppConstants.empty,
      subAdminArea: map[AppConstants.subAdminArea] ?? AppConstants.empty,
      adminArea: map[AppConstants.adminArea] ?? AppConstants.empty,
      country: map[AppConstants.country] ?? AppConstants.empty,
    );
  }

  Map<String, String> toMap() {
    return {
      AppConstants.name: name,
      AppConstants.street: street,
      AppConstants.locality: locality,
      AppConstants.subLocality: subLocality,
      AppConstants.subAdminArea: subAdminArea,
      AppConstants.adminArea: adminArea,
      AppConstants.country: country,
    };
  }
}

Future<Address> updateAddress(LatLng location) async {
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

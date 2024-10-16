part of 'package:flutter_parental_control/flutter_parental_control.dart';

/// thông tin thiết bị
class DeviceInfo {
  final String? systemName;
  final String? deviceName;
  final String? deviceManufacturer;
  final String? deviceVersion;
  final String? deviceApiLevel;
  final String? deviceBoard;
  final String? deviceHardware;
  final String? deviceDisplay;
  final String? batteryLevel;
  final String? screenBrightness;
  final String? volume;
  final String? deviceId;

  DeviceInfo({
    this.systemName,
    this.deviceName,
    this.deviceManufacturer,
    this.deviceVersion,
    this.deviceApiLevel,
    this.deviceBoard,
    this.deviceHardware,
    this.deviceDisplay,
    this.batteryLevel,
    this.screenBrightness,
    this.volume,
    this.deviceId,
  });

  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      systemName: map[AppConstants.systemName] as String?,
      deviceName: map[AppConstants.deviceName] as String?,
      deviceManufacturer: map[AppConstants.deviceManufacturer] as String?,
      deviceVersion: map[AppConstants.deviceVersion] as String?,
      deviceApiLevel: map[AppConstants.deviceApiLevel]?.toString(),
      deviceBoard: map[AppConstants.deviceBoard] as String?,
      deviceHardware: map[AppConstants.deviceHardware] as String?,
      deviceDisplay: map[AppConstants.deviceDisplay] as String?,
      batteryLevel: map[AppConstants.batteryLevel] as String?,
      screenBrightness: map[AppConstants.screenBrightness] as String?,
      volume: map[AppConstants.volume] as String?,
      deviceId: map[AppConstants.deviceId] as String?,
    );
  }
}

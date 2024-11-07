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
  final int? batteryLevel;
  final int? screenBrightness;
  final int? volume;
  final String? deviceId;

  DeviceInfo({
    this.systemName = '',
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
      batteryLevel: map[AppConstants.batteryLevel] as int?,
      screenBrightness: map[AppConstants.screenBrightness] as int?,
      volume: map[AppConstants.volume] as int?,
      deviceId: map[AppConstants.deviceId] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppConstants.systemName: systemName,
      AppConstants.deviceName: deviceName,
      AppConstants.deviceManufacturer: deviceManufacturer,
      AppConstants.deviceVersion: deviceVersion,
      AppConstants.deviceApiLevel: deviceApiLevel,
      AppConstants.deviceBoard: deviceBoard,
      AppConstants.deviceHardware: deviceHardware,
      AppConstants.deviceDisplay: deviceDisplay,
      AppConstants.batteryLevel: batteryLevel,
      AppConstants.screenBrightness: screenBrightness,
      AppConstants.volume: volume,
      AppConstants.deviceId: deviceId,
    };
  }

  static List<String> get keys => [
        'systemName',
        'deviceName',
        'deviceManufacturer',
        'deviceVersion',
        'deviceApiLevel',
        'deviceBoard',
        'deviceHardware',
        'deviceDisplay',
        'batteryLevel',
        'screenBrightness',
        'volume',
        'deviceId',
      ];
}

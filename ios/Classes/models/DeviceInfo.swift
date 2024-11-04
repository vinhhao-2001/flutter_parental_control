import UIKit
import AVFoundation

class DeviceInfo {
    static func getDeviceInfo() -> [String: Any] {
        let device = UIDevice.current
        
        // Bật theo dõi pin
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        // Lấy thông tin thiết bị
        let deviceName = device.name
        let systemName = device.systemName
        let systemVersion = device.systemVersion
        
        let modelName = device.model
        let localizedModel = device.localizedModel
        let identifierForVendor = device.identifierForVendor?.uuidString ?? AppConstants.UNKNOWN
        
        let batteryLevel = device.batteryLevel * 100
        let screenBrightness = UIScreen.main.brightness
        let volume = AVAudioSession.sharedInstance().outputVolume
        
        // Tạo dictionary chứa thông tin thiết bị
        let deviceInfo: [String: Any] = [
            AppConstants.SYSTEM_NAME: systemName,
            AppConstants.DEVICE_NAME: deviceName,
            AppConstants.DEVICE_MANUFACTURER: AppConstants.APPLE,
            AppConstants.SYSTEM_VERSION: systemVersion,
            AppConstants.DEVICE_API_LEVEL: systemVersion,
            AppConstants.BATTERY_LEVEL: Int(batteryLevel),
            AppConstants.SCREEN_BRIGHTNESS: Int(screenBrightness * 100),
            AppConstants.VOLUME: Int(volume * 10),
            AppConstants.MODEL_NAME: String(modelName),
            AppConstants.LOCALIZED_MODEL: String(localizedModel),
            AppConstants.DEVICE_ID: String(identifierForVendor),
        ]
        
        return deviceInfo
    }
}

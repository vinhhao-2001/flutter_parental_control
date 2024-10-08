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
        let identifierForVendor = device.identifierForVendor?.uuidString ?? "Unknown"

        let batteryLevel = device.batteryLevel * 100
        let screenBrightness = UIScreen.main.brightness
        let volume = AVAudioSession.sharedInstance().outputVolume

        // Tạo dictionary chứa thông tin thiết bị
        let deviceInfo: [String: Any] = [
            "systemName": systemName,
            "deviceName": deviceName,
            "deviceManufacturer": "Apple",
            "systemVersion": systemVersion,
            "deviceApiLevel": systemVersion,
            "batteryLevel": "\(batteryLevel)%",
            "screenBrightness": "\(screenBrightness)",
            "volume": "\(Int(volume * 100))",
            "modelName": "\(modelName)",
            "localizedModel": "\(localizedModel)",
            "deviceId": "\(identifierForVendor)"
        ]

        return deviceInfo
    }
}

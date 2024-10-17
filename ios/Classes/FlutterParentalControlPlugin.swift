import Flutter
import UIKit
import SwiftUI

@available(iOS 16.0, *)
public class FlutterParentalControlPlugin: NSObject, FlutterPlugin {
    // Đăng kí method channel
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: AppConstants.METHOD_CHANNEL, binaryMessenger: registrar.messenger())
        let instance = FlutterParentalControlPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    // Các chức năng giao tiếp giữa ios và flutter
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case AppConstants.GET_DEVICE_INFO:
            result(DeviceInfo.getDeviceInfo())
            break
        case AppConstants.CHECK_PERMISSION: // Kiểm tra quyền của phụ huynh
            Task {
                let requestPermission = RequestPermission()
                let permission = await requestPermission.checkParentalControl()
                result(permission)
            }
        case AppConstants.SCHEDULE_MONITOR: // Cài đặt thời gian giám sát
            if let args = call.arguments as? [String: Any?] {
                do {
                    try ParentalControlManager.shared.scheduleMonitor(with: args)
                    result(true)
                } catch {
                    result(FlutterError(code: AppConstants.SCHEDULE_MONITOR_ERROR, message: AppConstants.SCHEDULE_ERROR, details: error.localizedDescription))
                }
            }
            break
        case AppConstants.LIMITED_APP: // Giới hạn ứng dụng
            if let controller = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController {
                self.presentSwiftUIView(controller: controller)
                result(true)
            } else {
                result(FlutterError(code: AppConstants.UNAVAILABLE, message: AppConstants.CONTROLLER_ERROR, details: nil))
            }
        case AppConstants.SETTING_MONITOR: // Cài đặt giám sát
            if let args = call.arguments as? [String: Any?] {
                ParentalControlManager.shared.settingMonitor(with: args)
                result(true)
            }
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Mở giao diện giới hạn ứng dụng
    private func presentSwiftUIView(controller: FlutterViewController) {
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        controller.present(hostingController, animated: true, completion: nil)
    }
}

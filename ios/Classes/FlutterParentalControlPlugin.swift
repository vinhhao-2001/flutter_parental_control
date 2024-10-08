import Flutter
import UIKit
import SwiftUI

@available(iOS 16.0, *)
public class FlutterParentalControlPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: AppConstants.METHOD_CHANNEL, binaryMessenger: registrar.messenger())
        let instance = FlutterParentalControlPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case AppConstants.GET_DEVICE_INFO:
            result(DeviceInfo.getDeviceInfo())
            
        case AppConstants.CHECK_PERMISSION:
            Task {
                let requestPermission = RequestPermission()
                let permission = await requestPermission.checkParentalControl()
                result(permission)
            }
        case AppConstants.SCHEDULE_MONITOR:
            if let args = call.arguments as? [String: Any?] {
                ParentalControlManager.shared.scheduleMonitor(with: args)
                result(true)
            }
            break
        case AppConstants.LIMITED_APP:
            if let controller = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController {
                self.presentSwiftUIView(controller: controller)
                result(true)
            } else {
                result(FlutterError(code: "UNAVAILABLE", message: "FlutterViewController not available", details: nil))
            }
        case AppConstants.SETTING_MONITOR:
            if let args = call.arguments as? [String: Any?] {
                ParentalControlManager.shared.settingMonitor(with: args)
                result(true)
            }
            break
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func presentSwiftUIView(controller: FlutterViewController) {
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        controller.present(hostingController, animated: true, completion: nil)
    }
}

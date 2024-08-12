import UIKit
import Flutter
import SystemConfiguration.CaptiveNetwork

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  private let channelName = "com.example.wifi"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
     let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
        
        methodChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "getRouterIP" {
                result(self.getRouterIP())
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getRouterIP() -> String? {
      if let interfaces = CNCopySupportedInterfaces() as? [String] {
          for interface in interfaces {
              if let info = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? {
                  if let ipAddress = info[kCNNetworkInfoKeyBSSID as String] as? String {
                      return ipAddress
                  }
              }
          }
      }
      return nil
  }
}

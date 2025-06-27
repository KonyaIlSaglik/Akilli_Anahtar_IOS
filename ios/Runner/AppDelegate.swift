import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self

    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    let flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin()
    let initializationSettings = InitializationSettings(
      android: nil,
      iOS: IOSInitializationSettings()
    )
    flutterLocalNotificationsPlugin.initialize(initializationSettings)

    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

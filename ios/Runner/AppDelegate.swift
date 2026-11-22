import Flutter
import UIKit
import flutter_local_notifications
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    // Background refresh: iOS decides when it runs; 15 minutes is only the earliest.
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "at.anelkoo.untis_plus.refresh",
      earliestBeginInSeconds: NSNumber(value: 15 * 60)
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private var appGroupChannel: FlutterMethodChannel?

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Tells Dart the app group to share widget data in; SideStore may have renamed it.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "UntisPlusAppGroup") {
      let channel = FlutterMethodChannel(name: "untis_plus/app_group", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { _, result in result(AppGroup.id) }
      appGroupChannel = channel
    }
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

enum AppGroup {
  /// SideStore lists the app group it registered (possibly renamed) in ALTAppGroups.
  static var id: String {
    (Bundle.main.object(forInfoDictionaryKey: "ALTAppGroups") as? [String])?.first ?? "group.at.anelkoo.untisPlus"
  }
}

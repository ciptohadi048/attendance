import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Replace with your Maps API key from:
    // https://console.cloud.google.com/apis/credentials
    // Enable "Maps SDK for iOS" in Google Cloud Console first.
    GMSServices.provideAPIKey("AIzaSyD8cXG7fqzMVk4tcSxBC_81R9sDa4xoi9Q")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

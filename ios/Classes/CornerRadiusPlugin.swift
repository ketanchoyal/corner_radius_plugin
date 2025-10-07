import Flutter
import UIKit

public class CornerRadiusPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "corner_radius_plugin", binaryMessenger: registrar.messenger())
    let instance = CornerRadiusPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getDeviceInfo":
      result([
        "modelIdentifier": UIDevice.current.modelIdentifier,
        "deviceType": CornerRadiusPlugin.deviceTypeString(),
      ])
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // JSON parsing moved to Dart side

  private static func deviceTypeString() -> String {
    switch UIDevice.current.userInterfaceIdiom {
    case .phone: return "iPhone"
    case .pad: return "iPad"
    case .tv: return "tvOS"
    case .carPlay: return "CarPlay"
    case .mac: return "mac"
    case .vision: return "visionOS"
    default: return "unknown"
    }
  }
}

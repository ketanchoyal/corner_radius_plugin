import Flutter
import UIKit

public class CornerRadiusPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var pollTimer: Timer?
  private var lastEmittedKey: String?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "corner_radius_plugin", binaryMessenger: registrar.messenger())
    let events = FlutterEventChannel(name: "corner_radius_plugin/radius", binaryMessenger: registrar.messenger())
    let instance = CornerRadiusPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    events.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getScreenRadius":
      if #available(iOS 26.0, *) {
        if let radii = CornerRadiusPlugin.displayCornerRadii() {
          result([
            "topLeft": radii.topLeft,
            "topRight": radii.topRight,
            "bottomLeft": radii.bottomLeft,
            "bottomRight": radii.bottomRight,
          ])
          return
        }
      }
      result(nil)
    case "getDeviceInfo":
      result([
        "modelIdentifier": UIDevice.current.modelIdentifier,
        "deviceType": CornerRadiusPlugin.deviceTypeString(),
      ])
    default:
      result(FlutterMethodNotImplemented)
    }
  }

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

  @available(iOS 26.0, *)
  static func displayCornerRadii() -> (topLeft: Double, topRight: Double, bottomLeft: Double, bottomRight: Double)? {
    // On multi-display devices such as iPhone Duo apps run in a key window
    // attached to the currently active screen. Pick *that* window rather than
    // the first connected scene, which may belong to a different screen.
    let window = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first(where: { $0.isKeyWindow }) ??
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first
    guard let window else { return nil }

    // A container-concentric corner configuration resolves against the view's
    // container. At the top level the container is the display itself, which
    // yields the real per-corner display radius on iOS 26 and later.
    let view = UIView(frame: window.bounds)
    view.cornerConfiguration = .corners(
      topLeftRadius: .containerConcentric(),
      topRightRadius: .containerConcentric(),
      bottomLeftRadius: .containerConcentric(),
      bottomRightRadius: .containerConcentric()
    )
    window.addSubview(view)
    view.setNeedsLayout()
    view.layoutIfNeeded()

    let topLeft = Double(view.effectiveRadius(corner: .topLeft))
    let topRight = Double(view.effectiveRadius(corner: .topRight))
    let bottomLeft = Double(view.effectiveRadius(corner: .bottomLeft))
    let bottomRight = Double(view.effectiveRadius(corner: .bottomRight))

    view.removeFromSuperview()

    // Guard against obviously invalid values.
    if topLeft <= 0 || topRight <= 0 || bottomLeft <= 0 || bottomRight <= 0 {
      return nil
    }
    return (topLeft, topRight, bottomLeft, bottomRight)
  }

  // MARK: - FlutterStreamHandler

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    lastEmittedKey = nil
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()

    let notificationNames: [NSNotification.Name] = [
      UIScene.didActivateNotification,
      UIScene.willEnterForegroundNotification,
      UIApplication.didChangeStatusBarOrientationNotification,
      UIApplication.didChangeStatusBarFrameNotification,
      UIDevice.orientationDidChangeNotification,
      UIWindow.didBecomeKeyNotification,
    ]
    for name in notificationNames {
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(activeSceneDidChange),
        name: name,
        object: nil
      )
    }

    // Polling is deliberately used as a safety net for hinge state and other
    // transitions that do not always issue a distinct, observable notification.
    pollTimer = Timer(timeInterval: 0.25, target: self, selector: #selector(pollForRadiusUpdates), userInfo: nil, repeats: true)
    if let pollTimer {
      RunLoop.main.add(pollTimer, forMode: .common)
    }

    emitCurrentRadius()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    pollTimer?.invalidate()
    pollTimer = nil
    UIDevice.current.endGeneratingDeviceOrientationNotifications()
    NotificationCenter.default.removeObserver(self)
    eventSink = nil
    lastEmittedKey = nil
    return nil
  }

  @objc private func activeSceneDidChange(_ notification: Notification?) {
    emitCurrentRadius()
  }

  @objc private func pollForRadiusUpdates() {
    emitCurrentRadius()
  }

  private func emitCurrentRadius() {
    guard let sink = eventSink else { return }

    let keyWindow = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first(where: { $0.isKeyWindow })

    var payload: [String: Any]?
    var emittedKey: String
    if #available(iOS 26.0, *) {
      if let radii = CornerRadiusPlugin.displayCornerRadii() {
        payload = [
          "topLeft": radii.topLeft,
          "topRight": radii.topRight,
          "bottomLeft": radii.bottomLeft,
          "bottomRight": radii.bottomRight,
        ]
        emittedKey = "\(keyWindow.map { ObjectIdentifier($0) }?.hashValue ?? 0):\(radii.topLeft),\(radii.topRight),\(radii.bottomLeft),\(radii.bottomRight)"
      } else {
        payload = nil
        emittedKey = "nil:\(keyWindow.map { ObjectIdentifier($0) }?.hashValue ?? 0)"
      }
    } else {
      payload = nil
      emittedKey = "unsupported:\(keyWindow.map { ObjectIdentifier($0) }?.hashValue ?? 0)"
    }

    // Avoid spamming duplicate identical events while polling.
    guard emittedKey != lastEmittedKey else { return }
    lastEmittedKey = emittedKey

    if let payload {
      sink(payload)
    } else {
      sink(nil)
    }
  }
}
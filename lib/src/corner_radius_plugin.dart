import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'corner_radius_plugin_platform_interface.dart';
part 'corner_radius_plugin_method_channel.dart';

class CornerRadius {
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  static double _defaultRadius = 0;

  factory CornerRadius._default() => CornerRadius._all(_defaultRadius);

  const CornerRadius._all(double value)
    : topLeft = value,
      topRight = value,
      bottomLeft = value,
      bottomRight = value;

  /// Creates a [CornerRadius] instance with specified radii for each corner.
  ///
  /// All parameters are required.
  ///
  /// Example:
  /// ```dart
  /// const CornerRadius(topLeft: 10.0, topRight: 10.0, bottomLeft: 5.0, bottomRight: 5.0);
  /// ```
  const CornerRadius({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  factory CornerRadius._fromMap(Map<String, double> map) => CornerRadius(
    topLeft: map['topLeft'] ?? 0,
    topRight: map['topRight'] ?? 0,
    bottomLeft: map['bottomLeft'] ?? 0,
    bottomRight: map['bottomRight'] ?? 0,
  );
}

/// A plugin that provides information about the screen's corner radii.
///
/// This class offers methods to retrieve the physical corner radii of the
/// device screen, especially useful for devices with rounded corners (e.g., iPhones).
/// It also allows setting a default radius for cases where specific device
/// information is not available or applicable.
class CornerRadiusPlugin {
  static CornerRadius _screenRadius = CornerRadius._default();

  /// Sets the default radius to be used when specific corner radius information
  /// cannot be retrieved for a device.
  ///
  /// [radius] The default radius value to set.
  static void setDefaultRadius(double radius) {
    CornerRadius._defaultRadius = radius;
  }

  /// Returns the currently stored screen radius.
  ///
  /// This value is updated after calling the [init] method.
  static CornerRadius get screenRadius => _screenRadius;

  /// Initializes the CornerRadius plugin.
  ///
  /// This static method initializes the plugin and returns a [Future] that completes
  /// with a [CornerRadius] instance when the initialization is done.
  ///
  /// Returns a [Future<CornerRadius>] representing the initialized plugin instance.
  static Future<CornerRadius> init({double defaultRadius = 0}) async {
    CornerRadius._defaultRadius = defaultRadius;
    // Ensure bindings are initialized before any asset/binary messenger usage.
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isIOS) {
      final info = await CornerRadiusPluginPlatform._instance.getDeviceInfo();
      if (info == null ||
          info["modelIdentifier"] == null ||
          info["deviceType"] == null) {
        _screenRadius = CornerRadius._default();
        return _screenRadius;
      }
      final modelId = info["modelIdentifier"]!;
      final deviceType = info["deviceType"]!;
      String jsonStr;
      try {
        jsonStr = await rootBundle.loadString(
          'packages/corner_radius_plugin/assets/bezel.min.json',
        );
      } catch (_) {
        _screenRadius = CornerRadius._default();
        return _screenRadius;
      }
      final radius = await compute(_lookupBezelForModel, {
        'modelId': modelId,
        'deviceType': deviceType,
        'json': jsonStr,
      });
      if (radius == null || radius == 0) {
        _screenRadius = CornerRadius._default();
        return _screenRadius;
      }
      _screenRadius = CornerRadius._all(radius);
      return _screenRadius;
    } else {
      final map = await CornerRadiusPluginPlatform._instance.getScreenRadius();
      if (map == null) {
        _screenRadius = CornerRadius._default();
        return _screenRadius;
      }
      _screenRadius = CornerRadius._fromMap(map);
      return _screenRadius;
    }
  }
}

// Loads bezel.min.json from assets and returns the "bezel" value for given model
// This function runs on a background isolate to avoid blocking the main thread
Future<double?> _lookupBezelForModel(Map<String, dynamic> params) async {
  final modelId = params['modelId'] as String;
  final deviceType = params['deviceType'] as String;
  // final RootIsolateToken? token = params['token'] as RootIsolateToken?;
  final String providedJson = params['json'] as String;

  try {
    // Prefer JSON provided from the main isolate to avoid asset loading here.
    final dynamic decoded = json.decode(providedJson);
    if (decoded is! Map<String, dynamic>) return 0;

    // Dataset shape:
    // { "_metadata": {...}, "devices": { "iPhone": { "iPhone14,2": { "bezel": 47.33 } }, "iPad": {...} } }
    final devicesRoot = decoded['devices'];
    if (devicesRoot is! Map<String, dynamic>) return 0;

    double? parseBezel(dynamic deviceEntry) {
      if (deviceEntry is! Map<String, dynamic>) return null;
      final dynamic v =
          deviceEntry['bezel'] ??
          deviceEntry['bazel'] ??
          deviceEntry['radius'] ??
          deviceEntry['cornerRadius'];
      if (v is num) return v.toDouble();
      if (v is String) {
        final d = double.tryParse(v);
        if (d != null) return d;
      }
      return null;
    }

    // 1) Try direct type -> model lookup
    final typeMap = devicesRoot[deviceType];
    if (typeMap is Map<String, dynamic>) {
      final device = typeMap[modelId];
      final parsed = parseBezel(device);
      if (parsed != null) return parsed;
    }

    // 2) Try well-known iOS families if deviceType didn't match nesting
    const fallbackFamilies = ['iPhone', 'iPad', 'iPod'];
    for (final fam in fallbackFamilies) {
      final famMap = devicesRoot[fam];
      if (famMap is Map<String, dynamic>) {
        final device = famMap[modelId];
        final parsed = parseBezel(device);
        if (parsed != null) return parsed;
      }
    }

    // 3) Last resort: search all types for the modelId
    for (final entry in devicesRoot.values) {
      if (entry is Map<String, dynamic>) {
        final device = entry[modelId];
        final parsed = parseBezel(device);
        if (parsed != null) return parsed;
      }
    }
  } catch (e, st) {
    debugPrint('Error loading bezel data: $e\n$st');
    return 0;
  }
  return 0;
}

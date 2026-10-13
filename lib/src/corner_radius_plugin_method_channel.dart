part of 'corner_radius_plugin.dart';

/// An implementation of [CornerRadiusPluginPlatform] that uses method channels.
class _MethodChannelCornerRadiusPlugin extends CornerRadiusPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('corner_radius_plugin');

  /// Event channel used for live corner radius updates.
  @visibleForTesting
  final eventChannel = const EventChannel('corner_radius_plugin/radius');

  @override
  Future<Map<String, double>?> getScreenRadius() async {
    final Map<Object?, Object?>? res = await methodChannel.invokeMethod(
      'getScreenRadius',
    );
    if (res == null) return null;
    return res.map(
      (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
    );
  }

  @override
  Stream<Map<String, double>?> getScreenRadiusStream() {
    return eventChannel.receiveBroadcastStream().map((event) {
      if (event == null) return null;
      final raw = Map<String, dynamic>.from(event as Map);
      return raw.map(
        (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
      );
    });
  }

  @override
  Future<Map<String, String>?> getDeviceInfo() async {
    final res = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'getDeviceInfo',
    );
    if (res == null) return null;
    return res.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
  }
}

part of 'corner_radius_plugin.dart';

/// An implementation of [CornerRadiusPluginPlatform] that uses method channels.
class _MethodChannelCornerRadiusPlugin extends CornerRadiusPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('corner_radius_plugin');

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
  Future<Map<String, String>?> getDeviceInfo() async {
    final res = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'getDeviceInfo',
    );
    if (res == null) return null;
    return res.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
  }
}

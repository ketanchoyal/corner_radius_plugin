part of 'corner_radius_plugin.dart';

abstract class CornerRadiusPluginPlatform extends PlatformInterface {
  /// Constructs a CornerRadiusPluginPlatform.
  CornerRadiusPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static CornerRadiusPluginPlatform _instance =
      _MethodChannelCornerRadiusPlugin();

  /// The default instance of [CornerRadiusPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelCornerRadiusPlugin].
  @visibleForTesting
  static CornerRadiusPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CornerRadiusPluginPlatform] when
  /// they register themselves.
  static set instance(CornerRadiusPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, double>?> getScreenRadius() {
    throw UnimplementedError('getScreenRadius() has not been implemented.');
  }

  /// Stream of native screen corner radius maps.
  ///
  /// On platforms that cannot emit native updates (or before a listener is
  /// attached) this stream may be empty.
  Stream<Map<String, double>?> getScreenRadiusStream() {
    return const Stream.empty();
  }

  Future<Map<String, String>?> getDeviceInfo() {
    throw UnimplementedError('getDeviceInfo() has not been implemented.');
  }
}

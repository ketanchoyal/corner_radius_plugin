import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:corner_radius_plugin/src/corner_radius_plugin.dart';

class MockCornerRadiusPluginPlatform
    with MockPlatformInterfaceMixin
    implements CornerRadiusPluginPlatform {
  @override
  Future<Map<String, double>?> getScreenRadius() => Future.value({
    'topLeft': 10,
    'topRight': 10,
    'bottomLeft': 10,
    'bottomRight': 10,
  });

  @override
  Future<Map<String, String>?> getDeviceInfo() async => {
    'modelIdentifier': 'iPhone14,2',
    'deviceType': 'iPhone',
  };
}

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('get screen radius via API on Android', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    MockCornerRadiusPluginPlatform fakePlatform =
        MockCornerRadiusPluginPlatform();
    CornerRadiusPluginPlatform.instance = fakePlatform;

    final res = await CornerRadiusPlugin.init();
    expect(res, isNotNull);
    expect(res.topLeft, 10);
    expect(res.topRight, 10);
    expect(res.bottomLeft, 10);
    expect(res.bottomRight, 10);
  });

  test('default radius on unsupported platforms', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final res = await CornerRadiusPlugin.init(defaultRadius: 5.0);
    expect(res, isNotNull);
    expect(res.topLeft, 5.0);
    expect(res.topRight, 5.0);
    expect(res.bottomLeft, 5.0);
    expect(res.bottomRight, 5.0);
  });
}

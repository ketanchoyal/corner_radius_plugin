import 'package:flutter_test/flutter_test.dart';
import 'package:corner_radius_plugin/src/corner_radius_plugin.dart';

class MockCornerRadiusPluginPlatform implements CornerRadiusPluginPlatform {
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
  test('get screen radius via API', () async {
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
}

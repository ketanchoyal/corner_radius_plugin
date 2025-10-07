import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:corner_radius_plugin/src/corner_radius_plugin.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('corner_radius_plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return {
            'topLeft': 8.0,
            'topRight': 8.0,
            'bottomLeft': 8.0,
            'bottomRight': 8.0,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getScreenRadius via method channel', () async {
    final platform = CornerRadiusPluginPlatform.instance;
    final res = await platform.getScreenRadius();
    expect(res, isNotNull);
    expect(res!['topLeft'], 8.0);
  });
}

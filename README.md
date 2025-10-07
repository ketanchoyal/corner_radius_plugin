# corner_radius_plugin

Flutter plugin to get the current device screen corner radius on Android and iOS.

- **Android**: uses Android 12+ `RoundedCorner` via `WindowInsets`, with fallback to the system dimen `rounded_corner_radius` when available.
- **iOS**: integrates a BezelKit hook for accurate device bezels

Inspired by and Android logic adapted from `screen_corner_radius` [GitHub repo](https://github.com/ivangalkindeveloper/screen_corner_radius).
For iOS bezel data, see `BezelKit` [GitHub repo](https://github.com/markbattistella/BezelKit) and documentation at `swiftpackageindex.com/markbattistella/BezelKit/documentation`.

## Install

Add to your `pubspec.yaml`:

```yaml
dependencies:
  corner_radius_plugin: any
```

## Usage

Initialize during app startup, e.g. in `main()` or `initState()`.
```dart
import 'package:corner_radius_plugin/corner_radius_plugin.dart';

final screenRadius = await CornerRadiusPlugin.init();
if (screenRadius != null) {
  print('TL: ${screenRadius.topLeft}');
}
```

Get radius
```dart
final screenRadius =  CornerRadiusPlugin.screenRadius;
```

Setting default value
```dart
CornerRadiusPlugin.setDefaultRadius(5.0);
```


### iOS: Bezel data via BezelKit JSON

The plugin bundles `bezel.min.json` from BezelKit and looks up the radius by device model identifier (e.g. `iPhone14,2`). The JSON is auto-updated weekly via GitHub Actions.

- Source JSON: [bezel.min.json](https://github.com/markbattistella/BezelKit/blob/main/Sources/BezelKit/Resources/bezel.min.json)
- Auto updater workflow: `.github/workflows/update_bezel_json.yml`

At runtime the plugin:
- Reads `assets/bezel.min.json` (auto-refreshed weekly)
- Gets the current model with `getModelIdentifier` platform method on iOS
- Returns the device bezel value using "bezel" (or legacy "bazel") key; Android uses native API, iOS uses JSON lookup

### Android Notes

On Android 12 (API 31)+ the radii are per-corner. On lower APIs, a single value from `rounded_corner_radius` is used when available; otherwise zeros are returned.

## Attribution

- Android approach adapted from `screen_corner_radius` [repo](https://github.com/ivangalkindeveloper/screen_corner_radius).
- iOS bezel dataset and approach via `BezelKit` [repo](https://github.com/markbattistella/BezelKit).



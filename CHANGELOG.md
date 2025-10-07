## 0.0.2 - 2025-10-07

Device dataset Updated

## 0.0.1

- Initial release.

##### Highlights
- Public API: `CornerRadiusPlugin.init()`, `CornerRadiusPlugin.screenRadius`,
	and `CornerRadiusPlugin.setDefaultRadius(double)` to initialize, read and
	configure a fallback radius.
- Data model: `CornerRadius` value object with per-corner radii
	(`topLeft`, `topRight`, `bottomLeft`, `bottomRight`).
- Android support: Uses Android 12+ RoundedCorner APIs (via WindowInsets)
	to return per-corner radii. On older Android versions falls back to the
	`rounded_corner_radius` system dimension when available; otherwise returns
	zeros (or the configured default radius).
- iOS support: Bundles `assets/bezel.min.json` (BezelKit dataset) and looks up
	device-specific bezel/corner radius by model identifier (e.g. `iPhone14,2`).
	The JSON lookup runs on a background isolate to avoid blocking the UI.
- Method channel platform interface: `getScreenRadius()` and `getDeviceInfo()`
	are implemented via method channels so platform implementations can be
	overridden in tests or by federated plugins.

#### Behavior and usage notes
- Call `await CornerRadiusPlugin.init()` early in app startup (for example in
	`main()` or `initState`) to populate `CornerRadiusPlugin.screenRadius`.
- On iOS the plugin queries the native platform for the device model and
	device type then performs a JSON lookup in `bezel.min.json`. If the lookup
	fails or returns zero, the configured default radius will be used.
- Use `CornerRadiusPlugin.setDefaultRadius(5.0)` to set a non-zero fallback
	radius for devices where native APIs or dataset entries are unavailable.

#### Assets and maintenance
- `assets/bezel.min.json` is included in the package and is intended to be
	periodically updated (the project contains an auto-update workflow in the
	example README). The plugin reads the JSON from package assets at runtime.

#### Attribution
- Android logic adapted from `screen_corner_radius` by
	ivangalkindeveloper: https://github.com/ivangalkindeveloper/screen_corner_radius
- iOS bezel dataset and lookup approach via `BezelKit` by markbattistella:
	https://github.com/markbattistella/BezelKit

##### Developer notes (internal)
- The Dart implementation exposes a platform interface in
	`lib/src/corner_radius_plugin_platform_interface.dart` and a method channel
	implementation in `lib/src/corner_radius_plugin_method_channel.dart`.
- The lookup helper `_lookupBezelForModel` is run on a background isolate via
	`compute()` and loads the JSON from
	`packages/corner_radius_plugin/assets/bezel.min.json`.


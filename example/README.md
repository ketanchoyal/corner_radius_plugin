# corner_radius_plugin_example

Demonstrates how to use the corner_radius_plugin plugin.

## Getting Started

This example initializes the plugin once at startup and then reads the value
from `CornerRadiusPlugin.screenRadius`.

Key points:

- Call `await CornerRadiusPlugin.init(defaultRadius: 12)` once (for example in
	`initState`).
- Use `CornerRadiusPlugin.screenRadius` for the current corner values.
- Provide a non-zero `defaultRadius` as a fallback for unsupported platforms or
	unknown devices.

Run the example from the package root with Flutter as usual.

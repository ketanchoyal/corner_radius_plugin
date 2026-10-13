import 'package:flutter/material.dart';
import 'package:corner_radius_plugin/corner_radius_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CornerRadius _screenRadius = const CornerRadius(
    topLeft: 12,
    topRight: 12,
    bottomLeft: 12,
    bottomRight: 12,
  );
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize once with a non-zero fallback radius for unsupported devices.
    CornerRadiusPlugin.init(defaultRadius: 12).then((radius) {
      if (!mounted) return;
      setState(() {
        _screenRadius = radius;
        _initialized = true;
      });
    });
    // Keep the displayed radius in sync with the active screen.
    CornerRadiusPlugin.screenRadiusStream.listen((radius) {
      if (!mounted) return;
      setState(() {
        _screenRadius = radius;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Corner Radius Plugin Example')),
        body: SafeArea(
          child: !_initialized
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(_screenRadius.topLeft),
                              topRight: Radius.circular(_screenRadius.topRight),
                              bottomLeft: Radius.circular(
                                _screenRadius.bottomLeft,
                              ),
                              bottomRight: Radius.circular(
                                _screenRadius.bottomRight,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Stack(
                              children: [
                                _CornerValue(
                                  alignment: Alignment.topLeft,
                                  value: _screenRadius.topLeft,
                                ),
                                _CornerValue(
                                  alignment: Alignment.topRight,
                                  value: _screenRadius.topRight,
                                ),
                                _CornerValue(
                                  alignment: Alignment.bottomLeft,
                                  value: _screenRadius.bottomLeft,
                                ),
                                _CornerValue(
                                  alignment: Alignment.bottomRight,
                                  value: _screenRadius.bottomRight,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'Initialized with defaultRadius: 12\n'
                            'Current values (TL, TR, BL, BR): '
                            '${_screenRadius.topLeft.toStringAsFixed(2)}, '
                            '${_screenRadius.topRight.toStringAsFixed(2)}, '
                            '${_screenRadius.bottomLeft.toStringAsFixed(2)}, '
                            '${_screenRadius.bottomRight.toStringAsFixed(2)}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _CornerValue extends StatelessWidget {
  const _CornerValue({required this.alignment, required this.value});

  final Alignment alignment;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Text(
        value.toStringAsFixed(2),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 28),
      ),
    );
  }
}

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
  late final Future<CornerRadius> _radiusFuture;

  @override
  void initState() {
    super.initState();
    // Initialize once with a non-zero fallback radius for unsupported devices.
    _radiusFuture = CornerRadiusPlugin.init(defaultRadius: 12);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Corner Radius Plugin Example')),
        body: SafeArea(
          child: FutureBuilder(
            future: _radiusFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data;
              if (data == null) {
                return const Center(child: Text('No data'));
              }

              // Demonstrate the static getter after init.
              final screenRadius = CornerRadiusPlugin.screenRadius;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenRadius.topLeft),
                            topRight: Radius.circular(screenRadius.topRight),
                            bottomLeft: Radius.circular(
                              screenRadius.bottomLeft,
                            ),
                            bottomRight: Radius.circular(
                              screenRadius.bottomRight,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Stack(
                            children: [
                              _CornerValue(
                                alignment: Alignment.topLeft,
                                value: screenRadius.topLeft,
                              ),
                              _CornerValue(
                                alignment: Alignment.topRight,
                                value: screenRadius.topRight,
                              ),
                              _CornerValue(
                                alignment: Alignment.bottomLeft,
                                value: screenRadius.bottomLeft,
                              ),
                              _CornerValue(
                                alignment: Alignment.bottomRight,
                                value: screenRadius.bottomRight,
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
                          '${screenRadius.topLeft.toStringAsFixed(2)}, '
                          '${screenRadius.topRight.toStringAsFixed(2)}, '
                          '${screenRadius.bottomLeft.toStringAsFixed(2)}, '
                          '${screenRadius.bottomRight.toStringAsFixed(2)}',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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

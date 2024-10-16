import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_parental_control/flutter_parental_control.dart';
import 'package:flutter_parental_control_example/child_location_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoggingServicePage(),
    );
  }
}

class LoggingServicePage extends StatefulWidget {
  const LoggingServicePage({super.key});

  @override
  State<LoggingServicePage> createState() => _LoggingServicePageState();
}

class _LoggingServicePageState extends State<LoggingServicePage> {
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    Platform.isAndroid ? android() : ios();
  }

  Future<void> android() async {
    ParentalControl.requestPermission(Permission.location);
    ParentalControl.askParent();
  }

  Future<void> ios() async {
    final deviceInfo = await ParentalControl.getDeviceInfo();
    debugPrint(deviceInfo.deviceApiLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Log Value'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChildLocationScreen()));
              },
              child: const Text('Set Log Value'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_parental_control/flutter_parental_control.dart';

import 'child_location_screen.dart';

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
  late DeviceInfo deviceInfo;

  @override
  void initState() {
    super.initState();
    Platform.isAndroid ? android() : ios();
  }

  Future<void> android() async {
    // ParentalControl.requestPermission(Permission.deviceAdmin);
  }

  Future<void> ios() async {
    deviceInfo = await ParentalControl.getDeviceInfo();
    await ParentalControl.scheduleMonitorSettings(Schedule(isMonitoring: true));
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
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChildLocationScreen()));
              },
              child: const Text('Set Log Value'),
            ),
            ElevatedButton(
                onPressed: () async {
                  await ParentalControl.requestPermission(
                      Permission.deviceAdmin);
                },
                child: const Text("Lấy thông tin từ native"))
          ],
        ),
      ),
    );
  }
}

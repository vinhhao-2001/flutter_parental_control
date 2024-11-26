import 'dart:io';
import 'package:flutter/cupertino.dart';
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
    ParentalControl.askParent((packageName, appName) async {
      _chooseTimeRequest(packageName, appName);
    });
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
              decoration: const InputDecoration(labelText: 'Giá trị trả về'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChildLocationScreen()));
              },
              child: const Text('Bản đồ'),
            ),
            ElevatedButton(
                onPressed: () async {
                  await ParentalControl.requestPermission(
                      Permission.accessibility);
                  await ParentalControl.setListAppBlocked(
                      [AppBlock(packageName: 'com.android.camera2')]);
                },
                child: const Text("Lấy thông tin từ native"))
          ],
        ),
      ),
    );
  }

  void _chooseTimeRequest(String packageName, String appName) {
    int selectedHour = 0;
    int selectedMinute = 0;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                contentPadding: const EdgeInsets.all(20),
                title: Text("Yêu cầu sử dụng $appName trong thời gian"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                                initialItem: selectedHour),
                            looping: true,
                            itemExtent: 32.0,
                            onSelectedItemChanged: (int value) =>
                                setState(() => selectedHour = value),
                            children: List<Widget>.generate(
                                24,
                                (int index) =>
                                    Center(child: Text(index.toString()))),
                          ),
                        ),
                        const Text('Giờ'),
                        const Text(':'),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedMinute,
                            ),
                            looping: true,
                            itemExtent: 32.0,
                            onSelectedItemChanged: (int value) =>
                                setState(() => selectedMinute = value),
                            children: List<Widget>.generate(
                                60,
                                (int index) => Center(
                                    child: Text(
                                        index.toString().padLeft(2, '0')))),
                          ),
                        ),
                        const Text('Phút'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Dialog buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Huỷ',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Xong',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}

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
  List<AppDetail> a = [];

  @override
  void initState() {
    super.initState();
    Platform.isAndroid ? android() : ios();
    ParentalControl.requestPermission(Permission.accessibility);
    ParentalControl.requestPermission(Permission.usageState);
  }

  Future<void> android() async {
    ParentalControl.askParent((packageName, appName) async {
      print(packageName);
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
                  final a = await ParentalControl.getWebHistory();
                  a.forEach((b) {
                    print(b.toMap());
                  });
                },
                child: const Text("Lấy thông tin từ native")),
            a.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                        itemCount: a.length,
                        itemBuilder: (context, index) => ListTile(
                              title: Text(a[index].packageName),
                              subtitle: Text(a[index].appName),
                            )))
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  void _chooseTimeRequest(String packageName, String appName) {
    showDialog(
      context: context,
      builder: (context) {
        int selectedHour = 1;
        int selectedMinute = 0;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // tiêu đề
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 24, right: 24, bottom: 8, left: 24),
                    child: Text(
                      'Yêu cầu sử dụng $appName trong thời gian:',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                  ),
                  // mô tả thời gian chọn
                  Container(
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: Colors.black12, width: 0.5))),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thời gian',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        Text(
                          _formatTimeDisplay(selectedHour, selectedMinute),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 150,
                    child: Row(
                      children: [
                        // Giờ
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedHour,
                            ),
                            itemExtent: 30,
                            magnification: 1.3,
                            useMagnifier: true,
                            onSelectedItemChanged: (value) {
                              setState(() {
                                selectedHour = value;
                              });
                            },
                            children: List.generate(24, (index) {
                              return Center(
                                child: Text(
                                  '$index',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: index == selectedHour
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const Text('Giờ'),
                        // Phút
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                                initialItem: selectedMinute),
                            itemExtent: 32,
                            magnification: 1.2,
                            useMagnifier: true,
                            onSelectedItemChanged: (value) {
                              setState(() {
                                selectedMinute = value;
                              });
                            },
                            children: List.generate(60, (index) {
                              return Center(
                                child: Text(
                                  '$index',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: index == selectedMinute
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const Text('Phút'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                          ),
                          child: const Text(
                            'Huỷ bỏ',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Đồng ý'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _formatTimeDisplay(int hour, int minute) {
    if (hour == 0 && minute == 0) {
      return '0 phút';
    } else if (hour == 0) {
      return '$minute phút';
    } else if (minute == 0) {
      return '$hour giờ';
    } else {
      return '$hour giờ $minute phút';
    }
  }
}

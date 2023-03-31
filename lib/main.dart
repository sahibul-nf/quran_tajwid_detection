import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:quran_tajwid_detection/controllers/detection_controller.dart';

import 'pages/detection_page.dart';
import 'pages/realtime_detection_page.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quran Tajwid Detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MenuDetection(),
    );
  }
}

class MenuDetection extends StatelessWidget {
  const MenuDetection({super.key});

  @override
  Widget build(BuildContext context) {
    DetectionController.loadTfliteModel();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              'Quran Tajweed \nDetector',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetectionPage(),
                      ),
                    );
                  },
                  child: const Text("Detect from Image"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RealtimeDetectionPage(),
                      ),
                    );
                  },
                  child: const Text("Realtime Detection"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

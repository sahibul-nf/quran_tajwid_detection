import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class DetectionController {
  static loadTfliteModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
      );
    } on PlatformException {
      debugPrint("Failed to load the model");
    }
  }

  static Future<List?> detectObject({required String imagePath}) async {
    final result = await Tflite.detectObjectOnImage(
      path: imagePath, // required
      model: "SSDMobileNet",
      imageMean: 127.5,
      imageStd: 127.5,
      threshold: 0.4, // defaults to 0.1
      numResultsPerClass: 10, // defaults to 5
      asynch: true, // defaults to true
    );

    return result;
  }

  static Future<List?> detectImage({required String imagePath}) async {
    final result = await Tflite.runModelOnImage(
      path: imagePath, // required
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 2, // defaults to 5
      threshold: 0.5, // defaults to 0.1
      asynch: true, // defaults to true
    );

    return result;
  }
}

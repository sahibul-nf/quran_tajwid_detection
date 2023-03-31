import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quran_tajwid_detection/controllers/detection_controller.dart';
import 'package:quran_tajwid_detection/controllers/image_picker_controller.dart';

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  bool isLoading = false;
  File? imageFile;
  List? listResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tajweed Detection'),
      ),
      body: Center(
        child: listResult != null
            ? _ResultDetection(
                file: imageFile,
                result: '${listResult![0]['label']}'
                    .replaceAll(RegExp(r'[0-9]'), ''),
                onPressed: () {
                  setState(() {
                    listResult = null;
                    imageFile = null;
                    isLoading = false;
                  });
                },
              )
            : _InitialState(
                onTakeFromCameraTaped: () {
                  takeImage(imageSource: ImageSource.camera);
                },
                onTakeFromGalleryTaped: () {
                  takeImage(imageSource: ImageSource.gallery);
                },
                onProcessImageTaped: () {
                  processImage();
                },
                imageFile: imageFile,
              ),
      ),
    );
  }

  takeImage({required ImageSource imageSource}) async {
    ImagePickerController.pickImage(imageSource: imageSource).then((value) {
      setState(() {
        imageFile = value;
        debugPrint(imageFile.toString());
      });
    });
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (listResult == null) return [];

    double factorX = screen.width;
    double factorY = screen.height;

    Color colorPick = Colors.pink;

    return listResult!.map((result) {
      return Positioned(
        left: result["rect"]["x"] * factorX,
        top: result["rect"]["y"] * factorY,
        width: result["rect"]["w"] * factorX,
        height: result["rect"]["h"] * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['detectedClass']} ${(result['confidenceInClass'] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.black,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Processing image...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  processImage() async {
    showLoadingDialog();

    await Future.delayed(
      const Duration(seconds: 2),
      () => Navigator.pop(context),
    );

    if (imageFile != null) {
      DetectionController.detectObject(imagePath: imageFile!.path)
          .then((value) {
        setState(() {
          isLoading = false;
          listResult?.clear();
          listResult = value;
          debugPrint('outputs: $listResult');
        });
      });
    }
  }
}

class _InitialState extends StatelessWidget {
  const _InitialState(
      {required this.onTakeFromGalleryTaped,
      required this.onTakeFromCameraTaped,
      required this.imageFile,
      required this.onProcessImageTaped});
  final void Function() onTakeFromGalleryTaped;
  final void Function() onTakeFromCameraTaped;
  final void Function() onProcessImageTaped;
  final File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(30),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey.shade200,
            ),
            padding: const EdgeInsets.all(5),
            child: imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      imageFile!,
                      fit: BoxFit.contain,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 100,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Image Preview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 20),
        if (imageFile != null)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: onProcessImageTaped,
              icon: const Icon(Icons.photo_library),
              label: const Text("Process Image"),
            ),
          )
        else
          Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: onTakeFromGalleryTaped,
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Take from Gallery"),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: onTakeFromCameraTaped,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take from Camera"),
                ),
              ),
            ],
          ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _TakeImageOption extends StatelessWidget {
  const _TakeImageOption({required this.onTaped, required this.text});
  final void Function()? onTaped;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTaped,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 20,
        ),
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.image_outlined,
              size: 50,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text("Take a picture of the Quran"),
          ],
        ),
      ),
    );
  }
}

class _ResultDetection extends StatelessWidget {
  const _ResultDetection({
    required this.file,
    required this.onPressed,
    required this.result,
  });
  final File? file;
  final void Function()? onPressed;
  final String result;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.file(
            file!,
            fit: BoxFit.contain,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Detection result:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text("Restart"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

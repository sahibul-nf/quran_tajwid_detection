import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerController {
  static final _imagePicker = ImagePicker();

  static Future<File?> pickImage({required ImageSource imageSource}) async {
    final pickedFile =
        await _imagePicker.pickImage(source: imageSource);

    if (pickedFile != null) return File(pickedFile.path);

    return null;
  }
}

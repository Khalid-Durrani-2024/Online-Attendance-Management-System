import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

File? PickeFileFromStorage;

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.photos,
  ].request();
}

Future<void> pickImage(ImageSource source) async {
  await requestPermissions();
  print(requestPermissions());
  final picker = ImagePicker();
  PickeFileFromStorage = (await picker.pickImage(source: source)) as File?;

  if (PickeFileFromStorage != null) {
    // A file was picked.
    // You can now use the pickedFile.path to access the image.

    // Use the imagePath as needed (e.g., display it, upload it, etc.).
  } else {
    // User canceled the image picking.
  }
}

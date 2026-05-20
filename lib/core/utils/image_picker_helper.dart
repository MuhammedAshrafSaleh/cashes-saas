// lib/core/utils/image_picker_helper.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cashes/core/errors/exceptions.dart';

class ImagePickerHelper {
  ImagePickerHelper._();

  static final _picker = ImagePicker();

  static Future<Uint8List?> pickFromBottomSheet(BuildContext context) async {
    ImageSource? source;

    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('الكاميرا'),
              onTap: () {
                source = ImageSource.camera;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض'),
              onTap: () {
                source = ImageSource.gallery;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    final status = source == ImageSource.camera
        ? await Permission.camera.request()
        : await Permission.photos.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      throw const PermissionException('تعذر الوصول إلى الصور أو الكاميرا');
    }

    final file = await _picker.pickImage(source: source!);
    return file?.readAsBytes();
  }
}

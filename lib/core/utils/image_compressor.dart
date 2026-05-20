// lib/core/utils/image_compressor.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cashes/core/constants/app_durations.dart';
import 'package:cashes/core/errors/exceptions.dart';

class ImageCompressor {
  ImageCompressor._();

  static Future<Uint8List> compressInIsolate(Uint8List bytes) {
    return compute(_compressImageInIsolate, bytes)
        .timeout(
          AppDurations.imageCompressTimeout,
          onTimeout: () => throw const ValidationException('imageProcessFailed'),
        );
  }
}

Future<Uint8List> _compressImageInIsolate(Uint8List bytes) async {
  Uint8List? result = await FlutterImageCompress.compressWithList(
    bytes,
    quality: 70,
    minWidth: 1080,
    minHeight: 1080,
    format: CompressFormat.jpeg,
    autoCorrectionAngle: true,
  );

  // If still > 500KB, run second pass at quality 50
  if (result.length > 500 * 1024) {
    result = await FlutterImageCompress.compressWithList(
      result,
      quality: 50,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.jpeg,
      autoCorrectionAngle: true,
    );
  }

  return result;
}

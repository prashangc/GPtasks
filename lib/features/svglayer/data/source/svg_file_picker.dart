import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutterfirebaseposts/features/svglayer/data/model/picked_svg_file.dart';

abstract class SvgFilePicker {
  Future<PickedSvgFile?> pickSvg();
}

class SvgFilePickerImpl implements SvgFilePicker {
  @override
  Future<PickedSvgFile?> pickSvg() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['svg'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final bytes = file.bytes ?? await _readBytesFromPath(file.path);
      if (bytes == null) return null;

      return PickedSvgFile(
        name: file.name,
        path: file.path ?? '',
        content: String.fromCharCodes(bytes),
      );
    } on PlatformException {
      return null;
    }
  }

  Future<List<int>?> _readBytesFromPath(String? path) async {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  }
}



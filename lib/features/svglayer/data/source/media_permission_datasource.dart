import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class MediaPermissionDataSource {
  Future<bool> requestMediaAccess() async {
    final photosStatus = await Permission.photos.request();
    if (_isGranted(photosStatus)) return true;

    final storageStatus = await Permission.storage.request();
    if (_isGranted(storageStatus)) return true;

    if (Platform.isAndroid) {
      final manageStatus = await Permission.manageExternalStorage.request();
      if (_isGranted(manageStatus)) return true;
    }

    return false;
  }

  bool _isGranted(PermissionStatus status) {
    return status.isGranted || status.isLimited;
  }
}

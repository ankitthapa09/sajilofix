import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';

class AppPermissions {
  const AppPermissions._();

  static Future<bool> ensureCamera(BuildContext context) async {
    return _ensure(context, permission: Permission.camera, name: 'Camera');
  }

  static Future<bool> ensurePhotos(BuildContext context) async {
    // iOS: photos. Android: permission_handler maps to storage/media.
    return _ensure(
      context,
      permission: Permission.photos,
      name: 'Photos',
      treatLimitedAsGranted: true,
    );
  }

  static Future<bool> ensureLocationWhenInUse(BuildContext context) async {
    return _ensure(
      context,
      permission: Permission.locationWhenInUse,
      name: 'Location',
    );
  }

  static Future<bool> _ensure(
    BuildContext context, {
    required Permission permission,
    required String name,
    bool treatLimitedAsGranted = false,
  }) async {
    var status = await permission.status;

    if (status.isGranted) return true;
    if (treatLimitedAsGranted && status.isLimited) return true;

    status = await permission.request();
    if (!context.mounted) return false;

    if (status.isGranted) return true;
    if (treatLimitedAsGranted && status.isLimited) return true;

    if (status.isPermanentlyDenied || status.isRestricted) {
      showMySnackBar(
        context: context,
        message: '$name permission is required. Please enable it in Settings.',
        isError: true,
        icon: Icons.settings,
        actionLabel: 'Settings',
        onAction: openAppSettings,
      );
      return false;
    }

    showMySnackBar(
      context: context,
      message: '$name permission was denied.',
      isError: true,
      icon: Icons.info_outline,
    );
    return false;
  }
}

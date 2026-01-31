import 'package:flutter/material.dart';

class AppPermissions {
  const AppPermissions._();

  static Future<bool> requestLocationWithChoice(BuildContext context) async {
    return true;
  }

  static Future<bool> ensureCamera(BuildContext context) async {
    return true;
  }

  static Future<bool> ensurePhotos(BuildContext context) async {
    return true;
  }

  static Future<bool> ensureLocationWhenInUse(BuildContext context) async {
    return true;
  }

  static Future<bool> ensureLocationAlways(BuildContext context) async {
    return true;
  }
}

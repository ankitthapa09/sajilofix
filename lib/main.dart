import 'package:flutter/material.dart';
import 'package:sajilofix/app/app.dart';
import 'package:sajilofix/core/services/hive/hive_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const ProviderScope(child: SajiloFix()));
}

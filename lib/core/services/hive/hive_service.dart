import 'package:hive_flutter/hive_flutter.dart';

import 'package:sajilofix/core/constants/hive_constants.dart';
import 'package:sajilofix/features/auth/data/models/local_user.dart';

class HiveService {
  HiveService._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(LocalUserAdapter().typeId)) {
      Hive.registerAdapter(LocalUserAdapter());
    }

    await Hive.openBox<LocalUser>(HiveBoxes.users);
    await Hive.openBox(HiveBoxes.session);

    _initialized = true;
  }

  static Box<LocalUser> usersBox() => Hive.box<LocalUser>(HiveBoxes.users);

  static Box sessionBox() => Hive.box(HiveBoxes.session);
}

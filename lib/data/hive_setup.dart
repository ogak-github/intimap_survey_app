import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:survey_app/utils/app_logger.dart';

class HiveSetup {
  static final HiveSetup _instance = HiveSetup._internal();

  factory HiveSetup() => _instance;

  HiveSetup._internal();

  static Future<void> init() async {
    MyLogger("Local database").i("Setup hive");
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    final box = await Hive.openBox('base_url');
    if (box.isEmpty) {
      box.put('base_url', 'https://8b58-118-99-81-164.ngrok-free.app');
    }
  }
}

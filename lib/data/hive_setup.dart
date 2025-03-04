import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:survey_app/model/user_state.dart';
import 'package:survey_app/utils/app_logger.dart';

import '../model/route_issue.dart';
import '../model/street.dart';

class HiveSetup {
  static final HiveSetup _instance = HiveSetup._internal();

  factory HiveSetup() => _instance;

  HiveSetup._internal();

  static Future<void> init() async {
    MyLogger("Local database").i("Setup hive");
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    Hive.registerAdapter(StreetAdapter());
    Hive.registerAdapter(RouteIssueAdapter());
    Hive.registerAdapter(MapStateAdapter());
    final box = await Hive.openBox('base_url');
    if (box.isEmpty) {
      box.put('base_url', 'https://7ae8-112-78-165-162.ngrok-free.app');
    }

    await Hive.openBox<Street>('streets');
    await Hive.openBox<RouteIssue>('route_issues');
    await Hive.openBox<String>('deleted_issue_id');
    await Hive.openBox<MapState>('map_state');
  }
}


/* void displayStreets() {
  List<Street> streets = streetBox.values.toList();
  for (var street in streets) {
    print('${street.name}, ${street.type}, ${street.postalCode}');
  }
} */
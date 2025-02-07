import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:survey_app/data/street_spatialite.dart';

import 'main.dart';
import 'utils/app_logger.dart';

void app() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger().init();

  try {
    await StreetSpatialite.cleanOldDatabases();
  } catch (e) {}

  if (kDebugMode) {
    return _runThisApp();
  }
}

void _runThisApp() async {
  return runApp(const ProviderScope(child: MyApp()));
}

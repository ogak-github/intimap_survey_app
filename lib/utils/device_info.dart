import 'dart:io';

import 'package:flutter/foundation.dart';

class DevInfo {
  static const bool isWeb = kIsWeb;
  static final bool isAndroid = !kIsWeb && Platform.isAndroid;
  static final bool isIOS = !kIsWeb && Platform.isIOS;
  static final bool isMobile = defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
  static bool isWebMobile = isWeb && isMobile;
}

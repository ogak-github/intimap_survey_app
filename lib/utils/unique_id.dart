import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

String uniqid() {
  final now = DateTime.now();
  final microseconds = now.microsecondsSinceEpoch;
  final milliseconds = now.millisecondsSinceEpoch;
  final seconds = now.second;
  final minutes = now.minute;
  final hours = now.hour;
  final days = now.day;
  final months = now.month;
  final years = now.year;
  final random = Random().nextInt(1000000);
  return '$microseconds$milliseconds$seconds$minutes$hours$days$months$years$random';
}

String uniqIdMd5() {
  return strToMd5(uniqid()).substring(0, 10);
}

String strToMd5(String payload) {
  final bytes = utf8.encode(payload);
  return md5.convert(bytes).toString();
}

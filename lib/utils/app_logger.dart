import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:survey_app/utils/log_utils.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();

  factory AppLogger() {
    return _instance;
  }

  AppLogger get instance => _instance;

  AppLogger._internal() {
    // _sId = Uuid().v4();
  }

  late Logger _logger;
  // late String _sId;
  bool _initialized = false;

  Future<File> _getFileName({
    bool forCreate = true,
    DateTime? requiredDate,
  }) async {
    final DateTime date = requiredDate ?? DateTime.now();
    final directory = await _getDirectory(forCreate);
    final String fileName =
        "${directory.path}/${DateFormat("yyyy-MM-dd").format(date)}.txt";
    final File outputFile = File(fileName);

    try {
      if (!await outputFile.exists()) {
        if (forCreate) {
          await outputFile.create();
        } else {
          log('File not created');
          throw Exception("File Not Created");
        }
      }
      return outputFile;
    } catch (e) {
      log('Error in creating file $e');
      rethrow;
    }
  }

  Future<Directory> _getDirectory(bool forCreate,
      {String path = 'foreground_task_logs'}) async {
    final Directory directory =
        Directory("${(await getApplicationDocumentsDirectory()).path}/$path");
    if (!await directory.exists()) {
      if (forCreate) {
        await directory.create();
      } else {
        throw Exception('Directory Not Created');
      }
    }
    return directory;
  }

  Future<void> init() async {
    if (kDebugMode) {
      _logger = Logger(
        output: ConsoleOutput(),
        printer: ColoredLogPrinter(printTime: true, colors: true),
      );
      _initialized = true;
      return;
    }
    _logger = Logger(
      filter: MyLogFilter(),
      output: FileOutput(
        file: await _getFileName(),
        encoding: utf8,
      ),
      printer: MySimpleLogPrinter(printTime: true, colors: false),
    );
    _initialized = true;
  }

  Logger get logger => _logger;
  bool get initialize => _initialized;
}

class MyLogger {
  final String _prefix;

  MyLogger(this._prefix);

  MyLogger operator +(String prefix) {
    return MyLogger("$_prefix - $prefix");
  }

  void d(
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    AppLogger().logger.d("$_prefix - $message",
        time: time, error: error, stackTrace: stackTrace);
  }

  void i(
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    AppLogger().logger.i("$_prefix - $message",
        time: time, error: error, stackTrace: stackTrace);
  }

  void e(
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    AppLogger().logger.e("$_prefix - $message",
        time: time, error: error, stackTrace: stackTrace);
  }
}

MyLogger createCustomLogger(String prefix) {
  return MyLogger(prefix);
}

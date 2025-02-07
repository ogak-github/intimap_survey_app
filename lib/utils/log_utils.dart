import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class MyLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

class MySimpleLogPrinter extends LogPrinter {
  static final levelPrefixes = {
    Level.trace: '[T]',
    Level.debug: '[D]',
    Level.info: '[I]',
    Level.warning: '[W]',
    Level.error: '[E]',
    Level.fatal: '[F]',
  };

  final bool printTime;
  final bool colors;

  MySimpleLogPrinter({this.printTime = false, this.colors = true});

  @override
  List<String> log(LogEvent event) {
    final messageStr = _stringifyMessage(event.message);
    final errorStr = event.error != null ? '  ERROR: ${event.error}' : '';
    final timeFormat = DateFormat("MM-dd HH:mm:ss");
    final timeStr = printTime ? timeFormat.format(event.time) : '';
    final output = ['${_labelFor(event.level)} $timeStr $messageStr$errorStr'];

    if (event.stackTrace != null) {
      output.add('STACK TRACE: ${event.stackTrace}');
    }
    return output;
  }

  String _labelFor(Level level) {
    final prefix = levelPrefixes[level]!;
    return prefix;
  }

  String _stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      const encoder = JsonEncoder.withIndent(null);
      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }
}

class ColoredLogPrinter extends LogPrinter {
  static final levelColors = <Level, AnsiColor>{
    Level.trace: const AnsiColor.fg(14), // Use cyan-like color
    Level.debug: const AnsiColor.fg(13), // Use blue-like color
    Level.info: const AnsiColor.fg(10), // Use green-like color
    Level.warning: const AnsiColor.fg(11), // Use yellow-like color
    Level.error: const AnsiColor.fg(9), // Use red-like color
    Level.fatal: const AnsiColor.fg(15),
  };

  static final levelPrefixes = {
    Level.trace: '[TRACE]',
    Level.debug: '[DEBUG]',
    Level.info: '[INFO]',
    Level.warning: '[WARN]',
    Level.error: '[ERR]',
    Level.fatal: '[FATAL]',
  };

  final bool printTime;
  final bool colors;

  ColoredLogPrinter({this.printTime = false, this.colors = true});

  @override
  List<String> log(LogEvent event) {
    final messageStr = _stringifyMessage(event.message);
    final errorStr = event.error != null ? '  ERROR: ${event.error}' : '';
    final timeFormat = DateFormat("HH:mm:ss");
    final timeStr = printTime
        ? const AnsiColor.fg(15).call(timeFormat.format(event.time))
        : ''; // Use white color for times
    final output = ['${_labelFor(event.level)} $timeStr $messageStr$errorStr'];

    if (event.stackTrace != null) {
      output.add('STACK TRACE: ${event.stackTrace}');
    }
    return output;
  }

  String _labelFor(Level level) {
    final prefix = levelPrefixes[level]!;
    if (colors && levelColors.containsKey(level)) {
      return levelColors[level]!.call(prefix);
    }
    return prefix;
  }

  String _stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      const encoder = JsonEncoder.withIndent(null);
      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }
}

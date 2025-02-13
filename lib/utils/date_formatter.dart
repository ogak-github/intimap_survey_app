import 'package:intl/intl.dart';

String humanizeDate(DateTime date, {bool showElapsed = false}) {
  date = date.toLocal();
  var now = DateTime.now();
  var diff = now.difference(date);
  var secDiff = diff.inSeconds;
  if (secDiff < 60) {
    return DateFormat('HH:mm:ss').format(date) +
        (showElapsed ? ' (${secDiff}s)' : '');
  } else if (secDiff < 3600) {
    var minDiff = (secDiff / 60).floor();
    return DateFormat('HH:mm').format(date) +
        (showElapsed ? ' (${minDiff}m)' : '');
  }
  var today = DateFormat('d MMM yyyy').format(now);
  var dateStr = DateFormat('d MMM yyyy').format(date);
  if (today == dateStr) {
    return DateFormat('HH:mm').format(date);
  }
  return dateStr;
}

String humanizeDateWithoutSec(DateTime date, {bool showElapsed = false}) {
  date = date.toLocal();
  var now = DateTime.now();
  var diff = now.difference(date);
  var secDiff = diff.inSeconds;
  if (secDiff < 60) {
    return DateFormat('HH:mm').format(date) +
        (showElapsed ? ' (${secDiff}s)' : '');
  } else if (secDiff < 3600) {
    var minDiff = (secDiff / 60).floor();
    return DateFormat('HH:mm').format(date) +
        (showElapsed ? ' (${minDiff}m)' : '');
  }
  var today = DateFormat('d MMM yyyy').format(now);
  var dateStr = DateFormat('d MMM yyyy').format(date);
  if (today == dateStr) {
    return DateFormat('HH:mm').format(date);
  }
  return dateStr;
}

String humanizeDate2(DateTime date) {
  date = date.toLocal();
  var now = DateTime.now();
  var today = DateFormat('d MMM yyyy').format(now);
  var dateStr = DateFormat('d MMM yyyy HH:mm:ss').format(date);
  if (today == dateStr) {
    return DateFormat('HH:mm:ss').format(date);
  }
  return dateStr;
}

String humanizeTimeOnly(DateTime date) {
  date = date.toLocal();
  return DateFormat('HH:mm:ss').format(date);
}

String formatDate(DateTime date, String format) {
  return DateFormat(format).format(date);
}

String formatDuration(Duration? duration) {
  if (duration == null) return '';
  var sec = duration.inSeconds;
  if (sec < 60) {
    return '$sec sec';
  }
  var min = duration.inMinutes;
  if (min < 60) {
    return '$min min';
  }
  var hour = duration.inHours;
  if (hour < 24) {
    return '$hour hr';
  }

  var days = duration.inDays;
  return '$days days';
}

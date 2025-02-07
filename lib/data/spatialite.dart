import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../utils/app_logger.dart';

const MethodChannel _channel =
    MethodChannel('com.intimap.spatialite/nativechannel');

class SpatialResult {
  final String? _resId;
  final String? _error;

  SpatialResult(this._resId, this._error);

  bool get hasResult => _resId != null;

  Future<Map<String, dynamic>?> fetch() async {
    if (_resId == null) return null;
    final Map<Object?, Object?> rawRes =
        await _channel.invokeMethod('fetch', {'res_id': _resId});
    final res = Map<String, dynamic>.from(rawRes);
    if (res['status'] == false) return null;
    if (res['assoc'] is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(res['assoc']);
  }

  String? get error => _error;

  Future<List<Map<String, dynamic>>> fetchAll() async {
    if (_resId == null) return [];
    final result = <Map<String, dynamic>>[];
    while (true) {
      final row = await fetch();
      if (row == null) break;
      result.add(row);
    }
    return result;
  }

  Future<void> free() async {
    await _channel.invokeMethod('freeResult', {'res_id': _resId});
  }
}

class SqliteQueue {
  final Queue<Future<void> Function()> _queue =
      Queue<Future<void> Function()>();
  bool _running = false;
  final MySpatialite db;

  SqliteQueue(this.db);

  Future<List<Map<String, dynamic>>?> queueQuery(String query) async {
    final Completer<List<Map<String, dynamic>>?> completer = Completer();
    _queue.add(() async {
      final result = await runQuery(query);
      completer.complete(result);
    });

    if (!_running) _startRunning();
    return completer.future;
  }

  Future<List<Map<String, dynamic>>?> runQuery(String query) async {
    final result = await db.query(query);
    if (result.error != null) return null;
    return result.fetchAll();
  }

  void _startRunning() async {
    _running = true;
    while (_queue.isNotEmpty) {
      final f = _queue.removeFirst();
      await f();
    }
    _running = false;
  }
}

class MySpatialite {
  late Future<String> linkId;
  late MyLogger logger;

  MySpatialite(String filename) {
    logger = MyLogger("MYSP");
    // TODO: This is not reconnected!
    logger.d("Connecting to $filename");
    linkId = _channel.invokeMethod(
        'connect', {'filename': filename}).then((val) => val as String);
    linkId.then((data) {
      logger.d("Get linkid $data");
    });
  }

  Future<void> disconnect() async {
    linkId.then((data) {
      logger.d("Disconnecting from $data");
    });
    await _channel.invokeMethod('disconnect', {'link_id': await linkId});
  }

  Future<void> init() async {
    await _channel.invokeMethod('init', {'link_id': await linkId});
  }

  Future<String> test() async {
    final String status =
        await _channel.invokeMethod('test', {'link_id': await linkId});
    return status;
  }

  Future<SpatialResult> query(String query) async {
    final nLinkId = await linkId;
    // logger.d(
    //     "Query ${nLinkId.substring(0, 10)} ${query.split("\n").map((e) => e.trim()).join(" ").substring(0, 100)}");
    final String resID = await _channel
        .invokeMethod('query', {'link_id': nLinkId, 'query': query});
    if (resID.isEmpty) {
      final err0 = await lastError();
      logger.e("SQL ERR: $nLinkId ${json.encode(err0)}\n\n$query");
      return SpatialResult(null, err0['message'] as String?);
    }

    final err = await lastError();
    if (err['code'] != 0) {
      logger.e("SQL ERR: $nLinkId $err\n\n$query");
      if (err['message'] != 'another row available' &&
          err['message'] != "no more rows available") {
        return SpatialResult(null, err['message'] as String?);
      }
      // await Sentry.captureMessage("SQLITE Error : $err\n\n$query");
      return SpatialResult(null, err['message'] as String?);
    }
    return SpatialResult(resID, null);
  }

  Future<void> exec(String query) async {
    await _channel
        .invokeMethod('exec', {'link_id': await linkId, 'query': query});
  }

  Future<String> escapeString(String value) async {
    final String escapedValue =
        await _channel.invokeMethod('escapeString', {'value': value});
    return escapedValue;
  }

  Future<Map<String, Object>> lastError() async {
    final Map<dynamic, dynamic> res =
        await _channel.invokeMethod('lastError', {'link_id': await linkId});
    return res.cast<String, Object>();
  }

  Future<int> lastInsertId() async {
    final int res =
        await _channel.invokeMethod('lastInsertId', {'link_id': await linkId});
    return res;
  }

  Future<bool> executeQueriesWithTransaction(List<String> queries) async {
    final transactionQueries = ["BEGIN TRANSACTION;", ...queries, "COMMIT;"];
    final transaction = transactionQueries.join("\n");
    await exec(transaction);
    final Map<String, dynamic> err = await lastError();
    if (err['code'] != 0) {
      if (err['message'] != 'another row available' &&
          err['message'] != "no more rows available") {
        // await Sentry.captureMessage("SQLITE Error : $err\n\n$transaction");
      }
      if (err['message'] == "cannot start a transaction within a transaction") {
        await exec("ROLLBACK;");
        return false;
      }
    }
    await exec("VACUUM ;");
    return true;
  }
}

class SpatialiteService {
  final Map<String, Future<MySpatialite>> _spatialiteInstances = {};
  final Map<String, Future<void>> _deleteTasks = {};

  static final SpatialiteService _singleton = SpatialiteService._internal();

  factory SpatialiteService() {
    return _singleton;
  }

  SpatialiteService._internal();

  Future<MySpatialite> getSpatialiteInstance(String fileName) async {
    // If there's a delete operation in progress, wait for it to complete
    if (_deleteTasks.containsKey(fileName)) {
      await _deleteTasks[fileName];
      _deleteTasks.remove(fileName);
    }

    if (!_spatialiteInstances.containsKey(fileName)) {
      // Create a new instance and store the Future
      _spatialiteInstances[fileName] = Future(() => MySpatialite(fileName));
    }

    return _spatialiteInstances[fileName]!;
  }

  Future<void> removeAndDeleteSpatialiteInstance(String fileName) async {
    if (_spatialiteInstances.containsKey(fileName)) {
      _spatialiteInstances.remove(fileName);
    }

    // If there's a delete operation in progress, wait for it to complete
    if (_deleteTasks.containsKey(fileName)) {
      await _deleteTasks[fileName];
    }

    // Delete the file and store the Future
    _deleteTasks[fileName] = deleteSpatialiteFile(fileName);

    return _deleteTasks[fileName];
  }

  Future<void> deleteSpatialiteFile(String filename) async {
    final file = File(filename);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

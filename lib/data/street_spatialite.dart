import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:survey_app/data/spatialite.dart';
import 'package:survey_app/model/street.dart';

import '../utils/app_logger.dart';
import '../utils/device_info.dart';

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

class StreetSpatialite {
  Completer<MySpatialite>? _spatialiteCompleter;

  Future<MySpatialite> getSpatialite() async {
    if (_spatialiteCompleter?.isCompleted == true) {
      return _spatialiteCompleter!.future;
    }
    if (_spatialiteCompleter == null) {
      _spatialiteCompleter = Completer<MySpatialite>();
      _initDatabase().then((value) {
        _spatialiteCompleter?.complete(value);
      });
    }
    return _spatialiteCompleter!.future;
  }

  Future<MySpatialite> _initDatabase() async {
    final spatialite = await _prepareDatabase();
    await _initDBTableStreet(spatialite);
    return spatialite;
  }

  Future<MySpatialite> _prepareDatabase() async {
    final dbPath = await _getDbpath();
    return SpatialiteService().getSpatialiteInstance(dbPath);
  }

  Future<String> _getDbpath() async {
    final String dbDirPath = await _getDbDirPath();
    final date = DateTime.now().millisecondsSinceEpoch;
    final dbPath = join(dbDirPath, "street_merauke_$date.db");
    return dbPath;
  }

  Future<bool> _initDBTableStreet(MySpatialite spatialite) async {
    if (!await _isRoutingTableExists(spatialite)) {
      await _createStreetTable(spatialite);
    }
    return true;
  }

  static Future<String> _getDbDirPath() async {
    final appDirPath = await getApplicationDocumentsDirectory();
    final basePath =
        DevInfo.isAndroid ? appDirPath.parent.path : appDirPath.path;
    final dbDirectory = join(basePath, "db");
    final dbDirPath = dbDirectory;
    final directory = Directory(dbDirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return dbDirPath;
  }

  Future<bool> _isRoutingTableExists(MySpatialite spatialite) async {
    const query = "SELECT name FROM sqlite_master "
        "WHERE type='table' AND name='street';";
    final result = await spatialite.query(query);
    if (!result.hasResult) return false;

    while (true) {
      final Map<String, dynamic>? res = await result.fetch();
      if (res == null) break;
      if (res['name'].toString().trim().toLowerCase() == "street") {
        await result.free();
        return true;
      }
    }
    await result.free();

    return false;
  }

  static Future<void> cleanOldDatabases() async {
    final dbDirPath = await _getDbDirPath();
    final directory = Directory(dbDirPath);
    final logger = MyLogger("DB");

    logger.i("Cleaning old databases");
    int count = 0;

    // Current date time
    final now = DateTime.now();

    // Check if directory exists
    if (await directory.exists()) {
      final files = directory.listSync();

      // For each file in directory
      for (FileSystemEntity file in files) {
        // Get filename
        final String filename = basename(file.path);
        // Extract timestamp from filename
        if (filename.startsWith("street_") && filename.endsWith(".db")) {
          logger.i("Checking file: $filename");

          final filenameParts = filename.split('_');
          final timestampPart = filenameParts[2].split('.')[0];
          // Convert timestamp string to int safely
          final timestamp = int.tryParse(timestampPart);
          // Check if parsed successfully
          if (timestamp != null) {
            // If date is older than 7 days, delete the file
            final fileDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final diff = now.difference(fileDate).inDays;

            if (diff > 7) {
              logger.i("Deleting file: $filename, diff: $diff");
              await file.delete();
              count++;
            }
          }
        }
      }
    }

    if (count > 0) {
      logger.i("Deleted $count files");
    } else {
      logger.i("No files deleted");
    }
  }

  Future<bool> _createStreetTable(MySpatialite spatialite) async {
    String ifNotExists = "IF NOT EXISTS";
    if (Platform.isIOS) {
      ifNotExists = "";
    }

    final queries = <String>[];

    queries.add("CREATE TABLE $ifNotExists street "
        "(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, osm_id TEXT, nama TEXT, truk INTEGER, pickup INTEGER, roda3 INTEGER, last_modified_time TIMESTAMP, meta TEXT );");
    queries.add("CREATE INDEX $ifNotExists rNama ON street(nama) ;");
    queries.add("CREATE INDEX $ifNotExists rTruk ON street(truk) ;");
    queries.add("CREATE INDEX $ifNotExists rPickup ON street(pickup) ;");
    queries.add("CREATE INDEX $ifNotExists rRoda3 ON street(roda3) ;");
    queries.add("CREATE INDEX $ifNotExists rOsmId ON street(osm_id) ;");
    queries.add(
        "CREATE INDEX $ifNotExists rLastModifiedTime ON street(last_modified_time) ;");

    queries.add("CREATE INDEX $ifNotExists rMeta ON street(meta) ;");
    queries.add(
        "SELECT AddGeometryColumn('street', 'geom',  4326, 'GEOMETRY', 2);");
    queries.add("SELECT CreateSpatialIndex('street','geom');");

    /*    queries.add("CREATE INDEX $ifNotExists rType ON routing(type) ;");
    queries.add("CREATE INDEX $ifNotExists rName ON routing(name) ;");
    queries.add("CREATE INDEX $ifNotExists rMeta ON routing(meta) ;");
    queries.add(
        "SELECT AddGeometryColumn('routing', 'geom',  4326, 'GEOMETRY', 2);");
    queries.add("SELECT CreateSpatialIndex('routing','geom');");

    queries.add("CREATE TABLE $ifNotExists road_vs_bin "
        "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, road_id INTEGER, bin_id INTEGER) ;");
    queries.add("CREATE INDEX $ifNotExists rbRoad ON road_vs_bin(road_id) ;");
    queries.add("CREATE INDEX $ifNotExists rbBin ON road_vs_bin(bin_id) ;"); */

    return spatialite.executeQueriesWithTransaction(queries);
  }
}

class StreetData {
  final StreetSpatialite streetSpatialite;
  late Future<SqliteQueue> _queue;

  StreetData(this.streetSpatialite) {
    _queue = streetSpatialite.getSpatialite().then((spatialite) {
      return SqliteQueue(spatialite);
    });
  }

  Future<MySpatialite> get spatialite => streetSpatialite.getSpatialite();
  Future<SqliteQueue> get sqliteQueue => _queue;

  Future<bool> fillDataIntoDB(List<Street> streets) async {
    List<String> queries = [];
    for (var street in streets) {
      var query =
          "INSERT INTO street (osm_id, nama, truk, pickup, roda3, last_modified_time, meta, geom) "
          "VALUES('${street.osmId}', '${street.name}', ${street.truk}, ${street.pickup}, ${street.roda3}, '${street.lastModifiedTime}','${street.meta}','${street.geom}');";
      queries.add(query);
    }

    try {
      //MyLogger("Query Length").i(queries.toString());
      return (await spatialite).executeQueriesWithTransaction(queries);
    } on PlatformException catch (e) {
      MyLogger("DB").e(e.toString());
      return false;
    }
  }
}

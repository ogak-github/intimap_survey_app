import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:survey_app/data/street_spatialite.dart';
import 'package:survey_app/model/routing_data.dart';

import '../model/street.dart';
import '../utils/app_logger.dart';
import '../utils/unique_id.dart';

class RoutingFn {
  final StreetData _streetData;
  RoutingFn(this._streetData);

  SelectedRouteInfo2? lastRouteInfo;

  Future<List<RoutingPoint2>?> computeSegmentAgaintsPoint(LocationData location,
      {required String queryId}) async {
    final point =
        "ST_GEOMFROMTEXT('POINT(${location.longitude?.toStringAsFixed(6)} ${location.latitude?.toStringAsFixed(6)})', 4326)";
    final pointPos = "ST_line_locate_Point(geom, $point)";

    final query2 = """
  SELECT  
    id,
    "$queryId" as queryId,
    osm_id,
    nama,
    truk,
    pickup,
    roda3,
    last_modified_time,
    meta,
    ST_AsText(geom) AS geom,
    ST_AsText($point) AS originalPoint,
    pointPosition,
    ST_ASTEXT(fixedPoint) as fixedPoint,
    ST_ASTEXT(ST_Line_Interpolate_Point(geom, pointPosition + (3 / routeLength))) as nextPoint,
    ROUND(degrees(ST_Azimuth(
        fixedPoint,
        ST_Line_Interpolate_Point(geom, pointPosition + (3 / routeLength))
      ))) AS lineHeading,
    ROUND(ST_Distance(
      $point,
      geom, 1), 2
    ) AS distanceToRoute,
    routeLength,
    routeLength - (routeLength * pointPosition) AS distanceLeft
  FROM (
      SELECT
        id,
        osm_id,
        nama,
        truk,
        pickup,
        roda3,
        last_modified_time,
        geom,
        meta,
        $pointPos as pointPosition,
        ST_Line_Interpolate_Point(geom, $pointPos) as fixedPoint,
        ST_Length(geom, 1) AS routeLength
      FROM street
      WHERE ST_Distance($point, geom, 1) < 1000 
  ) as sub
  ORDER BY distanceToRoute ASC;
""";
/* AND ST_GeometryType(geom) <> 'ST_Point' */

    /* final dataRaw =
        await (await _streetData.sqliteQueue).queueQuery(query2.trim()); */
    final dataRaw =
        await (await _streetData.sqliteQueue).runQuery(query2.trim());

    if (dataRaw == null) return null;
    // final queryError = result.error;
    // if (queryError != null) {
    // //   log("Segment calculate error, query error: $queryError");
    //   return null;
    // }

    // final dataRaw = await result.fetchAll();
    final routingPoints2 = await _processRoutingPoints(dataRaw);

    if (routingPoints2.isEmpty) {
      // log("Segment calculate error, empty data ${json.encode(dataRaw)}");
    }

    return routingPoints2;
  }

  Future<LatLng> getTapPointFromPolylines(
      LatLng tapPoint, String streetId) async {
    // Create the point geometry from the tap point
    final point =
        "ST_GEOMFROMTEXT('POINT(${tapPoint.longitude} ${tapPoint.latitude})', 4326)";
    final pointPos = "ST_line_locate_Point(geom, $point)";

    final query2 = """
      SELECT id, ST_AsText(fixedPoint) AS fixedPoint 
      FROM (SELECT id, ST_Line_Interpolate_Point(geom, $pointPos) AS fixedPoint 
      FROM street 
    WHERE id = $streetId
    );
    """;

    // Execute the query
    final dataRaw =
        await (await _streetData.sqliteQueue).queueQuery(query2.trim());

    // Check if there's any result
    if (dataRaw == null || dataRaw.isEmpty) return tapPoint;

    // Extract the nearest point from the result
    final fixedPoint = dataRaw.first['fixedPoint'];
    if (fixedPoint == null) return tapPoint;

    // Parse the WKT point to LatLng
    LatLng getPoint = await Isolate.run(() async {
      var pointParts =
          fixedPoint.substring(6, fixedPoint.length - 1).split(' ');
      return LatLng(double.parse(pointParts[1]), double.parse(pointParts[0]));
    });

    return getPoint;
  }

  bool _busy = false;
  String? _pid;

  bool get isBusy => _busy;
  String? get pid => _pid;

  Future<double> headingDifference(double heading1, double heading2) async {
    return await Isolate.run(() {
      return (180 - (((heading1 - heading2).abs()) - 180).abs());
    });
  }

  Future<SelectedRouteInfo2?> getRouteSegment(
    LocationData location, {
    String? uniqId,
  }) async {
    final newUniqId = uniqId ?? uniqIdMd5();
    // final newLogger = routingLog + "uid: $newUniqId";

    _busy = true;
    _pid = uniqId;
    defer() {
      _busy = false;
      _pid = null;
    }

    MyLogger("getRouteSegment").d(" "
        "${location.latitude?.toStringAsFixed(6)} "
        "${location.longitude?.toStringAsFixed(6)} "
        "${location.speed?.round()} ${location.heading?.round()} ");

    final listRoutingPoint =
        await computeSegmentAgaintsPoint(location, queryId: newUniqId);
    if (listRoutingPoint == null || listRoutingPoint.isEmpty) {
      MyLogger("getRouteSegment")
          .d("Segment calculate error, list routing point is null/empty");
      defer();
      return null;
    }

    final result =
        await _getMatchingPoint(listRoutingPoint, location, uniqId: newUniqId);
    defer();
    return result;
  }

  Future<SelectedRouteInfo2?> _getMatchingPoint(
    List<RoutingPoint2> listRoutingPoint,
    LocationData location, {
    int distanceToRoute = 10,
    String uniqId = "",
  }) async {
    /*  final newLogger = routingLog + "uid: $uniqId-$distanceToRoute"; */

    const maxDistanceToRoute = 50;
    final flistRoutingPoint = listRoutingPoint
        .where((e) => e.distanceToRoute < distanceToRoute)
        .toList();
    final flistMaxRoutingPoint = listRoutingPoint
        .where((e) => e.distanceToRoute < maxDistanceToRoute)
        .toList();

    final lastRouteInfoX = lastRouteInfo ??
        SelectedRouteInfo2(
          lastOkPoint: listRoutingPoint.first,
          point: null,
          matchType: RouteMatchType.nextSegment,
          firstMatchTime: DateTime.now(),
        );

    final lastPointX = lastRouteInfoX.point ?? lastRouteInfoX.lastOkPoint;

    if (flistMaxRoutingPoint.isEmpty) {
      var datetime = DateTime.now();
      if (lastRouteInfoX.matchType == RouteMatchType.outOfRoute) {
        datetime = lastRouteInfoX.firstMatchTime;
      }
      // newLogger.d("Vehicle still out of route 1!");
      final newRouteInfo = SelectedRouteInfo2(
        point: null,
        lastOkPoint: lastPointX,
        matchType: RouteMatchType.outOfRoute,
        firstMatchTime: datetime,
      );
      lastRouteInfo = newRouteInfo;
      return newRouteInfo;
    }

    /*  final Map<RouteMatchType, RoutingPoint2> matchPoint = {};
    var hasCurrentSegment = false;
    var hasNextSegment = false;

    for (final point in flistRoutingPoint) {
      var logTrace = "";
      final headingDiff = await headingDifference(
          point.lineHeading ?? 0, location.heading ?? 0);
      if (point.id < lastPointX.id && headingDiff < 90) {
        // Going back to previous route segment
        if (point.pointPosition < 1.0) {
          logTrace += "A-";
          matchPoint[RouteMatchType.prevSegment] = point;
        }
      }
      if (point.id == lastPointX.id) {
        hasCurrentSegment = true;
        // Still in the same route segment
        if (point.pointPosition < 1.0) {
          if (point.pointPosition >= lastPointX.pointPosition) {
            logTrace += "B-";
            matchPoint[RouteMatchType.forward] = point;
          } else if (point.pointPosition < lastPointX.pointPosition) {
            logTrace += "C-";
            matchPoint[RouteMatchType.backward] = point;
          }
        } else if (point.pointPosition > lastPointX.pointPosition) {
          logTrace += "D-";
          matchPoint[RouteMatchType.forward] = point;
        }
      }
      if (point.id == lastPointX.id + 1) {
        // Move into next route segment
        if (point.pointPosition >= 0.0 &&
            point.pointPosition < lastPointX.pointPosition) {
          hasNextSegment = true;
          logTrace += "E-";
          matchPoint[RouteMatchType.nextSegment] = point;
        }
      }
      if ((point.id + 1) > lastPointX.id && headingDiff < 90) {
        logTrace += "F-";
        matchPoint[RouteMatchType.jumpSegment] = point;
      }
      MyLogger("Match Point").d(
          "MP ${point.id} ${point.pointPosition.toStringAsFixed(2)} ${point.distanceToRoute.toStringAsFixed(2)} $logTrace");
    } */

    var matchPointData = ProcessMatchPointData();

    matchPointData = await _processMatchPointData(
      flistRoutingPoint,
      location,
      lastPointX,
    );

    final moveToNextSegment =
        matchPointData.hasNextSegment && distanceToRoute < 30;

    if (!moveToNextSegment &&
        !matchPointData.hasCurrentSegment &&
        distanceToRoute < maxDistanceToRoute) {
      return _getMatchingPoint(
        listRoutingPoint,
        location,
        /*  vehicleStatus, */
        distanceToRoute: distanceToRoute + 10,
        uniqId: uniqId,
      );
    }

    MyLogger("Match Point").d(
        "MPs ${matchPointData.matchPoint.length} ${matchPointData.matchPoint.entries.map((e) => "${e.key} ${e.value.id}").join(",")}");

    var matchTypeData = MatchTypeData(
      matchType: RouteMatchType.outOfRoute,
      datetime: DateTime.now(),
    );

    lastRouteInfo =
        await _matchTypeProcess(matchPointData, lastRouteInfoX, matchTypeData);

    if (distanceToRoute < maxDistanceToRoute) {
      return _getMatchingPoint(
        listRoutingPoint,
        location,
        distanceToRoute: distanceToRoute + 10,
        uniqId: uniqId,
      );
    }

    final newRouteInfo = SelectedRouteInfo2(
      point: null,
      lastOkPoint: lastPointX,
      matchType: matchTypeData.matchType,
      firstMatchTime: matchTypeData.datetime,
    );
    lastRouteInfo = newRouteInfo;
    MyLogger("Match Point").d("User still out of route 3!");
    return newRouteInfo;
  }
}

Future<List<RoutingPoint2>> _processRoutingPoints(
    List<Map<String, dynamic>> dataRaw) async {
  List<RoutingPoint2> response = await Isolate.run(() {
    try {
      return dataRaw
          .map((e) {
            if (e['pointPosition'] == null || e['fixedPoint'] == null) {
              return null;
            }
            Street st = Street(
              id: e['id'],
              osmId: e["osm_id"],
              name: e['nama'],
              truk: e['truk'],
              pickup: e['pickup'],
              roda3: e['roda3'],
              meta: e['meta'],
              lastModifiedTime: DateTime.parse(e['last_modified_time']),
              geom: e['geom'],
            );
            return RoutingPoint2(
                id: e['id'],
                street: st,
                distanceToRoute: e['distanceToRoute'],
                queryId: e['queryId'],
                originalPoint: e['originalPoint'],
                fixedPoint: e['fixedPoint'],
                nextPoint: e['nextPoint'],
                pointPosition: e['pointPosition'],
                routeLength: e['routeLength'],
                distanceLeft: e['distanceLeft'],
                lineHeading: e['lineHeading']);
          })
          .whereType<RoutingPoint2>()
          .toList();
    } catch (error) {
      MyLogger('Error processing data in isolate').e(error.toString());
      return [];
    }
  });

  return response;
}

class ProcessMatchPointData {
  Map<RouteMatchType, RoutingPoint2> matchPoint;
  bool hasCurrentSegment;
  bool hasNextSegment;

  ProcessMatchPointData({
    this.matchPoint = const {},
    this.hasCurrentSegment = false,
    this.hasNextSegment = false,
  });
}

Future<double> headingDifference(double heading1, double heading2) async {
  return await Isolate.run(() {
    return (180 - (((heading1 - heading2).abs()) - 180).abs());
  });
}

Future<ProcessMatchPointData> _processMatchPointData(
    List<RoutingPoint2> flistRoutingPoint,
    LocationData location,
    RoutingPoint2 lastPointX) async {
  final result = await Isolate.run(() async {
    Map<RouteMatchType, RoutingPoint2> matchPoint = {};
    bool hasCurrentSegment = false;
    bool hasNextSegment = false;
    for (final point in flistRoutingPoint) {
      var logTrace = "";
      final headingDiff = await headingDifference(
          point.lineHeading ?? 0, location.heading ?? 0);
      if (point.id < lastPointX.id && headingDiff < 90) {
        // Going back to previous route segment
        if (point.pointPosition < 1.0) {
          logTrace += "A-";
          matchPoint[RouteMatchType.prevSegment] = point;
        }
      }
      if (point.id == lastPointX.id) {
        hasCurrentSegment = true;
        // Still in the same route segment
        if (point.pointPosition < 1.0) {
          if (point.pointPosition >= lastPointX.pointPosition) {
            logTrace += "B-";
            matchPoint[RouteMatchType.forward] = point;
          } else if (point.pointPosition < lastPointX.pointPosition) {
            logTrace += "C-";
            matchPoint[RouteMatchType.backward] = point;
          }
        } else if (point.pointPosition > lastPointX.pointPosition) {
          logTrace += "D-";
          matchPoint[RouteMatchType.forward] = point;
        }
      }
      if (point.id == lastPointX.id + 1) {
        // Move into next route segment
        if (point.pointPosition >= 0.0 &&
            point.pointPosition < lastPointX.pointPosition) {
          hasNextSegment = true;
          logTrace += "E-";
          matchPoint[RouteMatchType.nextSegment] = point;
        }
      }
      if ((point.id + 1) > lastPointX.id && headingDiff < 90) {
        logTrace += "F-";
        matchPoint[RouteMatchType.jumpSegment] = point;
      }
      log("MP ${point.id} ${point.pointPosition.toStringAsFixed(2)} ${point.distanceToRoute.toStringAsFixed(2)} $logTrace",
          name: "Match Point");
      /*  MyLogger("Match Point").d(
          "MP ${point.id} ${point.pointPosition.toStringAsFixed(2)} ${point.distanceToRoute.toStringAsFixed(2)} $logTrace"); */
    }

    return ProcessMatchPointData(
        matchPoint: matchPoint,
        hasCurrentSegment: hasCurrentSegment,
        hasNextSegment: hasNextSegment);
  });

  return result;
}

class MatchTypeData {
  RouteMatchType matchType;
  DateTime datetime = DateTime.now();

  MatchTypeData({RouteMatchType? matchType, DateTime? datetime})
      : matchType = matchType ?? RouteMatchType.outOfRoute,
        datetime = datetime ?? DateTime.now();
}

Future<SelectedRouteInfo2?> _matchTypeProcess(
    ProcessMatchPointData matchPointData,
    SelectedRouteInfo2 lastRouteInfoX,
    MatchTypeData matchTypeData) async {
  SelectedRouteInfo2? selectedRoute;
  return await Isolate.run(() async {
    final lastPointX = lastRouteInfoX.point ?? lastRouteInfoX.lastOkPoint;
    var matchType = RouteMatchType.outOfRoute;
    var datetime = DateTime.now();
    RoutingPoint2? minPoint;
    if (matchPointData.matchPoint.containsKey(RouteMatchType.forward)) {
      matchType = RouteMatchType.forward;
      minPoint = matchPointData.matchPoint[RouteMatchType.forward];
      datetime = lastRouteInfoX.firstMatchTime;
      /*  newLogger.d(
          "Vehicle -> ${minPoint!.id} ${minPoint.pointPosition.toStringAsFixed(2)}"); */
      if (matchPointData.matchPoint.containsKey(RouteMatchType.backward)) {
        matchType = RouteMatchType.backward;
        minPoint = matchPointData.matchPoint[RouteMatchType.backward];
        datetime = lastRouteInfoX.firstMatchTime;
        /* MyLogger("Match Point").d(
            "Vehicle <- ${minPoint!.id} ${minPoint.pointPosition.toStringAsFixed(2)}"); */
      } else if (matchPointData.matchPoint
          .containsKey(RouteMatchType.prevSegment)) {
        matchType = RouteMatchType.prevSegment;
        minPoint = matchPointData.matchPoint[RouteMatchType.prevSegment];
        /*   MyLogger("Match Point").d(
            "Back into previous route segment ${minPoint!.id} ${minPoint.pointPosition.toStringAsFixed(2)}"); */
      } else if (matchPointData.matchPoint
          .containsKey(RouteMatchType.jumpSegment)) {
        matchType = RouteMatchType.jumpSegment;
        minPoint = matchPointData.matchPoint[RouteMatchType.jumpSegment];
        /*  MyLogger("Match Point").d(
            "Jump into next route segment ${minPoint!.id} ${minPoint.pointPosition.toStringAsFixed(2)}"); */
      } else if (lastRouteInfoX.matchType == RouteMatchType.outOfRoute) {
        datetime = lastRouteInfoX.firstMatchTime;
        /* MyLogger("Match Point").d("User still out of route 2!"); */
      }

      if (minPoint != null) {
        var mPoint = minPoint;
        if (mPoint.lineHeading == null) {
          mPoint = mPoint.copyWith(lineHeading: lastPointX.lineHeading);
        }
        /*  MyLogger("Match Point").d("MP selected ${mPoint.id} "
            "queryId: ${mPoint.queryId} "
            "originalPoint: ${mPoint.originalPoint} "
            "${mPoint.pointPosition.toStringAsFixed(2)} "
            "${mPoint.distanceToRoute.toStringAsFixed(2)} "
            "${mPoint.latLng.latitude} ${mPoint.latLng.longitude}"); */
        final newRouteInfo = SelectedRouteInfo2(
          point: mPoint,
          lastOkPoint: mPoint,
          matchType: matchType,
          firstMatchTime: datetime,
        );
        selectedRoute = newRouteInfo;
        return newRouteInfo;
      }
    }
    return selectedRoute;
  });
}

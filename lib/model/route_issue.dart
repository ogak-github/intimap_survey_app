import 'dart:developer';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geobase/geobase.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'route_issue.freezed.dart';
part 'route_issue.g.dart';

@freezed
class RouteIssue with _$RouteIssue {
  const RouteIssue._();

  @HiveType(typeId: 2, adapterName: "RouteIssueAdapter")
  const factory RouteIssue({
    @HiveField(0) required int id,
    @HiveField(1) @JsonKey(name: "street_id") required int streetId,
    @HiveField(2) required int blocked,
    @HiveField(3) String? notes,
    @HiveField(4) required String geom,
  }) = _RouteIssue;

  factory RouteIssue.fromJson(Map<String, Object?> json) =>
      _$RouteIssueFromJson(json);

  LatLng get point {
    try {
      if (geom.contains("POINT")) {
        var point = Point.parse(geom, format: WKT.geometry);
        //MyLogger("Route Issue point parsing").d(point.toString());
        return LatLng(point.position.y, point.position.x);
      } else {
        return const LatLng(0, 0);
      }
    } catch (e) {
      log(e.toString(), name: "Convert to latlng error");
      return const LatLng(0, 0);
    }
  }

  String get insertReplaceQuery {
    var query = "REPLACE INTO route_issue (street_id, blocked, notes, geom) "
        "VALUES($streetId, $blocked, '$notes', GeomFromText('$geom', 4326));";
    return query;
  }
}

class RouteIssueData {
  final int streetId;
  final bool blocked;
  final String notes;
  final String geom;

  RouteIssueData(this.streetId, this.blocked, this.notes, this.geom);

  String get insertReplaceQuery {
    var query = "REPLACE INTO route_issue (street_id, blocked, notes, geom) "
        "VALUES($streetId, $blocked, '$notes', GeomFromText('$geom', 4326));";
    return query;
  }
}

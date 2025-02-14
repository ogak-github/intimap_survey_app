import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geobase/geobase.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'street.freezed.dart';
part 'street.g.dart';

@Freezed()
class Street with _$Street {
  const Street._();

  @HiveType(typeId: 1, adapterName: "StreetAdapter")
  const factory Street({
    @HiveField(0)
    required int id,
    @JsonKey(name: 'osm_id') 
    @HiveField(1)
    required String osmId,
    @HiveField(2)
    String? name,
    @HiveField(3)
    int? truk,
    @HiveField(4)
    int? pickup,
    @HiveField(5)
    int? roda3,
    @HiveField(6)
    String? meta,
    @JsonKey(name: 'last_modified_time') 
    @HiveField(7)
    required DateTime lastModifiedTime,
    @HiveField(8)
    required String geom,
  }) = _Street;

  factory Street.fromJson(Map<String, Object?> json) => _$StreetFromJson(json);

  List<LatLng> get poly {
    try {
      List<LatLng> list = [];
      if (geom.contains("LINESTRING") && !geom.contains("GEOMETRYCOLLECTION")) {
        var lineString = LineString.parse(geom, format: WKT.geometry);
        for (var line in lineString.chain.positions) {
          list.add(LatLng(line.y, line.x));
        }
      }

      /*   if (geom.contains("GEOMETRYCOLLECTION")) {
        var geometryColl = GeometryCollection.parse(geom, format: WKT.geometry);
        for (var element in geometryColl.geometries) {
          if (element.geomType == Geom.lineString) {
            var lineString =
                LineString.parse(element.toText(), format: WKT.geometry);
            for (var line in lineString.chain.positions) {
              list.add(LatLng(line.y, line.x));
            }
          }
        }
      } */
      return list;
    } catch (e) {
      log(e.toString(), name: "Convert to latlng error");
      return [];
    }
  }

  String get insertReplaceQuery {
    var query =
        "REPLACE INTO street (osm_id, nama, truk, pickup, roda3, last_modified_time, meta, geom) "
        "VALUES('$osmId', '$name', $truk, $pickup, $roda3, '$lastModifiedTime','$meta', GeomFromText('$geom', 4326));";
    return query;
  }
}


@freezed
class Metadata with _$Metadata {
  const factory Metadata({
    String? notes,
    bool? updated,
  }) = _Metadata;

  factory Metadata.fromJson(Map<String, Object?> json) => _$MetadataFromJson(json);
}

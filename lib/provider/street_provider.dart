import 'package:flutter/material.dart';
import 'package:geobase/geobase.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:location/location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:survey_app/data/street_spatialite.dart';

import '../api/street_api.dart';
import '../model/street.dart';

part 'street_provider.g.dart';

final streetData = StreetData(StreetSpatialite());

@Riverpod(keepAlive: true)
class StreetProvider extends _$StreetProvider {
  @override
  FutureOr<List<Street>> build({int page = 1}) {
    final api = ref.watch(streetAPIProvider);
    return api.getStreet(page: page);
  }
}

@riverpod
class LoadAllStreet extends _$LoadAllStreet {
  @override
  FutureOr<List<Street>> build() async {
    final api = ref.watch(streetAPIProvider);
    return await api.loadAll();
  }
}

@riverpod
class DrawStreet extends _$DrawStreet {
  @override
  FutureOr<Set<Polyline>> build() async {
    Set<Polyline> polylines = {};
    final streets = ref.watch(loadAllStreetProvider);
    streets.whenData((streets) {
      //filterStreet(streets);

      streetData.fillDataIntoDB(streets);
    });

    return polylines;
  }

  List<List<num>> decodedGeometry(String encodedGeom) {
    final decode = decodePolyline(encodedGeom);
    return decode;
  }

  List<LatLng> convertToLatLng(List<List<num>> decodedGeometry) {
    return decodedGeometry.map((List<num> coord) {
      // Ensure there are exactly two numbers in the list (latitude, longitude)
      if (coord.length != 2) {
        throw const FormatException(
            "Each coordinate pair should contain exactly two elements.");
      }
      // Create a LatLng object from each pair
      return LatLng(coord[0].toDouble(), coord[1].toDouble());
    }).toList();
  }

  void renderPolylines(List<Street> street) {
    Set<Polyline> newPolylines = {};
    for (var element in street) {
      newPolylines.add(
        Polyline(
          width: 2,
          polylineId: PolylineId(element.id.toString()),
          points: convertToLatLng(decodedGeometry(element.geom)),
          color: Colors.red,
        ),
      );
    }
    state = AsyncValue.data(newPolylines);
  }

  //Convert points to geobase lineString
/*   LineString convertToLineString(Street street) {
    try {
      //decode encoded polyline (google algorithm)
      var decode = convertToLatLng(decodedGeometry(street.geom));
      //convert to position
      var positionList = latlngToDouble(decode);
      LineString lineString = LineString.from(positionList);
      return lineString;
    } catch (e) {
      log(e.toString());
    }
    return LineString.build(const []);
  } */

/*   double calculateDistance(Street street, LocationData location) {
    LineString lineString = convertToLineString(street);
    double distance = lineString.distanceTo2D(
        Position.create(x: location.latitude!, y: location.longitude!));
    Position pos =
        Position.create(x: location.latitude!, y: location.longitude!);
    Position p = [location.latitude!, location.longitude!].xy * 0.001;

    return distance;
  } */

  double calculateDistance2(Street street, LocationData location) {
    double distance = double.infinity;
    var decode = convertToLatLng(decodedGeometry(street.geom));
    var pos = Geographic(lon: location.longitude!, lat: location.latitude!);
    for (var element in decode) {
      var latlng = Geographic(lon: element.longitude, lat: element.latitude);
      var arc = pos.vincenty().inverse(latlng);
      final distanceKm = arc.distance / 1000.0;
      if (distanceKm < distance) {
        distance = distanceKm;
      }
    }
    //log(distance.toStringAsFixed(2), name: 'distance in Km');
    return distance;
  }

  // TODO : Filter geobase < 1 km from user position
  void filterStreet(List<Street> streets) async {
    List<Street> filteredStreets = [];
    final Location lc = Location();

    var getLocation = await lc.getLocation();

    for (var street in streets) {
      double distance = calculateDistance2(street, getLocation);
      if (distance <= 1) {
        filteredStreets.add(street);
      } else {
        filteredStreets.remove(street);
      }
    }
    renderPolylines(filteredStreets);

    /*  lc.onLocationChanged.listen((loc) {
      for (var street in streets) {
        double distance = calculateDistance2(street, loc);
        if (distance <= 25) {
          filteredStreets.add(street);
        } else {
          filteredStreets.remove(street);
        }
      }
      renderPolylines(filteredStreets);
    }); */
  }

  List<Position> latlngToDouble(List<LatLng> latlng) {
    Set<Position> positionList = {};
    for (var element in latlng) {
      positionList
          .add(Position.create(x: element.latitude, y: element.longitude));
    }

    return positionList.toList();
  }
}

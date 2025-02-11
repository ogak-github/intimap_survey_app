import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geobase/geobase.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:location/location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:survey_app/data/street_spatialite.dart';
import 'package:survey_app/utils/app_logger.dart';
import 'package:survey_app/utils/debouncer.dart';

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
  FutureOr<void> build() async {
    MyLogger("Load all street").i("Called");
    EasyLoading.show(status: 'Loading streets from server...');
    final api = ref.watch(streetAPIProvider);
    var streets = await api.loadAll();
    MyLogger("Total loaded streets").i(streets.length.toString());
    EasyLoading.dismiss();

    /// call fillDataIntoDB
    EasyLoading.show(status: 'Sync data to local DB...');
    await runInBackground(streets);
    EasyLoading.dismiss();
  }

  Future<void> runInBackground(List<Street> streets) async {
    final response = ReceivePort();
    await Isolate.spawn(_processData, [streets, response.sendPort]);
    var processedStreets = await response.first;
    await streetData.fillBatchDataIntoDB(processedStreets);
  }

  static void _processData(List<dynamic> args) async {
    List<Street> streets = args[0];
    SendPort sendPort = args[1];
    sendPort.send(streets); // Notify completion
  }
}

@Riverpod(keepAlive: true)
class DrawStreet extends _$DrawStreet {
  final List<Street> _data = [];
  @override
  FutureOr<Set<Polyline>> build() async {
    Set<Polyline> polylines = {};

    onLocationChanged(_data);

    return polylines;
  }

  void loadStreetData() async {
    EasyLoading.show(status: 'Loading streets from local DB...');
    final streets = await streetData.getStreet();
    _data.addAll(streets.toSet());
    log(_data.length.toString(), name: "Total street loaded");
    EasyLoading.dismiss();
  }

/*   List<List<num>> decodedGeometry(String encodedGeom) {
    final decode = decodePolyline(encodedGeom);
    return decode;
  } */
/* 
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
  } */

  void renderPolylines(List<Street> street) {
    log("Rendering", name: "Polylines");
    Set<Polyline> newPolylines = {};
    /*  Future.forEach(street, (Street element) async {
      double distance = calculateDistance2(element, getLocation);
      newPolylines.add(
        Polyline(
            width: 2,
            polylineId: PolylineId(element.id.toString()),
            points: element.poly,
            color: Colors.red,
           ),
      );
    }); */
    for (var element in street) {
      newPolylines.add(
        Polyline(
          width: 2,
          polylineId: PolylineId(element.id.toString()),
          points: element.poly,
          color: Colors.red,
        ),
      );
    }
    log(newPolylines.length.toString(), name: "Polyline length");
    state = AsyncValue.data(newPolylines);
  }



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
    try {
      /*  if (street.geom.contains("LINESTRING")) {
        var wktParse = LineString.parse(street.geom, format: WKT.geometry);
        var pos = Geographic(lon: location.longitude!, lat: location.latitude!);
        for (var i in wktParse.chain.positions) {
          var latlng = Geographic(lon: i.y, lat: i.x);
          var arc = pos.vincenty().inverse(latlng);
          final distanceKm = arc.distance / 1000.0;
          if (distanceKm < distance) {
            distance = distanceKm;
          }
        }
      
        return distance;
      } */
      var pos = Geographic(lon: location.longitude!, lat: location.latitude!);
      for (var element in street.poly) {
        var latlng = Geographic(lon: element.longitude, lat: element.latitude);
        var arc = pos.vincenty().inverse(latlng);
        final distanceKm = arc.distance / 1000.0;
        if (distanceKm < distance) {
          distance = distanceKm;
        }

        //log(distance.toStringAsFixed(2), name: 'distance in Km');
      }
    } catch (e) {
      log(e.toString());
      return double.infinity;
    }
    return distance;
  }

  // TODO : Filter geobase < 1 km from user position
  void onLocationChanged(List<Street> streets) async {
    List<Street> filteredStreets = [];
    final Location lc = Location();

    // var getLocation = await lc.getLocation();

    /* for (var street in streets) {
      double distance = calculateDistance2(street, getLocation);
      filteredStreets.add(street);
      if (distance < 25) {
        filteredStreets.add(street);
      } else {
        filteredStreets.remove(street);
      }
    }
    renderPolylines(filteredStreets); */

    Debouncer debouncer = Debouncer(milliseconds: 500);

    lc.onLocationChanged.listen((loc) {
      debouncer.run(() {
        // renderPolylines(streets, loc);
        Set<Street> newFilteredStreets =
            {}; // Use a local set to store the current valid streets

        for (var street in streets) {
          double distance = calculateDistance2(street, loc);
          if (distance <= 10) {
            newFilteredStreets.add(street);
          }
          // Streets not within the distance are naturally not added to newFilteredStreets
        }

        // Update the filteredStreets set only if there are changes
        if (!setEquals(filteredStreets.toSet(), newFilteredStreets)) {
          filteredStreets = newFilteredStreets.toList();
          renderPolylines(filteredStreets);
        }
      });
    });
  }

}

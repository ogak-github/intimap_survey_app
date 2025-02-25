import 'dart:async';
import 'dart:developer' as d;
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:survey_app/data/routing_fn.dart';
import 'package:survey_app/data/street_spatialite.dart';
import 'package:survey_app/model/route_issue.dart';
import 'package:survey_app/utils/app_logger.dart';
import 'package:survey_app/utils/custom_marker.dart';
import 'package:survey_app/utils/poly_colors.dart';

import '../api/street_api.dart';
import '../main.dart';
import '../model/street.dart';
import 'compute_data_provider.dart';
import 'hive_street_provider.dart';

part 'street_provider.g.dart';

@riverpod
Future<bool> updateData(Ref ref, List<Street> newStreets) async {
  final api = ref.watch(streetAPIProvider);
  bool result = await api.updateBulk(newStreets);

  return result;
}

@riverpod
class LoadAllStreet extends _$LoadAllStreet {
  @override
  FutureOr<void> build() async {
    MyLogger("Load all street").i("Called");
    EasyLoading.show(status: 'Sync data...');
    final streetBox = Hive.box<Street>('streets');
    if (streetBox.isNotEmpty) {
      final data = streetBox.values.toList();
      final providerResult = await ref.read(updateDataProvider(data).future);

      if (providerResult) {
        for (var street in data) {
          ref.read(hiveStreetProvider.notifier).removeStreet(street);
        }
      } else {
        MyLogger("Upload failed").e("data not uploaded");
      }
    }

    final api = ref.watch(streetAPIProvider);
    var streets = await api.loadAll();
    MyLogger("Total loaded streets").d(streets.length.toString());
    EasyLoading.dismiss();

    /// call fillDataIntoDB
    EasyLoading.show(status: 'Processing data...');
    await runInBackground(streets);
    EasyLoading.dismiss();
  }

  Future<void> runInBackground(List<Street> streets) async {
    final streetProvider = ref.watch(streetDataProvider);
    final response = ReceivePort();
    await Isolate.spawn(_processData, [streets, response.sendPort]);
    var processedStreets = await response.first;

    await streetProvider.fillBatchDataIntoDB(processedStreets);
  }

  static void _processData(List<dynamic> args) async {
    List<Street> streets = args[0];
    SendPort sendPort = args[1];
    sendPort.send(streets); // Notify completion
  }
}

class MapData {
  final Set<Polyline> polylines;
  final Set<Marker> markers;

  MapData(this.polylines, this.markers);
}

@Riverpod(keepAlive: true)
class DrawStreet extends _$DrawStreet {
  Street? _selectedStreet;
  @override
  FutureOr<MapData> build() async {
    MyLogger("Draw street").i("Called");
    //List<Street> data = [];
    Set<Polyline> polylines = {};
    Set<Marker> markers = {};

    //final data = await ref.watch(_processedStreetDataProvider.future);
    ref.listen(processedStreetDataProvider.future, (previous, next) async {
      var data = await next;

      renderPolylines(data.streets, data.selectedStreet);
      renderMarkers(data.streets);
    });

    ref.onDispose(() {});

    return MapData(polylines, markers);
  }

  void updateStreetData(Street street) {
    ref.read(inMemoryStreetProvider.notifier).update(street);
    // ref.invalidateSelf();
  }

  void loadStreetData() async {
    EasyLoading.show(status: 'Loading streets..');
    ref.invalidate(inMemoryStreetProvider);
    EasyLoading.dismiss();
  }

/*   double _calculateDistancePoint(LatLng p1, LatLng p2) {
    double distance = double.infinity;
    try {
      var pos = Geographic(lon: p1.longitude, lat: p1.latitude);

      var latlng = Geographic(lon: p2.longitude, lat: p2.latitude);
      var arc = pos.vincenty().inverse(latlng);
      final distanceKm = arc.distance / 1000.0;
      if (distanceKm < distance) {
        distance = distanceKm;
      }
      return distance;
    } catch (e) {
      d.log(e.toString());
      return double.infinity;
    }
  } */

  void getBlockPoint(LatLng? tapPoint) async {
    final routeFunction = await ref.read(routingFnProvider.future);

    try {
      var blockPoint = await routeFunction?.getTapPointFromPolylines(
          tapPoint!, _selectedStreet!.id.toString());

      d.log(blockPoint.toString(), name: "block point");

      var notes = await showGlobalDialog();
      var routeIssueData = RouteIssueData(
        _selectedStreet!.id.toInt(),
        true,
        notes ?? "",
        "POINT(${blockPoint!.longitude} ${blockPoint.latitude})",
      );
      d.log(notes.toString(), name: "block point");

      await addToTmpMarker(blockPoint, routeIssueData);
    } catch (e) {
      MyLogger("Get block point").e(e.toString());
      return;
    }
  }

  Future<void> addToTmpMarker(
      LatLng blockPoint, RouteIssueData routeIssueData) async {
    ref
        .read(markerDataProvider.notifier)
        .addBlockMarker(blockPoint, routeIssueData);
  }

  void renderMarkers(List<Street> street) async {
    Set<Marker> blockedMarker = {};
    final streetProvider = ref.watch(streetDataProvider);
    List<RouteIssue> routeIssues = await streetProvider
        .getRouteIssue(street.map((e) => e.id.toInt()).toList());
    for (var issue in routeIssues) {
      blockedMarker.add(
        Marker(
          markerId: MarkerId(issue.id.toString()),
          position: issue.point,
          anchor: const Offset(0.5, 0.5),
          icon: await noEntrySignMarker(),
          onTap: () async {},
        ),
      );
    }

    state = AsyncValue.data(
        MapData({...state.value!.polylines}, {...blockedMarker}));
  }

  Future<String?> showGlobalDialog() async {
    return showDialog<String?>(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final TextEditingController ctrl = TextEditingController();
          return AlertDialog(
            title: const Text('Route notes: '),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Input notes',
                    labelStyle:
                        TextStyle(color: Theme.of(context).disabledColor),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () async {
                    if (context.mounted) {
                      Navigator.of(context).pop(ctrl.text);
                    }
                  },
                ),
              ),
            ],
          );
        });
      },
    );
  }

  void renderPolylines(List<Street> street, Street? selectedStreet) {
    d.log("Rendering ${street.length}", name: "Polylines");

    Set<Polyline> newPolylines = {};
    Set<Marker> newMarkers = {};
    Set<Polyline> selectedPolyline = {};
    if (selectedStreet != null) {
      _selectedStreet = selectedStreet;
      selectedPolyline.add(
        Polyline(
          consumeTapEvents: true,
          width: 7,
          polylineId: PolylineId("${selectedStreet.id}-selected"),
          points: selectedStreet.poly,
          color: Colors.indigoAccent,
          onTap: () async {},
        ),
      );
    }

    for (var element in street) {
      newPolylines.add(
        Polyline(
          consumeTapEvents: true,
          width: 3,
          polylineId: PolylineId(element.id.toString()),
          points: element.poly,
          color: polyColorByRoad(element),
          onTap: () async {
            MyLogger("Metadata").d(element.meta.toString());
            // ref.read(focusedStreetProvider.notifier).select(element);
          },
        ),
      );
    }

    d.log(newPolylines.length.toString(), name: "Polyline length");
    d.log(newMarkers.length.toString(), name: "Marker length");
    state = AsyncValue.data(
        MapData({...newPolylines, ...selectedPolyline}, {...newMarkers}));
  }

/*   double calculateDistance2(Street street, LocationData location) {
    double distance = double.infinity;
    try {
      var pos = Geographic(lon: location.longitude!, lat: location.latitude!);
      for (var element in street.poly) {
        var latlng = Geographic(lon: element.longitude, lat: element.latitude);
        var arc = pos.vincenty().inverse(latlng);
        final distanceKm = arc.distance / 1000.0;
        if (distanceKm < distance) {
          distance = distanceKm;
        }
      }
    } catch (e) {
      d.log(e.toString());
      return double.infinity;
    }
    return distance;
  } */
}

@riverpod
class LoadedStreetData extends _$LoadedStreetData {
  @override
  Future<List<Street>> build() async {
    MyLogger("In Memory Street").i("Called");
    final streetProvider = ref.watch(streetDataProvider);
    final streets = await streetProvider.getStreet();
    state = AsyncValue.data(streets);
    return streets;
  }

  void clear() {
    state = const AsyncValue.data([]);
  }

  void addAll(List<Street> streets) {
    state = AsyncValue.data(streets);
  }
}

@riverpod
class InMemoryStreet extends _$InMemoryStreet {
  @override
  List<Street> build() {
    return [];
  }

  void addAll(List<Street> streets) {
    MyLogger("In Memory Street Add").d(streets.length.toString());
    state = [...state.toSet(), ...streets.toSet()];
    ref.notifyListeners();
  }

  /// Updating row value data and replace the list
  void update(Street street) {
    //MyLogger("In Memory Street Update").i(street.toString());
    for (int i = 0; i < state.length; i++) {
      if (state[i].id == street.id) {
        // Replace the old street with the updated one at the same index
        state[i] = state[i].copyWith(
            truk: street.truk,
            pickup: street.pickup,
            roda3: street.roda3,
            lastModifiedTime: street.lastModifiedTime);
        MyLogger("Street updated").i(state[i].toString());
        break; // Exit the loop once the street is found and updated
      }
    }
    ref.notifyListeners(); // Notify listeners about the change
  }
}

@riverpod
class FocusedStreet extends _$FocusedStreet {
  @override
  Street? build() {
    return null;
  }

  void select(Street? street) {
    state = street;
  }

  void clear() {
    state = null;
  }
}

@riverpod
Future<RoutingFn?> routingFn(Ref ref) async {
  final streetProvider = ref.watch(streetDataProvider);
  return RoutingFn(streetProvider);
}

@riverpod
class MarkerData extends _$MarkerData {
  @override
  Set<TmpRouteData> build() {
    return {};
  }

  void addBlockMarker(LatLng point, RouteIssueData routeIssue) async {
    Marker? tmpTxtMarker;
    var tmpMarker = Marker(
      markerId: MarkerId(point.toString()),
      position: point,
      anchor: const Offset(0.5, 0.5),
      icon: await noEntrySignMarkerOpacity(),
      onTap: () {
        // Remove the marker from the state
        state.removeWhere((e) => e.marker.markerId.value == point.toString());
      },
    );
    if (routeIssue.notes.isNotEmpty && routeIssue.notes != "") {
      tmpTxtMarker = Marker(
        markerId: MarkerId(point.toString() + routeIssue.notes),
        position: point,
        anchor: const Offset(0.5, -1.0),
        icon: await createTextBitmapDescriptor(routeIssue.notes),
      );
    }

    state = {...state, TmpRouteData(tmpMarker, tmpTxtMarker, routeIssue)};
  }

  void saveToDatabase(RouteIssueData routeIssue) async {
    final streetProvider = ref.watch(streetDataProvider);
    await streetProvider.addRouteIssue(routeIssue);
  }
}

class TmpRouteData {
  final Marker marker;
  final Marker? txtMarker;
  final RouteIssueData routeIssue;

  TmpRouteData(this.marker, this.txtMarker, this.routeIssue);
}

final tapPointProvider = StateProvider<LatLng?>((ref) => null);

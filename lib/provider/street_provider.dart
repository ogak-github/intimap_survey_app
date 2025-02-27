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
import 'package:survey_app/provider/clustered_marker_provider.dart';
import 'package:survey_app/utils/app_logger.dart';
import 'package:survey_app/utils/custom_marker.dart';
import 'package:survey_app/utils/poly_colors.dart';
import 'package:uuid/uuid.dart';

import '../api/street_api.dart';
import '../main.dart';
import '../model/street.dart';
import 'compute_data_provider.dart';
import 'hive_street_provider.dart';

part 'street_provider.g.dart';

@riverpod
class LoadAllIssues extends _$LoadAllIssues {
  @override
  Future<List<RouteIssue>> build() async {
    final streetData = ref.watch(streetDataProvider);
    var listRoute = await streetData.getRouteIssues();
    return listRoute;
  }
}

@riverpod
Future<bool> updateData(Ref ref, List<Street> newStreets) async {
  final api = ref.watch(streetAPIProvider);
  bool result = await api.updateBulk(newStreets);

  return result;
}

@riverpod
Future<bool> updateIssue(Ref ref, List<RouteIssue> newIssue) async {
  final api = ref.watch(streetAPIProvider);
  bool result = await api.updateBulkRouteIssue(newIssue);
  return result;
}

@riverpod
Future<bool> deleteIssue(Ref ref, String id) async {
  final api = ref.watch(streetAPIProvider);
  bool result = await api.deleteRouteIssue(id);
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

    final issueBox = Hive.box<RouteIssue>('route_issues');
    if (issueBox.isNotEmpty) {
      final data = issueBox.values.toList();
      final provider = await ref.read(updateIssueProvider(data).future);
      if (provider) {
        MyLogger("Update issue").i("Success");
        for (var issue in data) {
          ref.read(hiveRouteIssueProvider.notifier).removeRouteIssue(issue);
        }
      }
    }

    final api = ref.watch(streetAPIProvider);
    final prov = ref.watch(streetDataProvider);
    var streets = await api.loadAll();
    var issues = await api.getRouteIssues();
    MyLogger("Total loaded streets").d(streets.length.toString());
    MyLogger("Total loaded issues").d(issues.length.toString());
    EasyLoading.dismiss();

    /// call fillDataIntoDB
    EasyLoading.show(status: 'Processing data...');
    await runInBackground(streets, prov);
    await runInBackground2(issues, prov);
    EasyLoading.dismiss();
  }

  Future<void> runInBackground(
      List<Street> streets, StreetData streetDataProvider) async {
    final response = ReceivePort();
    await Isolate.spawn(_processData, [streets, response.sendPort]);
    var processedStreets = await response.first;

    await streetDataProvider.fillBatchDataIntoDB(processedStreets);
  }

  static void _processData(List<dynamic> args) async {
    List<Street> streets = args[0];
    SendPort sendPort = args[1];
    sendPort.send(streets); // Notify completion
  }

  Future<void> runInBackground2(
      List<RouteIssue> issues, StreetData streetDataProvider) async {
    final response = ReceivePort();
    await Isolate.spawn(_processData2, [issues, response.sendPort]);
    var processedIssuesData = await response.first;
    await streetDataProvider.fillBatchRouteIssueIntoDB(processedIssuesData);
  }

  static void _processData2(List<dynamic> args) async {
    List<RouteIssue> issues = args[0];
    SendPort sendPort = args[1];
    sendPort.send(issues); // Notify completion
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
  bool isDialogOpen = false;
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

  void reloadDrawStreet() async {
    final data = await ref.read(processedStreetDataProvider.future);
    renderPolylines(data.streets, data.selectedStreet);
    renderMarkers(data.streets);
  }

  void getBlockPoint(LatLng? tapPoint) async {
    final routeFunction = await ref.read(routingFnProvider.future);
    final streetProvider = ref.watch(streetDataProvider);

    try {
      var blockPoint = await routeFunction?.getTapPointFromPolylines(
          tapPoint!, _selectedStreet!.id.toString());

      d.log(blockPoint.toString(), name: "block point");
      isDialogOpen = true;
      var notes = await showNotesDialog();
      isDialogOpen = false;
      var routeIssueData = RouteIssueData(
        const Uuid().v4(),
        _selectedStreet!.id.toInt(),
        1,
        notes ?? "",
        "POINT(${blockPoint!.longitude} ${blockPoint.latitude})",
      );

/*       var routeIssueHive = RouteIssue(
        id: const Uuid().v4(),
        streetId: _selectedStreet!.id.toInt(),
        blocked: 1,
        notes: notes ?? "",
        geom: "POINT(${blockPoint.longitude} ${blockPoint.latitude})",
      ); */

      //await addToTmpMarker(blockPoint, routeIssueData);
      streetProvider.addRouteIssue(routeIssueData).then((value) {
        reloadDrawStreet();
        ref.read(hiveRouteIssueProvider.notifier).addRouteIssue(routeIssueData);
      });
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
    //Set<Marker> textMarker = {};
    final streetProvider = ref.watch(streetDataProvider);
    List<RouteIssue> routeIssues = await streetProvider
        .getRouteIssue(street.map((e) => e.id.toInt()).toList());
    for (var issue in routeIssues) {
      final BitmapDescriptor descriptor =
          await CustomMarkerHelper.createNoEntryMarkerWithText(
              text: issue.notes, imageSize: 32.0, textFontSize: 12.0);
      blockedMarker.add(
        Marker(
          markerId: MarkerId(issue.id.toString()),
          position: issue.point,
          anchor: issue.notes == null || issue.notes == ""
              ? const Offset(0.5, 0.5)
              : const Offset(0.5, 0.3),
          icon: descriptor, //await noEntrySignWithText(text: issue.notes),
          onTap: () async {
            // Remove the marker from the state and database
            isDialogOpen = true;
            await showDeleteMarkerDialog(issue, streetProvider);
            blockedMarker.removeWhere(
              (marker) => marker.position.toString() == issue.point.toString(),
            );
            isDialogOpen = false;
          },
        ),
      );
      /*  if (issue.notes != null && issue.notes != "") {
        textMarker.add(Marker(
          markerId: MarkerId("${issue.id}-text"),
          position: issue.point,
          anchor: const Offset(0.5, -1.0),
          icon: await createTextBitmapDescriptor(issue.notes!),
        ));
      } */
    }
    d.log(blockedMarker.length.toString(), name: "Marker length");

    state = AsyncValue.data(
        MapData({...state.value!.polylines}, {...blockedMarker}));
  }

  Future<void> showDeleteMarkerDialog(
      RouteIssue issue, StreetData provider) async {
    return showDialog<void>(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Delete marker'),
        content: const Text('Are you sure you want to delete the marker?'),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              var deleted = await provider.deleteRouteIssue(issue.id);
              if (deleted) {
                reloadDrawStreet();
                _clearTmpMarker(issue.point);
                ref
                    .read(hiveRouteIssueProvider.notifier)
                    .removeRouteIssue(issue);
                final deleting =
                    await ref.read(deleteIssueProvider(issue.id).future);
                if (deleting) {
                  MyLogger("Deleting from server").i("Success");
                } else {
                  /// Add to hive for later deleting
                  ref
                      .read(deletedRouteIssueProvider.notifier)
                      .addDeletedId(issue.id);
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _clearTmpMarker(LatLng point) {
    ref.read(markerDataProvider.notifier).removeBlockMarker(point);
  }

  Future<String?> showNotesDialog() async {
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

  void removeBlockMarker(LatLng point) {
    state.removeWhere((e) => e.marker.markerId.value == point.toString());
  }
}

class TmpRouteData {
  final Marker marker;
  final Marker? txtMarker;
  final RouteIssueData routeIssue;

  TmpRouteData(this.marker, this.txtMarker, this.routeIssue);
}

final tapPointProvider = StateProvider<LatLng?>((ref) => null);

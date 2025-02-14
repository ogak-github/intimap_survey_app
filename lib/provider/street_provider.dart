import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geobase/geobase.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:location/location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:survey_app/data/street_spatialite.dart';
import 'package:survey_app/provider/my_location_provider.dart';
import 'package:survey_app/ui/map_widget.dart';
import 'package:survey_app/utils/app_logger.dart';

import '../api/street_api.dart';
import '../model/street.dart';
import 'hive_street_provider.dart';

part 'street_provider.g.dart';

final streetData = StreetData(StreetSpatialite());

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
    final response = ReceivePort();
    await Isolate.spawn(_processData, [streets, response.sendPort]);
    var processedStreets = await response.first;
    await streetData.fillBatchDataIntoDB(processedStreets);
    ref.read(inMemoryStreetProvider).clear();
    ref.read(inMemoryStreetProvider.notifier).addAll(streets);
  }

  static void _processData(List<dynamic> args) async {
    List<Street> streets = args[0];
    SendPort sendPort = args[1];
    sendPort.send(streets); // Notify completion
  }
}

@Riverpod(keepAlive: true)
class DrawStreet extends _$DrawStreet {
  @override
  FutureOr<Set<Polyline>> build() async {
    MyLogger("Draw street").i("Called");
    //List<Street> data = [];
    Set<Polyline> polylines = {};

    try {
      final locPermission = await ref.read(checkPermissionProvider.future);
      var inMemory = ref.read(inMemoryStreetProvider);
      if (inMemory.isEmpty) {
        final streetData = await ref.read(loadedStreetDataProvider.future);
        ref.read(inMemoryStreetProvider.notifier).addAll(streetData);
        inMemory = ref.read(inMemoryStreetProvider);
      }
      if (locPermission == true) {
        ref.listen<LocationData?>(myCurrentLocationProvider, (previous, next) {
          if (next != null) {
            onLocationChanged(inMemory, next);
            /*  MyLogger("Location changed")
              .i("User moved: ${next.latitude}, ${next.longitude}"); */
          }
        });
      }
      MyLogger("Draw street").i("${inMemory.length}");
    } catch (e) {
      MyLogger("Error").e(e.toString());
    }

/*     if (currentLocation != null) {
      MyLogger("My Location").i(
          "User moved to ${currentLocation!.latitude}, ${currentLocation!.longitude}");
      Timer.periodic(const Duration(seconds: 5), (timer) {
        onLocationChanged(streetData, currentLocation!);
      });
    } */
    return polylines;
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

  void renderPolylines(List<Street> street) {
    final panelCtr = ref.watch(panelController);
    log("Rendering ${street.length}", name: "Polylines");
    Set<Polyline> newPolylines = {};
    for (var element in street) {
      newPolylines.add(
        Polyline(
          consumeTapEvents: true,
          width: 3,
          polylineId: PolylineId(element.id.toString()),
          points: element.poly,
          color: Colors.red,
          onTap: () async {
            MyLogger("Metadata").d(element.meta.toString());
            ref.read(focusedStreetProvider.notifier).select(element);
            await panelCtr.animatePanelToSnapPoint();
          },
        ),
      );
    }
    log(newPolylines.length.toString(), name: "Polyline length");
    state = AsyncValue.data(newPolylines);
  }

  double calculateDistance2(Street street, LocationData location) {
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
      log(e.toString());
      return double.infinity;
    }
    return distance;
  }

  // TODO : Filter geobase < 1 km from user position
  void onLocationChanged(List<Street> streets, LocationData loc) async {
    List<Street> filteredStreets = [];
    Set<Street> newFilteredStreets =
        {}; // Use a local set to store the current valid streets

    for (var street in streets) {
      double distance = calculateDistance2(street, loc);
      if (distance <= 1) {
        newFilteredStreets.add(street);
      }
      // Streets not within the distance are naturally not added to newFilteredStreets
    }

    // Update the filteredStreets set only if there are changes
    if (!setEquals(filteredStreets.toSet(), newFilteredStreets)) {
      filteredStreets = newFilteredStreets.toList();
      renderPolylines(filteredStreets);
    }
  }
}

@riverpod
class LoadedStreetData extends _$LoadedStreetData {
  @override
  Future<List<Street>> build() async {
    /*    EasyLoading.show(status: 'Loading streets from local DB...');
    var streets = await streetData.getStreet();
    MyLogger("Total loaded streets").i(streets.length.toString());
    state = AsyncValue.data(streets);
    yield streets; */
    MyLogger("In Memory Street").i("Called");
    final streets = await streetData.getStreet();
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

  void select(Street street) {
    state = street;
  }

  void clear() {
    state = null;
  }
}

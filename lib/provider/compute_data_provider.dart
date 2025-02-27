import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:developer' as d;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:location/location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/routing_data.dart';
import '../model/street.dart';
import '../utils/app_logger.dart';
import '../utils/unique_id.dart';
import 'my_location_provider.dart';
import 'street_provider.dart';

part 'compute_data_provider.g.dart';

class ResultSetData {
  final List<Street> streets;
  final Street? selectedStreet;

  ResultSetData(this.streets, this.selectedStreet);
}

@riverpod
class ProcessedStreetData extends _$ProcessedStreetData {
  Timer? _timer;
  final double _locationChangeThreshold = 15.0; // meters
  LocationData? _lastLocation;
  bool _canProcessLocation = true;
  @override
  Future<ResultSetData> build() async {
    final locPermission = await ref.read(checkPermissionProvider.future);

    try {
      if (locPermission == true) {
        ref.listen(myCurrentLocationProvider, (_, loc) {
          if (loc == null || !_canProcessLocation) return;
          /*   if(_isLocationChangeSignificant(loc, _lastLocation)) {
            _lastLocation = loc;
          } */

          _lastLocation = loc;

          MyLogger("Location").i(loc.toString());

          _processLocation(loc);
          _canProcessLocation = false;
          _timer = Timer(const Duration(seconds: 30), () {
            _canProcessLocation = true;
          });
        });
      }

      ref.onDispose(() {
        _timer?.cancel();
      });
    } catch (e) {
      MyLogger("Error").e(e.toString());
    }
    return ResultSetData([], null);
  }

  void reloadProcessLocation() async {
    final loc = Location();

    final locData = await loc.getLocation();
    _lastLocation = locData;
    _processLocation(locData);
  }

  bool _isLocationChangeSignificant(
      LocationData newLoc, LocationData? lastLoc) {
    bool result = false;
    if (lastLoc == null) return true;
    ref.listen(myCurrentLocationProvider, (_, loc) {
      var distance = _calculateDistance(newLoc.latitude!, newLoc.longitude!,
          lastLoc.latitude!, lastLoc.longitude!);
      result = distance > _locationChangeThreshold;
    });
    return result;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula or similar to calculate distance between two coordinates
    var r = 6371; // Radius of the Earth in km
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c * 1000; // Convert to meters
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Future<List<RoutingPoint2>?> _computeSegment(LocationData loc) async {
    final routeFunction = await ref.read(routingFnProvider.future);

    try {
      final newUniqId = uniqIdMd5();
      var routePoints = await routeFunction?.computeSegmentAgaintsPoint(loc,
          queryId: newUniqId);

      return routePoints;
    } catch (e) {
      AppLogger().logger.e(e.toString());
      return [];
    }
  }

  Future<SelectedRouteInfo2?> _computeSegmentInfo(LocationData loc) async {
    final routeFunction = await ref.read(routingFnProvider.future);
    try {
      final newUniqId = uniqIdMd5();
      return await routeFunction?.getRouteSegment(loc, uniqId: newUniqId);
    } catch (e) {
      AppLogger().logger.e(e.toString());
      return null;
    }
  }

  Future<void> _processLocation(LocationData loc) async {
    var routePoints = await _computeSegment(loc);
    var selectedRoute = await _computeSegmentInfo(loc);
    List<int> ids = [];
    if (routePoints == null) return;

    d.log("${selectedRoute?.toJson()}", name: "Selected route points");
    MyLogger("User current location").i(loc.toString());
    List<Street> newFilteredStreets =
        routePoints.map((e) => e.street).whereType<Street>().toList();

    //renderPolylines(newFilteredStreets, selectedRoute?.lastOkPoint.street);
    state = AsyncValue.data(
        ResultSetData(newFilteredStreets, selectedRoute?.lastOkPoint.street));
    ref
        .watch(focusedStreetProvider.notifier)
        .select(selectedRoute?.lastOkPoint.street);

    /*  if (!setEquals(filteredStreets.toSet(), newFilteredStreets)) {
      filteredStreets = newFilteredStreets.toList();
      renderPolylines(filteredStreets, loc);
    } */

    for (var street in newFilteredStreets) {
      ids.add(street.id);
    }

    MyLogger("Filtered Streets ${ids.length}").i(ids.join(","));
  }
}

class ComputeSegmentData {
  final SendPort sendPort;
  final LocationData location;

  ComputeSegmentData(this.sendPort, this.location);
}

import 'dart:async';
import 'dart:developer' as d;

import 'package:location/location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:survey_app/provider/location_service.dart';

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
  //Timer? _timer;
  final double _locationChangeThreshold = 15.0; // meters
  // LocationData? _lastLocation;
  // bool _canProcessLocation = true;
  double _currentSpeed = 0.0;
  @override
  Future<ResultSetData> build() async {
    final locPermission = await ref.read(checkPermissionProvider.future);
    if (locPermission) {
      final locationService = ref.watch(locationServiceProvider);
      locationService.startLocationUpdates(
          accuracy: LocationAccuracy.navigation,
          interval: _determineSpeed(_currentSpeed));
      locationService.locationStream.listen((loc) {
        if (loc == null) return;
        MyLogger("My Current Location DATA").i(
            "${((loc.speed ?? 0) * 3600 / 1000).toStringAsFixed(2)} Km/h, Interval: ${_determineSpeed(_currentSpeed)}");
        _currentSpeed = loc.speed ?? 0;
        _processLocation(loc);
      });
      ref.onDispose(() {
        locationService.dispose();
      });
    }

    return ResultSetData([], null);
  }

  int _determineSpeed(double speedInMph) {
    double speedInKmh = speedInMph * 3600 / 1000;

    if (speedInKmh > 60) return 10000;
    if (speedInKmh > 35) return 15000;
    if (speedInKmh < 30) return 30000;
    return 30000;
  }

  void reloadProcessLocation() async {
    final loc = Location();

    final locData = await loc.getLocation();
    //_lastLocation = locData;
    _processLocation(locData);
  }

  Future<List<RoutingPoint2>?> _computeSegment(LocationData loc) async {
    final routeFunction = await ref.read(routingFnProvider.future);

    try {
      final newUniqId = uniqIdMd5();
      var routePoints = await routeFunction?.computeSegmentAgaintsPoint(loc,
          queryId: newUniqId);

      return routePoints;
    } catch (e) {
      MyLogger("Compute segment").e(e.toString());
      return [];
    }
  }

  Future<SelectedRouteInfo2?> _computeSegmentInfo(LocationData loc) async {
    final routeFunction = await ref.read(routingFnProvider.future);
    try {
      final newUniqId = uniqIdMd5();
      return await routeFunction?.getRouteSegment(loc, uniqId: newUniqId);
    } catch (e) {
      MyLogger("Compute segment info").e(e.toString());
      return null;
    }
  }

  Future<void> _processLocation(LocationData loc) async {
    var routePoints = await _computeSegment(loc);
    var selectedRoute = await _computeSegmentInfo(loc);
    if (routePoints == null) return;

    //d.log("${selectedRoute?.toJson()}", name: "Selected route points");
    MyLogger("Selected Route ID").d("${selectedRoute?.point?.id}");
    List<Street> newFilteredStreets =
        routePoints.map((e) => e.street).whereType<Street>().toList();

    //renderPolylines(newFilteredStreets, selectedRoute?.lastOkPoint.street);
    state = AsyncValue.data(
        ResultSetData(newFilteredStreets, selectedRoute?.lastOkPoint.street));

    ref
        .watch(focusedStreetProvider.notifier)
        .select(selectedRoute?.lastOkPoint.street);
  }
}

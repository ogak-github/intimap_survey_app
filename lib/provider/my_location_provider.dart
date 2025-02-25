import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:location/location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/app_logger.dart';

part 'my_location_provider.g.dart';

@riverpod
class MyLocation extends _$MyLocation {
  @override
  Future<LocationData?> build() async {
    final Location lc = Location();
    return await lc.getLocation();
  }

  void watchLocation() {
    final Location lc = Location();
    lc.onLocationChanged.listen((event) {
      state = AsyncValue.data(event);
    });
  }
}

@riverpod
class CheckService extends _$CheckService {
  @override
  Future<bool> build() async {
    final lc = Location();
    var serviceEnabled = await lc.serviceEnabled();
    return serviceEnabled;
  }

  void listenServiceChange() async {
    final lc = Location();
    final stream = lc.serviceEnabled().asStream();
    stream.listen((event) {
      state = AsyncValue.data(event);
    });
  }
}

@riverpod
class CheckPermission extends _$CheckPermission {
  @override
  Future<bool> build() async {
    final lc = Location();
    var permissionGranted = await lc.hasPermission();
    return permissionGranted == PermissionStatus.granted;
  }

  void listenPermissionChange() async {
    final lc = Location();
    final stream = lc.hasPermission().asStream();
    stream.listen((event) {
      state = AsyncValue.data(event == PermissionStatus.granted);
    });
  }
}

@riverpod
class RequestPermission extends _$RequestPermission {
  @override
  void build() {}

  void reqEnableService() async {
    final lc = Location();
    await lc.requestService();
  }

  Future<bool> reqAccessLocation() async {
    final lc = Location();
    var req = await lc.requestPermission();
    if (req == PermissionStatus.granted) {
      return true;
    }
    return false;
  }
}

@Riverpod(keepAlive: true)
class MyCurrentLocation extends _$MyCurrentLocation {
  @override
  LocationData? build() {
    Timer? timer;

    timer = Timer.periodic(const Duration(seconds: 25), (_) {
      _watchLocation();
    });

    ref.onDispose(() {
      timer?.cancel();
    });

    return null;
  }

  /*  void _subsribeLocation() {
    final listener = ref.listen<Future<LocationData?>>(
        locationUpdateProvider.future, (prev, next) async {
      final pos = await next;
      if (pos != null) {
        if (kDebugMode && pos.isMock != true) return;
        MyLogger("Current position").i(pos.speed.toString());
        state = pos;
      }
    });
    ref.onDispose(() {
      AppLogger().logger.d("MyLocationProvider disposed");
      listener.close();
    });
  } */

  void _watchLocation() {
    final lc = Location();
    lc.changeSettings(
        accuracy: LocationAccuracy.navigation,
        interval: kDebugMode ? 12000 : 30000);
    lc.onLocationChanged.listen((event) {
      state = event;
    }).onDone(() {
      AppLogger().logger.d("OnLocationChanged done");
    });

    ref.onDispose(() {
      AppLogger().logger.d("MyLocationProvider disposed");
    });
  }
}

@Riverpod(keepAlive: true)
bool hasLocation(Ref ref) {
  AppLogger().logger.d("Rebuilding hasLocation");
  return ref.watch(myLocationProvider.select((value) => value != null));
}

@Riverpod(keepAlive: true)
class LocationUpdate extends _$LocationUpdate {
  @override
  Stream<LocationData?> build() async* {
    AppLogger().logger.d("locationUpdateProvider rebuild");
    final requestStatus = await ref.watch(checkPermissionProvider.future);

    if (requestStatus != true) {
      yield null;
      return;
    }

    await Location()
        .changeSettings(accuracy: LocationAccuracy.navigation, interval: 1000);
    yield* Location().onLocationChanged;
  }
}

import 'package:location/location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  void reqAccessLocation() async {
    final lc = Location();
    await lc.requestPermission();
  }
}

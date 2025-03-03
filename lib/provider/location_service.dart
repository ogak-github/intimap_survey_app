import 'dart:async';

import 'package:location/location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class LocationService {
  StreamSubscription<LocationData?>? _locationSubscription;
  final StreamController<LocationData?> _locationController =
      StreamController<LocationData?>.broadcast();
  double _speedInKm = 0;
  Stream<LocationData?> get locationStream => _locationController.stream;
  double get speedInKm => _speedInKm;

  Future<void> startLocationUpdates(
      {LocationAccuracy accuracy = LocationAccuracy.high,
      int interval = 5000}) async {
    if (_locationSubscription != null) {
      await _locationSubscription!.cancel();
      _locationSubscription = null;
    }

    await Location().changeSettings(accuracy: accuracy, interval: interval);

    _locationSubscription = Location().onLocationChanged.listen((locationData) {
      _speedInKm = (locationData.speed ?? 0) * 3600 / 1000;
      if (_locationController.isClosed == false) {
        _locationController.add(locationData);
      }
    });
  }

  void dispose() {
    _locationSubscription?.cancel();
    _locationController.close();
  }
}

final locationServiceProvider = Provider((ref) => LocationService());

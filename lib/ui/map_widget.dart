import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:survey_app/provider/my_location_provider.dart';
import 'package:survey_app/provider/street_provider.dart';
import 'components/custom_text_box.dart';

final getLocationLoading = StateProvider<bool>((ref) => false);

class MapView extends StatefulHookConsumerWidget {
  const MapView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  GoogleMapController? _mapController;
  bool _mapCreated = false;
  double latitude = -0.7893;
  double longitude = 113.9213;
  Set<Polyline> _polylines = {};
  final bool _followLocation = false;

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _mapCreated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(getLocationLoading);
    final loadPolyline = ref.watch(drawStreetProvider);
    useEffect(() {
      loadPolyline.whenData((street) {
        setState(() {
          _polylines = street;
        });
      });
      return null;
    }, [loadPolyline]);

    useEffect(() {
      return null;
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            polylines: _polylines,
            onMapCreated: _onMapCreated,
            zoomControlsEnabled: false,
            initialCameraPosition:
                CameraPosition(target: LatLng(latitude, longitude), zoom: 2),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          if (_mapCreated) ...[
            Positioned(
              right: 15,
              bottom: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.small(
                    child: const Icon(Icons.refresh),
                    onPressed: () {
                      ref.invalidate(drawStreetProvider);
                    },
                  ),
                  const SizedBox(height: 15),
                  GpsFab(controller: _mapController!),
                ],
              ),
            ),
            Positioned(
              left: 15,
              bottom: 15,
              child: ZoomControlFab(controller: _mapController!),
            ),
          ],
          isLoading
              ? const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: CustomTextBox(
                      text: "Loading...",
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class ZoomControlFab extends HookConsumerWidget {
  final GoogleMapController controller;
  const ZoomControlFab({super.key, required this.controller});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        FloatingActionButton.small(
          child: const Icon(Icons.zoom_in),
          onPressed: () {
            controller.animateCamera(CameraUpdate.zoomIn());
          },
        ),
        const SizedBox(height: 5),
        FloatingActionButton.small(
          child: const Icon(Icons.zoom_out),
          onPressed: () {
            controller.animateCamera(CameraUpdate.zoomOut());
          },
        ),
      ],
    );
  }
}

class GpsFab extends HookConsumerWidget {
  final GoogleMapController controller;
  const GpsFab({super.key, required this.controller});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final following = useState(false);
    final serviceState = useState(false);
    final permissionState = useState(false);
    var service = ref.watch(checkServiceProvider);
    var permission = ref.watch(checkPermissionProvider);

    if (following.value) {
      ref.watch(myLocationProvider.notifier).watchLocation();
      ref.listen(myLocationProvider, (previous, next) {
        log(next.value!.heading.toString());
        if (following.value) {
          next.whenData((location) async {
            if (location == null) return;
            double zoom = await controller.getZoomLevel();
            controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(location.latitude!, location.longitude!),
                    zoom: zoom),
              ),
            );
          });
        }
      });
    }

    ref.watch(checkServiceProvider.notifier).listenServiceChange();
    ref.watch(checkPermissionProvider.notifier).listenPermissionChange();

    service.whenData((service) {
      serviceState.value = service;
    });

    permission.whenData((permission) {
      permissionState.value = permission;
    });

    useEffect(() {
      return null;
    }, []);

    void Function()? onEnableService() {
      if (serviceState.value == false) {
        ref.read(requestPermissionProvider.notifier).reqEnableService();
        // service = ref.refresh(isServiceEnabledProvider);
      }
      return null;
    }

    void Function()? onEnablePermission() {
      if (permissionState.value == false) {
        ref.read(requestPermissionProvider.notifier).reqAccessLocation();
        //permission = ref.refresh(permissionGrantedProvider);
      }
      return null;
    }

    Future<void Function()?> getCurrentLocation() async {
      ref.read(getLocationLoading.notifier).update((isLoading) => true);

      double zoom = await controller.getZoomLevel();
      final location = await ref.read(myLocationProvider.future);

      if (location != null) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(location.latitude!, location.longitude!),
                zoom: zoom),
          ),
        );
      }

      ref.read(getLocationLoading.notifier).update((isLoading) => false);
      return null;
    }

    return InkWell(
      onDoubleTap: () {
        following.value = !following.value;
        if (following.value) {
          //ref.read(myLocationProvider)
        }
      },
      child: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          onPressed: serviceState.value == false
              ? onEnableService
              : permissionState.value == false
                  ? onEnablePermission
                  : getCurrentLocation,
          child: isLoading.value == true
              ? const CircularProgressIndicator()
              : serviceState.value == false
                  ? const Icon(Icons.location_off)
                  : permissionState.value == false
                      ? const Icon(Icons.gps_not_fixed)
                      : following.value == true
                          ? const Icon(Icons.my_location, color: Colors.blue)
                          : const Icon(Icons.gps_fixed)),
    );
  }
}

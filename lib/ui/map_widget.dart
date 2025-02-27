import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:survey_app/data/street_spatialite.dart';
import 'package:survey_app/provider/clustered_marker_provider.dart';
import 'package:survey_app/provider/hive_street_provider.dart';
import 'package:survey_app/provider/loading_state.dart';
import 'package:survey_app/provider/my_location_provider.dart';
import 'package:survey_app/provider/street_provider.dart';
import 'package:survey_app/ui/components/street_info.dart';
import 'package:survey_app/utils/app_logger.dart';
import '../model/route_issue.dart';
import '../provider/compute_data_provider.dart';
import 'components/custom_text_box.dart';

final mapControllerProvider =
    StateProvider<GoogleMapController?>((ref) => null);

class MapView extends StatefulHookConsumerWidget {
  const MapView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;
  bool _mapCreated = false;
  double latitude = -0.7893;
  double longitude = 113.9213;
  Set<Polyline> _polylines = {};

  final Set<Polyline> _selectedPolyline = {};
  bool _myLocationEnabled = false;
  Timer? timer;
  double _currentZoom = 15;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    timer = Timer.periodic(
        const Duration(seconds: 60), (Timer t) => checkForChanges());
  }

  @override
  dispose() {
    super.dispose();
    timer?.cancel();
  }

  Future<void> _checkAndSyncDatabase() async {
    final spatialiteDb = ref.read(streetDataProvider);
    var dataExist = await spatialiteDb.checkDataExist();
    if (!dataExist) {
      MyLogger("Table empty").i("Loading data from server...");
      await ref.read(loadAllStreetProvider.future);
    }
  }

  checkForChanges() async {
    final deletedRouteIssueId = ref.read(deletedRouteIssueProvider);
    MyLogger("Changes Recorded for undeleted Route Issue")
        .i(deletedRouteIssueId.length.toString());
    if (deletedRouteIssueId.isNotEmpty) {
      for (var id in deletedRouteIssueId) {
        final deleteProvider = await ref.read(deleteIssueProvider(id).future);
        if (deleteProvider) {
          ref.read(deletedRouteIssueProvider.notifier).removeDeletedId(id);
        }
      }
    }

    final listRouteIssue = ref.read(hiveRouteIssueProvider);
    MyLogger("Changes Recorded for Route Issue")
        .i(listRouteIssue.length.toString());
    if (listRouteIssue.isNotEmpty) {
      final provider =
          await ref.read(updateIssueProvider(listRouteIssue).future);
      if (provider) {
        MyLogger("Update issue").i("Success");
        for (var issue in listRouteIssue) {
          ref.read(hiveRouteIssueProvider.notifier).removeRouteIssue(issue);
        }
      } else {
        MyLogger("Upload route issue failed").e("data not uploaded");
      }
    }

    final data = ref.read(hiveStreetProvider);
    MyLogger("Changes Recorded for Street").i(data.length.toString());

    if (data.isNotEmpty) {
      final providerResult = await ref.read(updateDataProvider(data).future);

      if (providerResult) {
        for (var street in data) {
          ref.read(hiveStreetProvider.notifier).removeStreet(street);
        }
      } else {
        MyLogger("Upload street failed").e("data not uploaded");
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    setState(() {
      _mapCreated = true;
    });
    _currentZoom = await controller.getZoomLevel();
    ref
        .read(clusteredMarkerProvider.notifier)
        .updateClustersMarker(_currentZoom);
    ref.read(mapControllerProvider.notifier).update((state) => controller);
  }

  Set<Polyline> _getCombinedPolylines() {
    return {..._polylines, ..._selectedPolyline};
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loadingStateProvider);
    final selectedStreet = ref.watch(focusedStreetProvider);
    var permission = ref.watch(checkPermissionProvider);
    // final inMemoryStreet = ref.watch(inMemoryStreetProvider);
    final markerData = ref.watch(markerDataProvider);
    bool dialogOpen = ref.watch(drawStreetProvider.notifier).isDialogOpen;
    final clusteredMarker = ref.watch(clusteredMarkerProvider);

    // final loadPolyline = ref.watch(drawStreetProvider);
/*     useEffect(() {
      loadPolyline.whenData((street) {
        setState(() {
          _polylines = street;
        });
      });

      return null;
    }, [loadPolyline]); */

    useEffect(() {
      _checkAndSyncDatabase().then((v) async {
        await ref.read(loadedStreetDataProvider.future);
      });
      return null;
    }, []);

    useEffect(() {
      permission.whenData((granted) {
        if (granted) {
          setState(() {
            _myLocationEnabled = true;
          });
        }
      });
      return null;
    }, [permission]);

    ref.listen(drawStreetProvider.future, (_, next) async {
      final data = await next;

      setState(() {
        _polylines = data.polylines;
      });
      clusteredMarker.updateClusters(zoomLevel: _currentZoom);
    });

    void showSyncDialog() {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Sync Data"),
              content: const Text("Are you sure you want to sync data?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  child: const Text("Sync"),
                  onPressed: () {
                    ref.read(loadAllStreetProvider);
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }

    void Function(LatLng)? onLongPress(LatLng arg) {
      MyLogger("Map long press").d(arg.toString());
      ref.read(drawStreetProvider.notifier).getBlockPoint(arg);

      return null;
    }

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      /*   drawer: Drawer(
          child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            title: const Text('Sync Data'),
            onTap: () {
              showSyncDialog();
            },
          ),
        ],
      )), */
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            polylines: _getCombinedPolylines(),
            markers: {
              ...clusteredMarker.getClusteredMarkers(),
              ...markerData.map((e) => e.marker),
              ...markerData.map((e) => e.txtMarker != null
                  ? e.txtMarker!
                  : const Marker(markerId: MarkerId("empty")))
            },
            onMapCreated: _onMapCreated,
            onCameraMove: (position) {
              setState(() {
                _currentZoom = position.zoom;
              });
              clusteredMarker.updateClusters(zoomLevel: _currentZoom);
            },
            zoomControlsEnabled: false,
            initialCameraPosition:
                CameraPosition(target: LatLng(latitude, longitude), zoom: 2),
            myLocationEnabled: _myLocationEnabled,
            myLocationButtonEnabled: false,
            onTap: (arg) async {
              /*  ref.read(focusedStreetProvider.notifier).clear();
                await panelCtrl.close(); */
              // ref.read(drawStreetProvider.notifier).tapPoint(arg);
              //log(arg.toString(), name: "Tapped");
              ref
                  .read(tapPointProvider.notifier)
                  .update((state) => state = null);
            },
            onLongPress: onLongPress,
          ),
          if (_mapCreated) ...[
            Positioned(
              right: 15,
              top: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      FloatingActionButton.small(
                        child: const Icon(Icons.refresh),
                        onPressed: () {
                          ref.invalidate(inMemoryStreetProvider);
                          /* ref
                              .read(drawStreetProvider.notifier)
                              .loadStreetData(); */
                        },
                      ),
                      const SizedBox(width: 5),
                      FloatingActionButton.small(
                        child: const Icon(Icons.sync),
                        onPressed: () {
                          final hiveStreet = ref.read(hiveStreetProvider);
                          if (hiveStreet.isNotEmpty) {
                            showSyncDialog();
                          } else {
                            ref.read(loadAllStreetProvider);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 15,
              bottom: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
            Visibility(
              visible: selectedStreet != null && dialogOpen == false,
              child: Positioned(
                bottom: 125,
                left: 15,
                right: 15,
                child: Opacity(
                    opacity: 0.8,
                    child: StreetInfo(selectedStreet: selectedStreet)),
              ),
            ),
          ],
          state.isLoading
              ? Positioned(
                  left: 15,
                  top: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: CustomTextBox(
                        text: state.infoText,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          /*  loadDataNotifier.isLoading
                ? Positioned(
                    left: 15,
                    top: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: CustomBox(
                          widget: Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Theme.of(context).highlightColor),
                            ),
                          ),
                          text: "Loading street data...",
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(), */
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

    Future<void Function()?> getCurrentLocation() async {
      ref
          .read(loadingStateProvider.notifier)
          .setLoading(isLoading: true, infoText: "Finding your location...");

      // double zoom = await controller.getZoomLevel();
      final location = await ref.read(myLocationProvider.future);

      if (location != null) {
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(location.latitude!, location.longitude!),
                zoom: 16.0),
          ),
        );
        ref.read(processedStreetDataProvider.notifier).reloadProcessLocation();
      }

      ref.read(loadingStateProvider.notifier).dismiss();
      return null;
    }

    if (following.value) {
      ref.watch(myLocationProvider.notifier).watchLocation();
      ref.listen(myLocationProvider, (_, next) {
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

    Future<void Function()?> onEnablePermission() async {
      if (permissionState.value == false) {
        ref
            .read(requestPermissionProvider.notifier)
            .reqAccessLocation()
            .then((val) async {
          if (val) {
            await getCurrentLocation();
            ref.invalidate(drawStreetProvider);
          }
        });
      }
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

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:markers_cluster_google_maps_flutter/markers_cluster_google_maps_flutter.dart';
import 'package:survey_app/provider/street_provider.dart';
import 'package:survey_app/ui/map_widget.dart';

part 'clustered_marker_provider.g.dart';

@riverpod
class ClusteredMarker extends _$ClusteredMarker {
  @override
  MarkersClusterManager build() {
    final mapController = ref.watch(mapControllerProvider);
    final mapData = ref.watch(drawStreetProvider.future);
    final clusterManager = MarkersClusterManager(
      clusterColor: Colors.red,
      clusterBorderColor: Colors.white,
    );

    mapData.asStream().listen((value) {
      for (var marker in value.markers) {
        clusterManager.addMarker(marker);
      }
      if (mapController != null) {
        mapController
            .getZoomLevel()
            .then((val) => clusterManager.updateClusters(zoomLevel: val));
      }
    });
    return clusterManager;
  }

  void updateClustersMarker(double zoomLevel) async {
    await state.updateClusters(zoomLevel: zoomLevel);
  }
}

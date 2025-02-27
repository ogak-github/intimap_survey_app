import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:markers_cluster_google_maps_flutter/markers_cluster_google_maps_flutter.dart';
import 'package:survey_app/provider/street_provider.dart';

part 'clustered_marker_provider.g.dart';

@riverpod
class ClusteredMarker extends _$ClusteredMarker {
  @override
  MarkersClusterManager build() {
    final mapData = ref.watch(drawStreetProvider.future);
    final clusterManager = MarkersClusterManager(
      clusterColor: Colors.red,
      clusterBorderColor: Colors.white,
    );
    mapData.asStream().listen((data) {
      for (var marker in data.markers) {
        clusterManager.addMarker(marker);
      }
    });

    return clusterManager;
  }

  void updateClustersMarker(double zoomLevel) {
    state.updateClusters(zoomLevel: zoomLevel);
  }

  /*  void addMarker(Set<Marker> markers) {
    for (var e in markers) {
      state.addMarker(e);
    }
  } */
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:survey_app/model/street.dart';

part 'routing_data.freezed.dart';
part 'routing_data.g.dart';

enum RouteMatchType {
  forward,
  backward,
  prevSegment,
  nextSegment,
  jumpSegment,
  outOfRoute,
}

@freezed
class RoutingPoint with _$RoutingPoint {
  const RoutingPoint._();
  factory RoutingPoint({
    required int id,
    required double distanceToRoute,
    required String queryId,
    required String originalPoint,
    required String fixedPoint,
    required String nextPoint,
    required double pointPosition,
    required double routeLength,
    required double distanceLeft,
    required double? lineHeading,
  }) = _RoutingPoint;

  factory RoutingPoint.fromJson(Map<String, dynamic> json) =>
      _$RoutingPointFromJson(json);

  LatLng get latLng {
    final coords = fixedPoint.split('(')[1].split(')')[0].split(' ');
    return LatLng(double.parse(coords[1]), double.parse(coords[0]));
  }
}

@freezed
class RoutingPoint2 with _$RoutingPoint2 {
  const RoutingPoint2._();
  const factory RoutingPoint2({
    required int id,
    required double distanceToRoute,
    required String queryId,
    required String originalPoint,
    required String fixedPoint,
    required String nextPoint,
    required double pointPosition,
    required double routeLength,
    required double distanceLeft,
    required double? lineHeading,
    Street? street,
  }) = _RoutingPoint2;

  factory RoutingPoint2.fromJson(Map<String, dynamic> json) =>
      _$RoutingPoint2FromJson(json);

  LatLng get latLng {
    final coords = fixedPoint.split('(')[1].split(')')[0].split(' ');
    return LatLng(double.parse(coords[1]), double.parse(coords[0]));
  }
}

@freezed
class SelectedRouteInfo with _$SelectedRouteInfo {
  const factory SelectedRouteInfo({
    required RoutingPoint? point,
    required RoutingPoint lastOkPoint,
    required RouteMatchType? matchType,
    required DateTime firstMatchTime,
  }) = _SelectedRouteInfo;

  factory SelectedRouteInfo.fromJson(Map<String, dynamic> json) =>
      _$SelectedRouteInfoFromJson(json);
}

@freezed
class SelectedRouteInfo2 with _$SelectedRouteInfo2 {
  const factory SelectedRouteInfo2({
    required RoutingPoint2? point,
    required RoutingPoint2 lastOkPoint,
    required RouteMatchType? matchType,
    required DateTime firstMatchTime,
  }) = _SelectedRouteInfo2;

  factory SelectedRouteInfo2.fromJson(Map<String, dynamic> json) =>
      _$SelectedRouteInfo2FromJson(json);
}

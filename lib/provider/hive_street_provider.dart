import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:survey_app/utils/app_logger.dart';

import '../model/route_issue.dart';
import '../model/street.dart';
import '../model/user_state.dart';

part 'hive_street_provider.g.dart';

@riverpod
class HiveStreet extends _$HiveStreet {
  @override
  List<Street> build() {
    final Box<Street> streetBox = Hive.box<Street>('streets');
    List<Street> streets = streetBox.values.toList();
    return streets;
  }

  Future<void> addStreet(Street street) async {
    MyLogger("Hive Add Street").d(street.toString());
    final streetBox = Hive.box<Street>('streets');
    streetBox.put(street.id, street);
    ref.invalidateSelf();
  }

  Future<void> removeStreet(Street street) async {
    final streetBox = Hive.box<Street>('streets');
    streetBox.delete(street.id);
    ref.invalidateSelf();
  }
}

@riverpod
class HiveRouteIssue extends _$HiveRouteIssue {
  @override
  List<RouteIssue> build() {
    final Box<RouteIssue> routeIssueBox = Hive.box<RouteIssue>('route_issues');
    List<RouteIssue> routeIssues = routeIssueBox.values.toList();
    return routeIssues;
  }

  Future<void> addRouteIssue(RouteIssueData routeIssue) async {
    final issue = RouteIssue(
      id: routeIssue.id,
      streetId: routeIssue.streetId,
      blocked: routeIssue.blocked,
      notes: routeIssue.notes,
      geom: routeIssue.geom,
    );
    final routeIssueBox = Hive.box<RouteIssue>('route_issues');
    routeIssueBox.put(routeIssue.id, issue);
    ref.invalidateSelf();
  }

  Future<void> addAll(List<RouteIssue> routeIssues) async {
    final routeIssueBox = Hive.box<RouteIssue>('route_issues');
    routeIssueBox.addAll(routeIssues);
    ref.invalidateSelf();
  }

  Future<void> removeRouteIssue(RouteIssue routeIssue) async {
    final routeIssueBox = Hive.box<RouteIssue>('route_issues');
    routeIssueBox.delete(routeIssue.id);
    ref.invalidateSelf();
  }
}

@riverpod
class DeletedRouteIssue extends _$DeletedRouteIssue {
  @override
  List<String> build() {
    final Box<String> issueIdBox = Hive.box<String>('deleted_issue_id');
    List<String> idBox = issueIdBox.values.toList();
    return idBox;
  }

  Future<void> addDeletedId(String id) async {
    final routeIssueBox = Hive.box<String>('deleted_issue_id');
    routeIssueBox.put(id, id);
    ref.invalidateSelf();
  }

  Future<void> removeDeletedId(String id) async {
    final routeIssueBox = Hive.box<String>('deleted_issue_id');
    routeIssueBox.delete(id);
    ref.invalidateSelf();
  }
}

@riverpod
class CurrentMapState extends _$CurrentMapState {
  @override
  MapState? build() {
    final Box<MapState> mapStateBox = Hive.box<MapState>('map_state');
    var mapState = mapStateBox.get('map_state');
    return mapState;
  }

  Future<void> updateMapState(MapState mapState) async {
    final mapStateBox = Hive.box<MapState>('map_state');
    mapStateBox.put('map_state', mapState);
    ref.invalidateSelf();
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'user_state.freezed.dart';
part 'user_state.g.dart';

@freezed
class MapState with _$MapState {
  @HiveType(typeId: 4, adapterName: "MapStateAdapter")
  const factory MapState({
    @HiveField(0, defaultValue: -0.7893) @Default(-0.7893) double latitude,
    @HiveField(1, defaultValue: 113.9213) @Default(113.9213) double longitude,
    @HiveField(2, defaultValue: 2) @Default(2) double zoom,
  }) = _MapState;
  factory MapState.fromJson(Map<String, dynamic> json) =>
      _$MapStateFromJson(json);
}

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'street.freezed.dart';
part 'street.g.dart';

@Freezed()
class Street with _$Street {
  const factory Street({
    required int id,
    @JsonKey(name: 'osm_id') required String osmId,
    String? name,
    int? truk,
    int? pickup,
    int? roda3,
    String? meta,
    @JsonKey(name: 'last_modified_time') required DateTime lastModifiedTime,
    required String geom,
  }) = _Street;

  factory Street.fromJson(Map<String, Object?> json) => _$StreetFromJson(json);
}

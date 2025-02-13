// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'street.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StreetImpl _$$StreetImplFromJson(Map<String, dynamic> json) => _$StreetImpl(
      id: (json['id'] as num).toInt(),
      osmId: json['osm_id'] as String,
      name: json['name'] as String?,
      truk: (json['truk'] as num?)?.toInt(),
      pickup: (json['pickup'] as num?)?.toInt(),
      roda3: (json['roda3'] as num?)?.toInt(),
      meta: json['meta'] as String?,
      lastModifiedTime: DateTime.parse(json['last_modified_time'] as String),
      geom: json['geom'] as String,
    );

Map<String, dynamic> _$$StreetImplToJson(_$StreetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'osm_id': instance.osmId,
      'name': instance.name,
      'truk': instance.truk,
      'pickup': instance.pickup,
      'roda3': instance.roda3,
      'meta': instance.meta,
      'last_modified_time': instance.lastModifiedTime.toIso8601String(),
      'geom': instance.geom,
    };

_$MetadataImpl _$$MetadataImplFromJson(Map<String, dynamic> json) =>
    _$MetadataImpl(
      notes: json['notes'] as String?,
      updated: json['updated'] as bool?,
    );

Map<String, dynamic> _$$MetadataImplToJson(_$MetadataImpl instance) =>
    <String, dynamic>{
      'notes': instance.notes,
      'updated': instance.updated,
    };

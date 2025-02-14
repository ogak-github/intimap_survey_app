// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'street.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StreetAdapter extends TypeAdapter<_$StreetImpl> {
  @override
  final int typeId = 1;

  @override
  _$StreetImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$StreetImpl(
      id: fields[0] as int,
      osmId: fields[1] as String,
      name: fields[2] as String?,
      truk: fields[3] as int?,
      pickup: fields[4] as int?,
      roda3: fields[5] as int?,
      meta: fields[6] as String?,
      lastModifiedTime: fields[7] as DateTime,
      geom: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, _$StreetImpl obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.osmId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.truk)
      ..writeByte(4)
      ..write(obj.pickup)
      ..writeByte(5)
      ..write(obj.roda3)
      ..writeByte(6)
      ..write(obj.meta)
      ..writeByte(7)
      ..write(obj.lastModifiedTime)
      ..writeByte(8)
      ..write(obj.geom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_street.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModelStreetImpl _$$ModelStreetImplFromJson(Map<String, dynamic> json) =>
    _$ModelStreetImpl(
      pages: (json['pages'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => Street.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ModelStreetImplToJson(_$ModelStreetImpl instance) =>
    <String, dynamic>{
      'pages': instance.pages,
      'currentPage': instance.currentPage,
      'data': instance.data,
    };

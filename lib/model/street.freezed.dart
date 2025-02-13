// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'street.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Street _$StreetFromJson(Map<String, dynamic> json) {
  return _Street.fromJson(json);
}

/// @nodoc
mixin _$Street {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'osm_id')
  String get osmId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  int? get truk => throw _privateConstructorUsedError;
  int? get pickup => throw _privateConstructorUsedError;
  int? get roda3 => throw _privateConstructorUsedError;
  String? get meta => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_modified_time')
  DateTime get lastModifiedTime => throw _privateConstructorUsedError;
  String get geom => throw _privateConstructorUsedError;

  /// Serializes this Street to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Street
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreetCopyWith<Street> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreetCopyWith<$Res> {
  factory $StreetCopyWith(Street value, $Res Function(Street) then) =
      _$StreetCopyWithImpl<$Res, Street>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'osm_id') String osmId,
      String? name,
      int? truk,
      int? pickup,
      int? roda3,
      String? meta,
      @JsonKey(name: 'last_modified_time') DateTime lastModifiedTime,
      String geom});
}

/// @nodoc
class _$StreetCopyWithImpl<$Res, $Val extends Street>
    implements $StreetCopyWith<$Res> {
  _$StreetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Street
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? osmId = null,
    Object? name = freezed,
    Object? truk = freezed,
    Object? pickup = freezed,
    Object? roda3 = freezed,
    Object? meta = freezed,
    Object? lastModifiedTime = null,
    Object? geom = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      osmId: null == osmId
          ? _value.osmId
          : osmId // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      truk: freezed == truk
          ? _value.truk
          : truk // ignore: cast_nullable_to_non_nullable
              as int?,
      pickup: freezed == pickup
          ? _value.pickup
          : pickup // ignore: cast_nullable_to_non_nullable
              as int?,
      roda3: freezed == roda3
          ? _value.roda3
          : roda3 // ignore: cast_nullable_to_non_nullable
              as int?,
      meta: freezed == meta
          ? _value.meta
          : meta // ignore: cast_nullable_to_non_nullable
              as String?,
      lastModifiedTime: null == lastModifiedTime
          ? _value.lastModifiedTime
          : lastModifiedTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      geom: null == geom
          ? _value.geom
          : geom // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreetImplCopyWith<$Res> implements $StreetCopyWith<$Res> {
  factory _$$StreetImplCopyWith(
          _$StreetImpl value, $Res Function(_$StreetImpl) then) =
      __$$StreetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'osm_id') String osmId,
      String? name,
      int? truk,
      int? pickup,
      int? roda3,
      String? meta,
      @JsonKey(name: 'last_modified_time') DateTime lastModifiedTime,
      String geom});
}

/// @nodoc
class __$$StreetImplCopyWithImpl<$Res>
    extends _$StreetCopyWithImpl<$Res, _$StreetImpl>
    implements _$$StreetImplCopyWith<$Res> {
  __$$StreetImplCopyWithImpl(
      _$StreetImpl _value, $Res Function(_$StreetImpl) _then)
      : super(_value, _then);

  /// Create a copy of Street
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? osmId = null,
    Object? name = freezed,
    Object? truk = freezed,
    Object? pickup = freezed,
    Object? roda3 = freezed,
    Object? meta = freezed,
    Object? lastModifiedTime = null,
    Object? geom = null,
  }) {
    return _then(_$StreetImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      osmId: null == osmId
          ? _value.osmId
          : osmId // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      truk: freezed == truk
          ? _value.truk
          : truk // ignore: cast_nullable_to_non_nullable
              as int?,
      pickup: freezed == pickup
          ? _value.pickup
          : pickup // ignore: cast_nullable_to_non_nullable
              as int?,
      roda3: freezed == roda3
          ? _value.roda3
          : roda3 // ignore: cast_nullable_to_non_nullable
              as int?,
      meta: freezed == meta
          ? _value.meta
          : meta // ignore: cast_nullable_to_non_nullable
              as String?,
      lastModifiedTime: null == lastModifiedTime
          ? _value.lastModifiedTime
          : lastModifiedTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      geom: null == geom
          ? _value.geom
          : geom // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreetImpl extends _Street with DiagnosticableTreeMixin {
  const _$StreetImpl(
      {required this.id,
      @JsonKey(name: 'osm_id') required this.osmId,
      this.name,
      this.truk,
      this.pickup,
      this.roda3,
      this.meta,
      @JsonKey(name: 'last_modified_time') required this.lastModifiedTime,
      required this.geom})
      : super._();

  factory _$StreetImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreetImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'osm_id')
  final String osmId;
  @override
  final String? name;
  @override
  final int? truk;
  @override
  final int? pickup;
  @override
  final int? roda3;
  @override
  final String? meta;
  @override
  @JsonKey(name: 'last_modified_time')
  final DateTime lastModifiedTime;
  @override
  final String geom;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Street(id: $id, osmId: $osmId, name: $name, truk: $truk, pickup: $pickup, roda3: $roda3, meta: $meta, lastModifiedTime: $lastModifiedTime, geom: $geom)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Street'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('osmId', osmId))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('truk', truk))
      ..add(DiagnosticsProperty('pickup', pickup))
      ..add(DiagnosticsProperty('roda3', roda3))
      ..add(DiagnosticsProperty('meta', meta))
      ..add(DiagnosticsProperty('lastModifiedTime', lastModifiedTime))
      ..add(DiagnosticsProperty('geom', geom));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.osmId, osmId) || other.osmId == osmId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.truk, truk) || other.truk == truk) &&
            (identical(other.pickup, pickup) || other.pickup == pickup) &&
            (identical(other.roda3, roda3) || other.roda3 == roda3) &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.lastModifiedTime, lastModifiedTime) ||
                other.lastModifiedTime == lastModifiedTime) &&
            (identical(other.geom, geom) || other.geom == geom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, osmId, name, truk, pickup,
      roda3, meta, lastModifiedTime, geom);

  /// Create a copy of Street
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreetImplCopyWith<_$StreetImpl> get copyWith =>
      __$$StreetImplCopyWithImpl<_$StreetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreetImplToJson(
      this,
    );
  }
}

abstract class _Street extends Street {
  const factory _Street(
      {required final int id,
      @JsonKey(name: 'osm_id') required final String osmId,
      final String? name,
      final int? truk,
      final int? pickup,
      final int? roda3,
      final String? meta,
      @JsonKey(name: 'last_modified_time')
      required final DateTime lastModifiedTime,
      required final String geom}) = _$StreetImpl;
  const _Street._() : super._();

  factory _Street.fromJson(Map<String, dynamic> json) = _$StreetImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'osm_id')
  String get osmId;
  @override
  String? get name;
  @override
  int? get truk;
  @override
  int? get pickup;
  @override
  int? get roda3;
  @override
  String? get meta;
  @override
  @JsonKey(name: 'last_modified_time')
  DateTime get lastModifiedTime;
  @override
  String get geom;

  /// Create a copy of Street
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreetImplCopyWith<_$StreetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Metadata _$MetadataFromJson(Map<String, dynamic> json) {
  return _Metadata.fromJson(json);
}

/// @nodoc
mixin _$Metadata {
  String? get notes => throw _privateConstructorUsedError;
  bool? get updated => throw _privateConstructorUsedError;

  /// Serializes this Metadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MetadataCopyWith<Metadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MetadataCopyWith<$Res> {
  factory $MetadataCopyWith(Metadata value, $Res Function(Metadata) then) =
      _$MetadataCopyWithImpl<$Res, Metadata>;
  @useResult
  $Res call({String? notes, bool? updated});
}

/// @nodoc
class _$MetadataCopyWithImpl<$Res, $Val extends Metadata>
    implements $MetadataCopyWith<$Res> {
  _$MetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notes = freezed,
    Object? updated = freezed,
  }) {
    return _then(_value.copyWith(
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      updated: freezed == updated
          ? _value.updated
          : updated // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MetadataImplCopyWith<$Res>
    implements $MetadataCopyWith<$Res> {
  factory _$$MetadataImplCopyWith(
          _$MetadataImpl value, $Res Function(_$MetadataImpl) then) =
      __$$MetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? notes, bool? updated});
}

/// @nodoc
class __$$MetadataImplCopyWithImpl<$Res>
    extends _$MetadataCopyWithImpl<$Res, _$MetadataImpl>
    implements _$$MetadataImplCopyWith<$Res> {
  __$$MetadataImplCopyWithImpl(
      _$MetadataImpl _value, $Res Function(_$MetadataImpl) _then)
      : super(_value, _then);

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notes = freezed,
    Object? updated = freezed,
  }) {
    return _then(_$MetadataImpl(
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      updated: freezed == updated
          ? _value.updated
          : updated // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MetadataImpl with DiagnosticableTreeMixin implements _Metadata {
  const _$MetadataImpl({this.notes, this.updated});

  factory _$MetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MetadataImplFromJson(json);

  @override
  final String? notes;
  @override
  final bool? updated;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Metadata(notes: $notes, updated: $updated)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Metadata'))
      ..add(DiagnosticsProperty('notes', notes))
      ..add(DiagnosticsProperty('updated', updated));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MetadataImpl &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.updated, updated) || other.updated == updated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, notes, updated);

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MetadataImplCopyWith<_$MetadataImpl> get copyWith =>
      __$$MetadataImplCopyWithImpl<_$MetadataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MetadataImplToJson(
      this,
    );
  }
}

abstract class _Metadata implements Metadata {
  const factory _Metadata({final String? notes, final bool? updated}) =
      _$MetadataImpl;

  factory _Metadata.fromJson(Map<String, dynamic> json) =
      _$MetadataImpl.fromJson;

  @override
  String? get notes;
  @override
  bool? get updated;

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MetadataImplCopyWith<_$MetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

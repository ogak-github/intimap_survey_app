// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_street.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ModelStreet _$ModelStreetFromJson(Map<String, dynamic> json) {
  return _ModelStreet.fromJson(json);
}

/// @nodoc
mixin _$ModelStreet {
  int get pages => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  List<Street> get data => throw _privateConstructorUsedError;

  /// Serializes this ModelStreet to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModelStreet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModelStreetCopyWith<ModelStreet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelStreetCopyWith<$Res> {
  factory $ModelStreetCopyWith(
          ModelStreet value, $Res Function(ModelStreet) then) =
      _$ModelStreetCopyWithImpl<$Res, ModelStreet>;
  @useResult
  $Res call({int pages, int currentPage, List<Street> data});
}

/// @nodoc
class _$ModelStreetCopyWithImpl<$Res, $Val extends ModelStreet>
    implements $ModelStreetCopyWith<$Res> {
  _$ModelStreetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModelStreet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pages = null,
    Object? currentPage = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      pages: null == pages
          ? _value.pages
          : pages // ignore: cast_nullable_to_non_nullable
              as int,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<Street>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModelStreetImplCopyWith<$Res>
    implements $ModelStreetCopyWith<$Res> {
  factory _$$ModelStreetImplCopyWith(
          _$ModelStreetImpl value, $Res Function(_$ModelStreetImpl) then) =
      __$$ModelStreetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int pages, int currentPage, List<Street> data});
}

/// @nodoc
class __$$ModelStreetImplCopyWithImpl<$Res>
    extends _$ModelStreetCopyWithImpl<$Res, _$ModelStreetImpl>
    implements _$$ModelStreetImplCopyWith<$Res> {
  __$$ModelStreetImplCopyWithImpl(
      _$ModelStreetImpl _value, $Res Function(_$ModelStreetImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModelStreet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pages = null,
    Object? currentPage = null,
    Object? data = null,
  }) {
    return _then(_$ModelStreetImpl(
      pages: null == pages
          ? _value.pages
          : pages // ignore: cast_nullable_to_non_nullable
              as int,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<Street>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModelStreetImpl implements _ModelStreet {
  _$ModelStreetImpl(
      {required this.pages,
      required this.currentPage,
      required final List<Street> data})
      : _data = data;

  factory _$ModelStreetImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModelStreetImplFromJson(json);

  @override
  final int pages;
  @override
  final int currentPage;
  final List<Street> _data;
  @override
  List<Street> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'ModelStreet(pages: $pages, currentPage: $currentPage, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelStreetImpl &&
            (identical(other.pages, pages) || other.pages == pages) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, pages, currentPage,
      const DeepCollectionEquality().hash(_data));

  /// Create a copy of ModelStreet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelStreetImplCopyWith<_$ModelStreetImpl> get copyWith =>
      __$$ModelStreetImplCopyWithImpl<_$ModelStreetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModelStreetImplToJson(
      this,
    );
  }
}

abstract class _ModelStreet implements ModelStreet {
  factory _ModelStreet(
      {required final int pages,
      required final int currentPage,
      required final List<Street> data}) = _$ModelStreetImpl;

  factory _ModelStreet.fromJson(Map<String, dynamic> json) =
      _$ModelStreetImpl.fromJson;

  @override
  int get pages;
  @override
  int get currentPage;
  @override
  List<Street> get data;

  /// Create a copy of ModelStreet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModelStreetImplCopyWith<_$ModelStreetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

import 'package:freezed_annotation/freezed_annotation.dart';

import 'street.dart';

part 'model_street.freezed.dart';
part 'model_street.g.dart';

@Freezed()
class ModelStreet with _$ModelStreet {
  factory ModelStreet({
    required int pages,
    required int currentPage,
    required List<Street> data,
  }) = _ModelStreet;

  factory ModelStreet.fromJson(Map<String, dynamic> json) =>
      _$ModelStreetFromJson(json);
}

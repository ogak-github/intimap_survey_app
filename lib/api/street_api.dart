import 'dart:developer';
import 'dart:isolate';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:survey_app/api/dio_client.dart';

import '../model/street.dart';

class StreetAPI {
  final DioClient _dioClient;
  StreetAPI(this._dioClient);

  Future<List<Street>> getStreet({int page = 1}) async {
    try {
      final response = await _dioClient.get(
        '/street',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        List<Street> streets =
            response.data.map((e) => Street.fromJson(e)).toList();

        return streets;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Street>> loadAll() async {
    List<Street> streets = [];
    try {
      final response = await _dioClient.get(
        '/loadstreets',
      );
      var isolatedStreets = await Isolate.run<List<Street>>(() async {
        for (var item in response.data) {
          Map<String, dynamic> map = item;
          Street s = Street.fromJson(map);
          streets.add(s);
        }

        return streets;
      });

      return isolatedStreets;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

final streetAPIProvider = Provider<StreetAPI>((ref) {
  const String baseUrl = 'https://786a-112-78-165-162.ngrok-free.app/api';
  return StreetAPI(DioClient(baseUrl));
});

import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:survey_app/api/dio_client.dart';
import 'package:survey_app/model/route_issue.dart';
import 'package:survey_app/utils/app_logger.dart';

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
      if (response.statusCode != 200) {
        return [];
      }
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

  Future<bool> updateBulk(List<Street> newStreets) async {
    try {
      final jsonData = newStreets.map((e) => jsonEncode(e)).toList();
      final response = await _dioClient.put(
        '/bulk-update',
        data: jsonData.toString(),
      );
      MyLogger("Status code").i("${response.statusCode}");
      if (response.statusCode != 200) {
        return false;
      }

      MyLogger("Update bulk status Code: ${response.statusCode}")
          .i(response.data.toString());

      return true;
    } catch (e) {
      MyLogger("API Error").e(e.toString());
      return false;
    }
  }

  Future<bool> updateBulkRouteIssue(List<RouteIssue> routeIssues) async {
    try {
      final jsonData = routeIssues.map((e) => jsonEncode(e)).toList();
      final response = await _dioClient.post(
        '/add-route-issue',
        data: jsonData.toString(),
      );
      MyLogger("Upload route issue status code").i("${response.statusCode}");
      if (response.statusCode != 200) {
        return false;
      }
      return true;
    } catch (e) {
      MyLogger("API Error").e(e.toString());
      return false;
    }
  }

  Future<List<RouteIssue>> getRouteIssues() async {
    List<RouteIssue> issues = [];
    try {
      final response = await _dioClient.get(
        '/load-route-issues',
      );
      if (response.statusCode == 200) {
        var isolated = await Isolate.run<List<RouteIssue>>(() async {
          for (var item in response.data) {
            Map<String, dynamic> map = item;
            RouteIssue s = RouteIssue.fromJson(map);
            log(s.toJson().toString(), name: "Route Issue API");
            issues.add(s);
          }

          return issues;
        });

        return isolated;
      }
      return issues;
    } catch (e) {
      MyLogger("API Error").e(e.toString());
      return issues;
    }
  }

  Future<bool> deleteRouteIssue(String id) async {
    try {
      final response = await _dioClient.delete(
        '/delete-route-issues/$id',
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      MyLogger("API Error").e(e.toString());
      return false;
    }
  }
}

final streetAPIProvider = Provider<StreetAPI>((ref) {
  final box = Hive.box('base_url');
  var currentUrl = 'https://7ae8-112-78-165-162.ngrok-free.app/api';
  var urlFromBox = box.get('base_url');
  if (urlFromBox != null) {
    currentUrl = urlFromBox;
  }

  return StreetAPI(DioClient(currentUrl));
  //return StreetAPI(DioClient('https://7ae8-112-78-165-162.ngrok-free.app/api'));
});


import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_state.g.dart';

@riverpod
class ServerState extends _$ServerState {
  @override
  FutureOr<String> build() async {
    final box = await Hive.openBox('base_url');
    String baseUrl = box.get('base_url');
    return baseUrl;
  }

  FutureOr<void> updateUrl(String url) async {
    final box = await Hive.openBox('base_url');
    box.put('base_url', url);
    state = AsyncValue.data(url);
  }
}

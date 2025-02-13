import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loading_state.g.dart';

class LoadingData {
  final bool isLoading;
  String infoText;

  LoadingData({required this.isLoading, this.infoText = "Loading..."});
}

@riverpod
class LoadingState extends _$LoadingState {
  @override
  LoadingData build() {
    return LoadingData(isLoading: false);
  }

  void setLoading({required bool isLoading, String infoText = "Loading..."}) {
    state = LoadingData(isLoading: isLoading, infoText: infoText);
  }

  void dismiss() {
    state = LoadingData(isLoading: false);
  }
}

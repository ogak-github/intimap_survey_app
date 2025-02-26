import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/street_spatialite.dart';
import '../model/street.dart';
import '../model/update_data.dart';
import 'hive_street_provider.dart';
import 'street_provider.dart';

part 'update_street_provider.g.dart';

@riverpod
class UpdateStreet extends _$UpdateStreet {
  @override
  Future<void> build(Street newData, UpdateData updatedData) async {
    EasyLoading.show(status: 'Updating data...');

    final spatial = ref.watch(streetDataProvider);
    final updateStatus = await spatial.updateStreet(updatedData, newData.id);
    if (!updateStatus) {
      EasyLoading.showError("Failed to update street data", dismissOnTap: true);
      return;
    }
    //ref.read(drawStreetProvider.notifier).updateStreetData(newData);
    ref.read(hiveStreetProvider.notifier).addStreet(newData);

    EasyLoading.dismiss();
  }
}

@riverpod
class UpdateStreet2 extends _$UpdateStreet2 {
  @override
  Future<void> build(UpdateStreetPerColumn street, int id) async {
    EasyLoading.show(status: 'Updating data...');
    final spatial = ref.watch(streetDataProvider);
    final updateStatus = await spatial.updateStreetPerColumn(street, id);
    if (!updateStatus) {
      EasyLoading.showError("Failed to update street data", dismissOnTap: true);
      return;
    }
    /*   ref.read(drawStreetProvider.notifier).updateStreetData(newData);
    ref.read(hiveStreetProvider.notifier).addStreet(newData); */
    EasyLoading.dismiss();
  }
}

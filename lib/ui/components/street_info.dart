import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:survey_app/data/street_spatialite.dart';
import 'package:survey_app/provider/compute_data_provider.dart';

import '../../model/street.dart';
import '../../model/update_data.dart';
import '../../provider/hive_street_provider.dart';
import '../../provider/street_provider.dart';
import '../../utils/date_formatter.dart';

class StreetInfo extends HookConsumerWidget {
  final Street? selectedStreet;
  const StreetInfo({super.key, required this.selectedStreet});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streetData = ref.watch(streetDataProvider);
    final selectedStreet = ref.watch(focusedStreetProvider);
    final truk = useState<int>(selectedStreet?.truk ?? 0);
    final pickup = useState<int>(selectedStreet?.pickup ?? 0);
    final roda3 = useState<int>(selectedStreet?.roda3 ?? 0);

    useEffect(() {
      //  dynamic selectedStreetMeta = selectedStreet?.meta;
      //  Map<String, dynamic> metadataMap;
      truk.value = selectedStreet?.truk ?? 0;
      pickup.value = selectedStreet?.pickup ?? 0;
      roda3.value = selectedStreet?.roda3 ?? 0;
      /*   if (selectedStreetMeta is String && selectedStreetMeta.isNotEmpty) {
        try {
          metadataMap = jsonDecode(selectedStreetMeta);
        } catch (e) {
          print("Error decoding JSON: $e");
          // Set default values or handle the error as appropriate
          roadCondition.value = false;
          notes.value = "-";
          return; // Exit if the JSON is invalid
        }
      } else if (selectedStreetMeta is Map<String, dynamic>) {
        metadataMap = selectedStreetMeta;
      } else {
        // Handle the case where selectedStreetMeta is neither a non-empty String nor a Map
        print("Invalid or missing metadata");
        roadCondition.value = false;
        notes.value = "-";
        return;
      }

// Proceed with using the decoded or directly assigned map
      var metadata = Metadata.fromJson(metadataMap);
      roadCondition.value = metadata.blocked ?? false;
      notes.value = metadata.notes ?? "-"; */
      return null;
    }, [selectedStreet]);

    void updateprocess(UpdateStreetPerColumn update, Street street) async {
      /// Save to hive
      Street newData = Street(
          id: street.id,
          osmId: street.osmId,
          name: street.name,
          truk: truk.value,
          pickup: pickup.value,
          roda3: roda3.value,
          lastModifiedTime: DateTime.now(),
          geom: street.geom);

      if (selectedStreet == null) return;
      EasyLoading.show(status: 'Updating data...');

      /// Directly update sqlite
      await streetData.updateStreetPerColumn(update, street.id);
      ref.read(hiveStreetProvider.notifier).addStreet(newData);

      EasyLoading.dismiss();
      ref.read(drawStreetProvider.notifier).reloadDrawStreet();
      ref.read(processedStreetDataProvider.notifier).reloadProcessLocation();
    }

    return selectedStreet != null
        ? Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Wrap(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("ID: ${selectedStreet.id}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      "Last update: ${humanizeDateWithoutSec(selectedStreet.lastModifiedTime)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const Divider(endIndent: 2, indent: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(
                        showCheckmark: roda3.value != 0,
                        label: vehicleType(VehicleType.roda3),
                        onSelected: (value) {
                          /*   value = !value; */
                          if (roda3.value == 1) {
                            roda3.value = 0;
                          } else {
                            roda3.value = 1;
                          }
                          var data = UpdateStreetPerColumn(
                              columnName: VehicleType.roda3.name,
                              value: roda3.value);
                          updateprocess(data, selectedStreet);
                        },
                        selected: true),
                    ChoiceChip(
                        showCheckmark: pickup.value != 0,
                        label: vehicleType(VehicleType.pickup),
                        onSelected: (value) {
                          if (pickup.value == 1) {
                            pickup.value = 0;
                          } else {
                            pickup.value = 1;
                          }
                          var data = UpdateStreetPerColumn(
                              columnName: VehicleType.pickup.name,
                              value: pickup.value);
                          updateprocess(data, selectedStreet);
                        },
                        selected: true),
                    ChoiceChip(
                        showCheckmark: truk.value != 0,
                        label: vehicleType(VehicleType.truk),
                        onSelected: (value) {
                          if (truk.value == 1) {
                            truk.value = 0;
                          } else {
                            truk.value = 1;
                          }

                          var data = UpdateStreetPerColumn(
                              columnName: VehicleType.truk.name,
                              value: truk.value);
                          updateprocess(data, selectedStreet);
                        },
                        selected: true),
                  ],
                ),
                const Divider(endIndent: 2, indent: 2),
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}

enum VehicleType { roda3, pickup, truk }

Widget vehicleType(VehicleType type) {
  switch (type) {
    case VehicleType.roda3:
      return const Icon(Icons.motorcycle);
    case VehicleType.pickup:
      return const Icon(Icons.directions_car);
    case VehicleType.truk:
      return const Icon(Icons.local_shipping);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:survey_app/model/street.dart';
import 'package:survey_app/model/update_data.dart';
import 'package:survey_app/provider/hive_street_provider.dart';
import 'package:survey_app/provider/street_provider.dart';
import 'package:survey_app/ui/map_widget.dart';
import 'package:survey_app/utils/app_logger.dart';
import 'package:survey_app/utils/date_formatter.dart';

import '../data/street_spatialite.dart';

class PanelBuilderWidget extends HookConsumerWidget {
  const PanelBuilderWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streetData = ref.watch(streetDataProvider);
    final selectedStreet = ref.watch(focusedStreetProvider);
    final truk = useState<int>(selectedStreet?.truk ?? 0);
    final pickup = useState<int>(selectedStreet?.pickup ?? 0);
    final roda3 = useState<int>(selectedStreet?.roda3 ?? 0);

    useEffect(() {
      truk.value = selectedStreet?.truk ?? 0;
      pickup.value = selectedStreet?.pickup ?? 0;
      roda3.value = selectedStreet?.roda3 ?? 0;
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
      ref.invalidate(drawStreetProvider);
    }

    return selectedStreet != null
        ? Container(
            padding: const EdgeInsets.all(1),
            child: Column(
              children: [
                Center(
                  child: SizedBox(
                    width: 20,
                    child: Divider(
                        thickness: 5, color: Theme.of(context).disabledColor),
                  ),
                ),
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
                        label: const Text("Roda 3"),
                        onSelected: (value) {
                          /*   value = !value; */
                          if (roda3.value == 1) {
                            roda3.value = 0;
                          } else {
                            roda3.value = 1;
                          }
                          var data = UpdateStreetPerColumn(
                              columnName: "roda3", value: roda3.value);
                          updateprocess(data, selectedStreet);
                        },
                        selected: true),
                    ChoiceChip(
                        showCheckmark: pickup.value != 0,
                        label: const Text("Pickup"),
                        onSelected: (value) {
                          if (pickup.value == 1) {
                            pickup.value = 0;
                          } else {
                            pickup.value = 1;
                          }
                          var data = UpdateStreetPerColumn(
                              columnName: "pickup", value: pickup.value);
                          updateprocess(data, selectedStreet);
                        },
                        selected: true),
                    ChoiceChip(
                        showCheckmark: truk.value != 0,
                        label: const Text("Truck"),
                        onSelected: (value) {
                          if (truk.value == 1) {
                            truk.value = 0;
                          } else {
                            truk.value = 1;
                          }

                          var data = UpdateStreetPerColumn(
                              columnName: "truk", value: truk.value);
                          updateprocess(data, selectedStreet);
                        },
                        selected: true),
                  ],
                ),
              ],
            ),
          )
        : const Center(
            child: Text("No data!"),
          );
  }
}

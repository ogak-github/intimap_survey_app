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
    final streetData = StreetData(StreetSpatialite());
    final selectedStreet = ref.watch(focusedStreetProvider);
    final truk = useState<int>(selectedStreet?.truk ?? 0);
    final pickup = useState<int>(selectedStreet?.pickup ?? 0);
    final roda3 = useState<int>(selectedStreet?.roda3 ?? 0);
    final panelCtrl = ref.watch(panelController);
    final isLoading = useState<bool>(false);

    useEffect(() {
      truk.value = selectedStreet?.truk ?? 0;
      pickup.value = selectedStreet?.pickup ?? 0;
      roda3.value = selectedStreet?.roda3 ?? 0;
      return null;
    }, [selectedStreet]);

    void updateprocess(Street street) async {
      isLoading.value = true;
      const metadata = Metadata(notes: "", blocked: true);
      final data = UpdateData(
          truk: truk.value,
          pickup: pickup.value,
          roda3: roda3.value,
          metadata: metadata);
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
      await streetData.updateStreet(data, selectedStreet.id);
      ref.read(drawStreetProvider.notifier).updateStreetData(newData);
      ref.read(hiveStreetProvider.notifier).addStreet(newData);

      isLoading.value = false;
      panelCtrl.close();
      EasyLoading.dismiss();
      ref.invalidate(drawStreetProvider);
    }

    return selectedStreet != null
        ? Container(
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
                          MyLogger("Roda 3").i(roda3.value.toString());
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
                        },
                        selected: true),
                  ],
                ),
                /*   const Divider(endIndent: 2, indent: 2),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Notes:"),
                    ),
                    Text("${selectedStreet.meta}")
                  ],
                ), */

                const Divider(endIndent: 2, indent: 2),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      updateprocess(selectedStreet);
                    },
                    child: isLoading.value
                        ? const Center(
                            child: Padding(
                            padding: EdgeInsets.all(2),
                            child: CircularProgressIndicator(),
                          ))
                        : const Text("Update"),
                  ),
                ),
              ],
            ),
          )
        : Container(
            child: const Center(
              child: Text("No data!"),
            ),
          );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:survey_app/data/street_spatialite.dart';
import 'package:survey_app/provider/update_street_provider.dart';

import '../../model/route_issue.dart';
import '../../model/street.dart';
import '../../model/update_data.dart';
import '../../provider/street_provider.dart';
import '../../utils/app_logger.dart';
import '../../utils/date_formatter.dart';

class StreetInfo extends HookConsumerWidget {
  final Street? selectedStreet;
  const StreetInfo({super.key, required this.selectedStreet});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streetData = ref.watch(streetDataProvider);
    final markerState = ref.watch(markerDataProvider);
    final selectedStreet = ref.watch(focusedStreetProvider);
    final truk = useState<int>(selectedStreet?.truk ?? 0);
    final pickup = useState<int>(selectedStreet?.pickup ?? 0);
    final roda3 = useState<int>(selectedStreet?.roda3 ?? 0);
    final roadCondition = useState<bool>(false);
    final notes = useState<String?>(null);

    final isLoading = useState<bool>(false);

    useEffect(() {
      dynamic selectedStreetMeta = selectedStreet?.meta;
      Map<String, dynamic> metadataMap;
      truk.value = selectedStreet?.truk ?? 0;
      pickup.value = selectedStreet?.pickup ?? 0;
      roda3.value = selectedStreet?.roda3 ?? 0;
      if (selectedStreetMeta is String && selectedStreetMeta.isNotEmpty) {
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
      notes.value = metadata.notes ?? "-";
      return null;
    }, [selectedStreet]);

    updateProcess(Street street) async {
      var metadata = Metadata(notes: notes.value, blocked: roadCondition.value);
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
          meta: street.meta,
          lastModifiedTime: DateTime.now(),
          geom: street.geom);

      ref.read(updateStreetProvider(newData, data));
      
      if(markerState != null) {
       
      }
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
                        label: const Icon(Icons.motorcycle),
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
                        label: const Icon(Icons.directions_car),
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
                        label: const Icon(Icons.local_shipping),
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
                const Divider(endIndent: 2, indent: 2),
                /*   Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(child: Text("Road Condition:")),
                      Row(
                        children: [
                          ChoiceChip(
                              label: Icon(
                                Icons.block,
                                color: roadCondition.value
                                    ? Colors.redAccent
                                    : Theme.of(context).disabledColor,
                              ),
                              showCheckmark: false,
                              onSelected: (value) {
                                /*   value = !value; */
                                /*  if (roda3.value == 1) {
                                  roda3.value = 0;
                                } else {
                                  roda3.value = 1;
                                }
                                MyLogger("Roda 3").i(roda3.value.toString()); */
                                roadCondition.value = !roadCondition.value;
                              },
                              selected: true),
                        ],
                      ),
                    ],
                  ),
                ), */
                /*    const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Notes:"),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Text(notes.value ?? ""),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          notes.value = await showDialog(
                              context: context,
                              builder: (context) {
                                return const NoteEditor();
                              });
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                  ),
                ), 
                const Divider(endIndent: 2, indent: 2),
                */
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      updateProcess(selectedStreet);
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
                /*      SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      ref.read(focusedStreetProvider.notifier).clear();
                    },
                    child: isLoading.value
                        ? const Center(
                            child: Padding(
                            padding: EdgeInsets.all(2),
                            child: CircularProgressIndicator(),
                          ))
                        : const Text("Close"),
                  ),
                ), */
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}

class NoteEditor extends HookConsumerWidget {
  const NoteEditor({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txtEditingCtrl = useTextEditingController();
    return AlertDialog(
      title: const Text("Notes"),
      content: TextField(
        controller: txtEditingCtrl,
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(txtEditingCtrl.value.text);
            },
            child: const Text("Done"))
      ],
    );
  }
}

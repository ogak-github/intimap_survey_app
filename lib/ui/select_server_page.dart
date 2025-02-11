import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:survey_app/api/street_api.dart';

import '../provider/server_state.dart';
import 'map_widget.dart';

class SelectServerPage extends HookConsumerWidget {
  const SelectServerPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(serverStateProvider);
    final textUrlCtrl = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Server'),
      ),
      body: server.when(
        data: (data) {
          return Center(
            child: Column(
              children: [
                Text(data),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const MapView();
                      }));
                    },
                    child: const Text('Select'))
              ],
            ),
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Change base url'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: textUrlCtrl,
                          decoration: InputDecoration(
                            hintText: 'https://example.com',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context).disabledColor),
                            border: const OutlineInputBorder(),
                            labelText: 'URL',
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Change'),
                        onPressed: () async {
                          final box = await Hive.openBox('base_url');
                          box.put('base_url', textUrlCtrl.text);
                          if (context.mounted) {
                            ref.invalidate(serverStateProvider);
                            ref.invalidate(streetAPIProvider);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  );
                });
          }),
    );
  }
}

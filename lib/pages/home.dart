import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_dashboard/state.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Center(
        child: Column(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectableText("Hello, select a menu item"),
            Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 5,
              spacing: 5,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(notifProvider.notifier).displayNotif("Notification");
                  },
                  label: Text("Show notif"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(dialogProvider.notifier)
                        .displayDialog(message: "Notification", validateAction: "OK", annulationAction: "Cancel");
                  },
                  label: Text("Show dialog"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(textFieldProvider.notifier)
                        .displayTextField(
                          textField: TextField(
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: "TextField",
                              hintText: "Type your text",
                            ),
                          ),
                          validateAction: "OK",
                          annulationAction: "Cancel",
                        );
                  },
                  label: Text("Show text field"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

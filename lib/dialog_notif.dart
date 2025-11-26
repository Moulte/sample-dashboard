import 'package:flutter/material.dart';
import 'package:template_dashboard/model.dart';

Future<bool?> displayDialog(BuildContext context, DialogNotif dialog) async {
  final callback = dialog.callback;
  return await showDialog<bool>(
    context: context,
    barrierDismissible: dialog.barrierDismissible, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(child: ListBody(children: <Widget>[Text(dialog.message)])),
        actions: <Widget>[
          TextButton(
            child: Text(dialog.validateAction),
            onPressed: () {
              if (callback != null) {
                callback(true);
              }
              Navigator.of(context).pop(true);
            },
          ),
          if (dialog.annulationAction != null)
            TextButton(
              child: Text(dialog.annulationAction!),
              onPressed: () {
                if (callback != null) {
                  callback(false);
                }
                Navigator.of(context).pop(false);
              },
            ),
        ],
      );
    },
  );
}

Future<String?> displayTextField(BuildContext context, TextFieldNotif textFieldNotif, {bool barrierDismissible = true}) async {
  final callback = textFieldNotif.callback;
  final textFieldController = TextEditingController(text: textFieldNotif.textField.controller?.text);
  return await showDialog<String>(
    context: context,
    barrierDismissible: barrierDismissible, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: TextField(
          enableIMEPersonalizedLearning: false,
          enableInteractiveSelection: false,
          enableSuggestions: false,
          autofillHints: null,
          autofocus: true,
          autocorrect: false,
          controller: textFieldController,
          focusNode: textFieldNotif.textField.focusNode,
          decoration: textFieldNotif.textField.decoration,
          keyboardType: textFieldNotif.textField.keyboardType,
        ),
        actions: <Widget>[
          TextButton(
            child: Text(textFieldNotif.validateAction),
            onPressed: () {
              if (callback != null) {
                callback(textFieldController.text);
              }
              Navigator.of(context).pop(textFieldController.text);
            },
          ),
          if (textFieldNotif.annulationAction != null)
            TextButton(
              child: Text(textFieldNotif.annulationAction!),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
        ],
      );
    },
  );
}

Future<String?> showPasswordDialog(BuildContext context) async {
  final TextEditingController controller = TextEditingController();

  return showDialog<String?>(
    context: context,
    barrierDismissible: false, // empêche de fermer en cliquant à l'extérieur
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Mot de passe requis"),
        content: TextField(
          controller: controller,
          enableSuggestions: false,
          enableIMEPersonalizedLearning: false,
          textCapitalization: TextCapitalization.characters,
          obscureText: true, // masque le texte
          decoration: const InputDecoration(hintText: "Entrez le mot de passe"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null); // retour null
            },
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(controller.text); // retour valeur saisie
            },
            child: const Text("Valider"),
          ),
        ],
      );
    },
  );
}

void displayNotif(BuildContext context, String message, {String closeLabel = "Close", Duration duration = const Duration(seconds: 20)}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.fixed,
      duration: duration,
      content: Text(message),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      action: SnackBarAction(label: closeLabel, onPressed: () => ScaffoldMessenger.of(context).removeCurrentSnackBar()),
    ),
  );
}

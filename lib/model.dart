// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class DialogNotif {
  final String message;
  final String validateAction;
  final String? annulationAction;
  final bool barrierDismissible;
  final void Function(bool)? callback;

  DialogNotif(this.message, this.validateAction, this.annulationAction, this.barrierDismissible, [this.callback]);
}

class TextFieldNotif {
  final TextField textField;
  final String validateAction;
  final String? annulationAction;
  final void Function(String)? callback;

  TextFieldNotif(this.textField, this.validateAction,this.annulationAction, {this.callback});
}

class Settings extends ChangeNotifier {
  late String _baseUrl;

  Settings(this._baseUrl);

  String get baseUrl => _baseUrl;
  set baseUrl(String baseUrl) {
    _baseUrl = baseUrl;
    notifyListeners();
  }
}

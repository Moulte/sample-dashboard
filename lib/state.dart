import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:micro_entreprise_web/data_model/article.dart';
import 'package:micro_entreprise_web/data_model/config.dart';
import 'package:micro_entreprise_web/data_model/db_client.dart';
import 'package:micro_entreprise_web/data_model/document.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:micro_entreprise_web/api/api.dart';

import 'model.dart';

// --- NOTIF ---
class Notif extends StateNotifier<String?> {
  Notif() : super(null);

  void displayNotif(String? notifText) {
    state = notifText;
  }
}

final notifProvider = StateNotifierProvider<Notif, String?>((ref) => Notif());

// --- DIALOG ---
class DialogNotifier extends StateNotifier<DialogNotif?> {
  DialogNotifier() : super(null);

  Future<void> displayDialog({
    required String message,
    required String validateAction,
    String? annulationAction,
    void Function(bool?)? callback,
    bool barrierDismissible = true,
  }) async {
    state = DialogNotif(message, validateAction, annulationAction, barrierDismissible, callback);
  }
}

final dialogProvider = StateNotifierProvider<DialogNotifier, DialogNotif?>((ref) => DialogNotifier());

// --- TEXTFIELD ---
class TextFieldNotifier extends StateNotifier<TextFieldNotif?> {
  TextFieldNotifier() : super(null);

  Future<void> displayTextField({
    required TextField textField,
    required String validateAction,
    String? annulationAction,
    void Function(String?)? callback,
  }) async {
    state = TextFieldNotif(textField, validateAction, annulationAction, callback: callback);
  }
}

final textFieldProvider = StateNotifierProvider<TextFieldNotifier, TextFieldNotif?>((ref) => TextFieldNotifier());

// --- SETTINGS ---
final prefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError("SharedPreferences not initialized"));
final secureStorageProvider = Provider<FlutterSecureStorage?>((ref) => throw UnimplementedError("FlutterSecureStorage not initialized"));

final settingsProvider = ChangeNotifierProvider<Settings>((ref) {
  final prefs = ref.watch(prefsProvider);
  return Settings(prefs.getString("baseUrl") ?? "https://cloud-cmd.com/api-v2");
});

// --- CONNEXION / API ---
final connexionProvider = Provider<API>((ref) {
  final settings = ref.watch(settingsProvider);
  final String baseUrl = settings.baseUrl;
  final FlutterSecureStorage? secureStorage = ref.watch(secureStorageProvider);
  final api = API(baseUrl: baseUrl, secureStorage: secureStorage);
  api.init();
  return api;
});

final articlesProvider = FutureProvider<List<Article>>((ref) async {
  return ref.watch(connexionProvider).fetchArticles();
});

final documentsProvider = FutureProvider<List<Document>>((ref) async {
  final docs = await ref.watch(connexionProvider).fetchDocuments();
  return docs.sortedBy((b) => b.docDate).reversed.toList();
});

final clientsProvider = FutureProvider<List<DBClient>>((ref) async {
  return ref.watch(connexionProvider).fetchClients();
});

final configProvider = FutureProvider<AppConfiguration>((ref) async {
  return ref.watch(connexionProvider).fetchConfig();
});

final articleSearchProvider = StateProvider<String>((ref) => '');
final clientSearchProvider = StateProvider<String>((ref) => '');
final documentSearchProvider = StateProvider<String>((ref) => '');
final expandedDocumentsProvider = StateProvider<Set<String>>((ref) => <String>{});
final deletingArticleProvider = StateProvider<Set<String>>((ref) => {});
final deletingClientProvider = StateProvider<Set<String>>((ref) => {});
final deletingDocumentProvider = StateProvider<Set<String>>((ref) => {});
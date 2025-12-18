import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_entreprise_web/data_model/config.dart';
import 'package:micro_entreprise_web/state.dart';

class EditConfigurationPage extends ConsumerStatefulWidget {
  const EditConfigurationPage({super.key});

  @override
  ConsumerState<EditConfigurationPage> createState() => _EditConfigurationPageState();
}

class _EditConfigurationPageState extends ConsumerState<EditConfigurationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;

  final societeCtrl = TextEditingController();
  final adresseCtrl = TextEditingController();
  final codePostalCtrl = TextEditingController();
  final villeCtrl = TextEditingController();
  final telephoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final nomCtrl = TextEditingController();
  final prenomCtrl = TextEditingController();
  final siretCtrl = TextEditingController();
  final rcsCtrl = TextEditingController();
  final sirenCtrl = TextEditingController();
  final ibanCtrl = TextEditingController();
  final logoUrlCtrl = TextEditingController();

  void _initFromConfig(AppConfiguration c) {
    societeCtrl.text = c.societe;
    adresseCtrl.text = c.adresse;
    codePostalCtrl.text = c.codePostal;
    villeCtrl.text = c.ville;
    telephoneCtrl.text = c.telephone;
    emailCtrl.text = c.email;
    nomCtrl.text = c.nom;
    prenomCtrl.text = c.prenom;
    siretCtrl.text = c.siret;
    rcsCtrl.text = c.rcs;
    sirenCtrl.text = c.siren;
    ibanCtrl.text = c.iban;
    logoUrlCtrl.text = c.logoUrl;
    _initialized = true;
  }

  @override
  void dispose() {
    societeCtrl.dispose();
    adresseCtrl.dispose();
    codePostalCtrl.dispose();
    villeCtrl.dispose();
    telephoneCtrl.dispose();
    emailCtrl.dispose();
    nomCtrl.dispose();
    prenomCtrl.dispose();
    siretCtrl.dispose();
    rcsCtrl.dispose();
    sirenCtrl.dispose();
    ibanCtrl.dispose();
    logoUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(configProvider);

    return Scaffold(
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (config) {
          if (!_initialized) {
            _initFromConfig(config);
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      const Text('Informations société', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextFormField(
                        controller: societeCtrl,
                        decoration: const InputDecoration(labelText: 'Société'),
                      ),
                      TextFormField(
                        controller: adresseCtrl,
                        decoration: const InputDecoration(labelText: 'Adresse'),
                      ),
                      TextFormField(
                        controller: codePostalCtrl,
                        decoration: const InputDecoration(labelText: 'Code postal'),
                      ),
                      TextFormField(
                        controller: villeCtrl,
                        decoration: const InputDecoration(labelText: 'Ville'),
                      ),

                      const SizedBox(height: 16),
                      const Text('Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextFormField(
                        controller: telephoneCtrl,
                        decoration: const InputDecoration(labelText: 'Téléphone'),
                      ),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),

                      const SizedBox(height: 16),
                      const Text('Responsable', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextFormField(
                        controller: nomCtrl,
                        decoration: const InputDecoration(labelText: 'Nom'),
                      ),
                      TextFormField(
                        controller: prenomCtrl,
                        decoration: const InputDecoration(labelText: 'Prénom'),
                      ),

                      const SizedBox(height: 16),
                      const Text('Informations légales', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextFormField(
                        controller: siretCtrl,
                        decoration: const InputDecoration(labelText: 'SIRET'),
                      ),
                      TextFormField(
                        controller: sirenCtrl,
                        decoration: const InputDecoration(labelText: 'SIREN'),
                      ),
                      TextFormField(
                        controller: rcsCtrl,
                        decoration: const InputDecoration(labelText: 'RCS'),
                      ),
                      TextFormField(
                        controller: ibanCtrl,
                        decoration: const InputDecoration(labelText: 'IBAN'),
                      ),

                      const SizedBox(height: 16),
                      const Text('Branding', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextFormField(
                        controller: logoUrlCtrl,
                        decoration: const InputDecoration(labelText: 'URL du logo'),
                      ),

                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Enregistrer'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final updated = AppConfiguration(
                              societe: societeCtrl.text,
                              adresse: adresseCtrl.text,
                              codePostal: codePostalCtrl.text,
                              ville: villeCtrl.text,
                              telephone: telephoneCtrl.text,
                              email: emailCtrl.text,
                              nom: nomCtrl.text,
                              prenom: prenomCtrl.text,
                              siret: siretCtrl.text,
                              rcs: rcsCtrl.text,
                              siren: sirenCtrl.text,
                              iban: ibanCtrl.text,
                              logoUrl: logoUrlCtrl.text,
                            );

                            try {
                              await ref.read(connexionProvider).postConfig(updated);
                              ref.invalidate(configProvider);
                              ref.read(notifProvider.notifier).displayNotif('Configuration enregistrée');
                            } catch (e) {
                              ref.read(notifProvider.notifier).displayNotif('Erreur : $e');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

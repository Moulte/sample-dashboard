// ======================
// Page : Liste des clients
// ======================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_entreprise_web/data_model/db_client.dart';
import 'package:micro_entreprise_web/state.dart';

class ClientListPage extends ConsumerWidget {
  const ClientListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);
    final search = ref.watch(clientSearchProvider);

    return Scaffold(
      body: clientsAsync.when(
        data: (clients) {
          final filtered = clients.where((c) {
            final q = search.toLowerCase();
            return c.numeroClient.toString().contains(q) ||
                c.nomLivraison.toLowerCase().contains(q) ||
                c.villeLivraison.toLowerCase().contains(q);
          }).toList();

          return Column(
            children: [
              // 🔍 Recherche
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Rechercher un client (nom, n°, ville)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => ref.read(clientSearchProvider.notifier).state = value,
                ),
              ),

              // 📋 Liste
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final client = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          'Client N°${client.numeroClient} – ${client.nomLivraison}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${client.rueLivraison}, '
                          '${client.codePostalLivraison} ${client.villeLivraison}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.blue,
                              onPressed: () => context.go('/clients/edit', extra: client),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () async {
                                try {
                                  await ref.read(connexionProvider).deleteClient(client);
                                  ref.read(notifProvider.notifier).displayNotif('Client supprimé');
                                  ref.invalidate(clientsProvider);
                                } catch (e) {
                                  ref.read(notifProvider.notifier).displayNotif('Erreur : $e');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        error: (e, _) => Center(child: Text(e.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

// ======================
// Page : Ajout d'un nouveau client
// ======================
class AddClientPage extends ConsumerStatefulWidget {
  const AddClientPage({this.editedClient, super.key});
  final DBClient? editedClient;

  @override
  ConsumerState<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends ConsumerState<AddClientPage> {
  final _formKey = GlobalKey<FormState>();

  final numeroClientCtrl = TextEditingController();
  final rueLivraisonCtrl = TextEditingController();
  final codePostalLivraisonCtrl = TextEditingController();
  final villeLivraisonCtrl = TextEditingController();
  final telephoneLivraisonCtrl = TextEditingController();
  final contactLivraisonCtrl = TextEditingController();
  final rueFacturationCtrl = TextEditingController();
  final codePostalFacturationCtrl = TextEditingController();
  final villeFacturationCtrl = TextEditingController();
  final telephoneFacturationCtrl = TextEditingController();
  final contactFacturationCtrl = TextEditingController();
  final nomFacturationCtrl = TextEditingController();
  final nomLivraisonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editedClient != null) {
      final client = widget.editedClient!;
      numeroClientCtrl.text = client.numeroClient;
      nomLivraisonCtrl.text = client.nomLivraison;
      rueLivraisonCtrl.text = client.rueLivraison;
      codePostalLivraisonCtrl.text = client.codePostalLivraison;
      villeLivraisonCtrl.text = client.villeLivraison;
      telephoneLivraisonCtrl.text = client.telephoneLivraison;
      contactLivraisonCtrl.text = client.contactLivraison;
      nomFacturationCtrl.text = client.nomFacturation;
      rueFacturationCtrl.text = client.rueFacturation;
      codePostalFacturationCtrl.text = client.codePostalFacturation;
      villeFacturationCtrl.text = client.villeFacturation;
      telephoneFacturationCtrl.text = client.telephoneFacturation;
      contactFacturationCtrl.text = client.contactFacturation;
    }
  }

  @override
  void dispose() {
    numeroClientCtrl.dispose();
    nomLivraisonCtrl.dispose();
    rueLivraisonCtrl.dispose();
    codePostalLivraisonCtrl.dispose();
    villeLivraisonCtrl.dispose();
    telephoneLivraisonCtrl.dispose();
    contactLivraisonCtrl.dispose();
    nomFacturationCtrl.dispose();
    rueFacturationCtrl.dispose();
    codePostalFacturationCtrl.dispose();
    villeFacturationCtrl.dispose();
    telephoneFacturationCtrl.dispose();
    contactFacturationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                TextFormField(
                  readOnly: widget.editedClient != null,
                  controller: numeroClientCtrl,
                  decoration: const InputDecoration(labelText: 'Numéro client'),
                ),
                const Text('Informations livraison', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: nomLivraisonCtrl,
                  decoration: const InputDecoration(labelText: 'Nom livraison'),
                ),
                TextFormField(
                  controller: rueLivraisonCtrl,
                  decoration: const InputDecoration(labelText: 'Rue livraison'),
                ),
                TextFormField(
                  controller: codePostalLivraisonCtrl,
                  decoration: const InputDecoration(labelText: 'Code postal livraison'),
                ),
                TextFormField(
                  controller: villeLivraisonCtrl,
                  decoration: const InputDecoration(labelText: 'Ville livraison'),
                ),
                TextFormField(
                  controller: telephoneLivraisonCtrl,
                  decoration: const InputDecoration(labelText: 'Téléphone livraison'),
                ),
                TextFormField(
                  controller: contactLivraisonCtrl,
                  decoration: const InputDecoration(labelText: 'Contact livraison'),
                ),
            
                const SizedBox(height: 20),
                const Text('Informations facturation', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: nomFacturationCtrl,
                  decoration: const InputDecoration(labelText: 'Nom facturation'),
                ),
                TextFormField(
                  controller: rueFacturationCtrl,
                  decoration: const InputDecoration(labelText: 'Rue facturation'),
                ),
                TextFormField(
                  controller: codePostalFacturationCtrl,
                  decoration: const InputDecoration(labelText: 'Code postal facturation'),
                ),
                TextFormField(
                  controller: villeFacturationCtrl,
                  decoration: const InputDecoration(labelText: 'Ville facturation'),
                ),
                TextFormField(
                  controller: telephoneFacturationCtrl,
                  decoration: const InputDecoration(labelText: 'Téléphone facturation'),
                ),
                TextFormField(
                  controller: contactFacturationCtrl,
                  decoration: const InputDecoration(labelText: 'Contact facturation'),
                ),
            
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final newClient = DBClient(
                        nomLivraison: nomLivraisonCtrl.text,
                        nomFacturation: nomFacturationCtrl.text,
                        numeroClient: numeroClientCtrl.text,
                        rueLivraison: rueLivraisonCtrl.text,
                        codePostalLivraison: codePostalLivraisonCtrl.text,
                        villeLivraison: villeLivraisonCtrl.text,
                        telephoneLivraison: telephoneLivraisonCtrl.text,
                        contactLivraison: contactLivraisonCtrl.text,
                        rueFacturation: rueFacturationCtrl.text,
                        codePostalFacturation: codePostalFacturationCtrl.text,
                        villeFacturation: villeFacturationCtrl.text,
                        telephoneFacturation: telephoneFacturationCtrl.text,
                        contactFacturation: contactFacturationCtrl.text,
                      );
            
                      try {
                        await ref.read(connexionProvider).postClient(newClient);
                        ref
                            .read(notifProvider.notifier)
                            .displayNotif(widget.editedClient != null ? 'Client modifié avec succès' : 'Client ajouté avec succès');
                        ref.invalidate(clientsProvider);
                      } catch (e) {
                        ref
                            .read(notifProvider.notifier)
                            .displayNotif(
                              widget.editedClient != null
                                  ? 'Erreur lors de la modification du client : $e'
                                  : 'Erreur lors de l\'ajout du client : $e',
                            );
                      }
                    }
                  },
                  child: Text(widget.editedClient != null ? 'Modifier' : 'Ajouter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

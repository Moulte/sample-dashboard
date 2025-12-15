// ======================
// Page : Liste des documents
// ======================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_entreprise_web/data_model/article.dart';
import 'package:micro_entreprise_web/data_model/db_client.dart';
import 'package:micro_entreprise_web/data_model/document.dart';
import 'package:micro_entreprise_web/state.dart';

class DocumentListPage extends ConsumerWidget {
  const DocumentListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(documentsProvider);

    return documents.when(
      data: (documents) {
        return Scaffold(
          appBar: AppBar(title: const Text('Documents')),

          body: ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final d = documents[index];
              return ListTile(
                title: Text('Doc #${d.numeroDocument} - Client ${d.client.numeroClient}'),
                subtitle: Text('Total TTC: ${d.totalTTC.toStringAsFixed(2)} €'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        context.go('/documents/edit', extra: d);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        try {
                          await ref.read(connexionProvider).deleteDocument(d);
                          ref.read(notifProvider.notifier).displayNotif('Client supprimé avec succès');
                        } catch (e) {
                          ref.read(notifProvider.notifier).displayNotif('Erreur lors de la suppression du client : $e');
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      error: (e, _) => Center(child: Text(e.toString())),
      loading: () => Center(child: CircularProgressIndicator()),
    );
  }
}

// ======================
// Page : Ajout d'un document
// ======================
class AddDocumentPage extends ConsumerStatefulWidget {
  final Document? editedDocument;

  const AddDocumentPage({super.key, this.editedDocument});

  @override
  ConsumerState<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends ConsumerState<AddDocumentPage> {
  final _formKey = GlobalKey<FormState>();

  String? _docType = "facture";
  String? _numDoc = "";
  DBClient? _client;
  final List<DocumentRow> lignes = [];

  @override
  void initState() {
    super.initState();
    if (widget.editedDocument != null) {
      final doc = widget.editedDocument!;
      _docType = doc.docType;
      _numDoc = doc.numeroDocument;
      _client = doc.client;
      lignes.addAll(doc.lignes);
    }
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ElevatedButton.icon(onPressed: addItem, icon: const Icon(Icons.add), label: const Text('Ajouter un item')),
    );
  }

  void addItem() {
    setState(() {
      lignes.add(DocumentRow(numeroDocument: _numDoc!, numeroLigne: (lignes.length + 1).toString(), qte: 1, remisePrct: 0.0));
    });
  }

  Widget _buildItem(List<Article> articles, int index) {
    final item = lignes[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: item.article?.codeArticle,
              hint: const Text('Choisir une option'),
              items: articles.map((x) => DropdownMenuItem(value: x.codeArticle, child: Text('${x.codeArticle} - ${x.libArticle}'))).toList(),
              onChanged: (value) {
                setState(() {
                  item.article = articles.firstWhere((a) => a.codeArticle == value);
                });
              },
            ),

            const SizedBox(height: 8),

            TextFormField(
              initialValue: item.qte?.toString(),
              decoration: const InputDecoration(labelText: 'Quantité'),
              onChanged: (value) {
                item.qte = double.tryParse(value);
              },
            ),

            const SizedBox(height: 8),

            TextFormField(
              initialValue: item.remisePrct?.toString(),
              decoration: const InputDecoration(labelText: 'Remise (%)'),
              onChanged: (value) {
                item.remisePrct = double.tryParse(value);
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final articles = ref
        .watch(articlesProvider)
        .when(data: (articles) => articles, error: (e, _) => <Article>[], loading: () => <Article>[]);
    final clients = ref.watch(clientsProvider).when(data: (clients) => clients, error: (e, _) => <DBClient>[], loading: () => <DBClient>[]);
    if(clients.isEmpty || articles.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: Text(widget.editedDocument != null ? 'Modifier un document' : 'Ajouter un document')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                readOnly: widget.editedDocument != null,
                initialValue: _numDoc,
                decoration: const InputDecoration(labelText: 'Numéro document'),
                onChanged: (value) {
                  setState(() {
                    _numDoc = value;
                    for (var ligne in lignes) {
                      ligne.numeroDocument = value;
                    }
                  });
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _docType,
                decoration: const InputDecoration(labelText: 'Type de document'),
                items: const [
                  DropdownMenuItem(value: 'devis', child: Text('Devis')),
                  DropdownMenuItem(value: 'facture', child: Text('Facture')),
                ],
                onChanged: (val) {
                  setState(() => _docType = val);
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _client?.numeroClient,
                decoration: const InputDecoration(labelText: 'Client'),
                items: clients.map((c) => DropdownMenuItem(value: c.numeroClient, child: Text('${c.numeroClient} - ${c.nomLivraison}'))).toList(),
                onChanged: (val) {
                  setState(() => _client = clients.firstWhere((c) => c.numeroClient == val));
                },
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lignes.length + 1, // +1 pour le bouton "Ajouter"
                  itemBuilder: (context, index) {
                    if (index == lignes.length) {
                      return _buildAddButton();
                    }
                    return _buildItem(articles, index);
                  },
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final doc = Document(docType: _docType!, numeroDocument: _numDoc!, client: _client!, lignes: lignes);
                  try {
                    await ref.read(connexionProvider).postDocument(doc);
                    ref
                        .read(notifProvider.notifier)
                        .displayNotif(widget.editedDocument != null ? 'Document modifié avec succès' : 'Document ajouté avec succès');
                  } catch (e) {
                    ref
                        .read(notifProvider.notifier)
                        .displayNotif(
                          widget.editedDocument != null
                              ? 'Erreur lors de la modification du document : $e'
                              : 'Erreur lors de l\'ajout du document : $e',
                        );
                  }
                },
                child: Text(widget.editedDocument != null ? 'Modifier' : 'Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

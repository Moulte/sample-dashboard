import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_entreprise_web/data_model/article.dart';
import 'package:micro_entreprise_web/data_model/db_client.dart';
import 'package:micro_entreprise_web/data_model/document.dart';
import 'package:micro_entreprise_web/state.dart';
import 'package:intl/intl.dart';

class _DocumentRowsView extends StatelessWidget {
  final List<DocumentRow> rows;

  const _DocumentRowsView(this.rows);

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Aucune ligne', style: TextStyle(fontStyle: FontStyle.italic)),
      );
    }

    return Column(
      children: rows.map((r) {
        return ListTile(
          leading: Text(r.numeroLigne),
          dense: true,
          title: Text(r.article != null ? '${r.article!.codeArticle} – ${r.article!.libArticle}' : 'Ligne sans article'),
          subtitle: Row(
            children: [
              Text('Qté : ${r.qte ?? 0} • '),
              Text('Remise : ${r.remisePrct ?? 0} %'),
              if (r.commentaireLigne != null && r.commentaireLigne!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(child: Text('• Commentaire : ${r.commentaireLigne}')),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

class DocumentListPage extends ConsumerWidget {
  const DocumentListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(documentsProvider);
    final search = ref.watch(documentSearchProvider);
    final expandedDocs = ref.watch(expandedDocumentsProvider);

    return Scaffold(
      body: documentsAsync.when(
        data: (documents) {
          final q = search.toLowerCase();

          final filtered = documents.where((d) {
            return d.numeroDocument.toLowerCase().contains(q) ||
                d.client.numeroClient.toString().contains(q) ||
                d.client.nomLivraison.toLowerCase().contains(q);
          }).toList();

          return Column(
            children: [
              // 🔍 Recherche
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Rechercher un document (n°, client)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => ref.read(documentSearchProvider.notifier).state = value,
                ),
              ),

              // 📋 Liste
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final d = filtered[index];
                    final isExpanded = expandedDocs.contains(d.numeroDocument);
                    final deleting = ref.watch(deletingDocumentProvider).contains(d.numeroDocument);

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () {
                              final notifier = ref.read(expandedDocumentsProvider.notifier);
                              final set = {...notifier.state};

                              isExpanded ? set.remove(d.numeroDocument) : set.add(d.numeroDocument);

                              notifier.state = set;
                            },
                            leading: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                            title: Text(
                              '${d.docType.toUpperCase()} '
                              'N° ${d.numeroDocument} – '
                              'Client : ${d.client.numeroClient} '
                              '${d.client.nomLivraison}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Date : ${d.docDate} • '
                              'Total TTC : ${d.totalTTC.toStringAsFixed(2)} €',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: deleting
                                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Icon(Icons.download),
                                  onPressed: deleting
                                      ? null
                                      : () async {
                                          final config = ref.read(configProvider).whenOrNull(data: (d) => d);
                                          if (config == null || !config.checkConfigurationComplete()) {
                                            ref.read(notifProvider.notifier).displayNotif('Configuration incomplète');
                                            return;
                                          }
                                          ref.read(connexionProvider).downloadDocument(config, d);
                                        },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  color: Colors.blue,
                                  onPressed: () => context.go('/documents/edit', extra: d),
                                ),
                                IconButton(
                                  icon: deleting
                                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: deleting
                                      ? null
                                      : () async {
                                          final notifier = ref.read(deletingDocumentProvider.notifier);
                                          notifier.state = {...notifier.state, d.numeroDocument};

                                          try {
                                            await ref.read(connexionProvider).deleteDocument(d);
                                            ref.read(notifProvider.notifier).displayNotif('Document supprimé');
                                            ref.invalidate(documentsProvider);
                                          } catch (e) {
                                            ref.read(notifProvider.notifier).displayNotif('Erreur : $e');
                                          } finally {
                                            notifier.state = notifier.state..remove(d.numeroDocument);
                                          }
                                        },
                                ),
                              ],
                            ),
                          ),
                          AnimatedCrossFade(
                            firstChild: const SizedBox.shrink(),
                            secondChild: _DocumentRowsView(d.lignes),
                            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200),
                          ),
                        ],
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

class AddDocumentPage extends ConsumerStatefulWidget {
  final Document? editedDocument;

  const AddDocumentPage({super.key, this.editedDocument});

  @override
  ConsumerState<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends ConsumerState<AddDocumentPage> {
  final _formKey = GlobalKey<FormState>();

  String _docType = 'facture';
  String _docDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _numDoc = '';
  DBClient? _client;
  final List<DocumentRow> lignes = [];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.editedDocument != null) {
      final doc = widget.editedDocument!;
      _docType = doc.docType;
      _docDate = doc.docDate;
      _numDoc = doc.numeroDocument;
      _client = doc.client;
      lignes.addAll(doc.lignes);
    }
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ElevatedButton.icon(
        style: ButtonStyle(elevation: WidgetStateProperty.all(4)),
        onPressed: addItem,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un item'),
      ),
    );
  }

  void addItem() {
    setState(() {
      lignes.add(DocumentRow(numeroDocument: _numDoc, numeroLigne: (lignes.length + 1).toString(), qte: 1, remisePrct: 0.0));
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
              items: articles
                  .map((x) => DropdownMenuItem(value: x.codeArticle, child: Text('${x.codeArticle} - ${x.libArticle}')))
                  .toList(),
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
            TextFormField(
              initialValue: item.commentaireLigne ?? "",
              decoration: const InputDecoration(labelText: 'Commentaire'),
              onChanged: (value) {
                item.commentaireLigne = value;
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
    final articles = ref.watch(articlesProvider).when(data: (d) => d, error: (_, _) => <Article>[], loading: () => <Article>[]);
    final clients = ref.watch(clientsProvider).when(data: (d) => d, error: (_, _) => [], loading: () => []);

    if (articles.isEmpty || clients.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    ref.watch(documentsProvider).whenData((docs) {
      if (widget.editedDocument == null && _numDoc.isEmpty) {
        final maxNum = docs.map((d) => int.tryParse(d.numeroDocument) ?? 0).fold<int>(0, (a, b) => b > a ? b : a);
        _numDoc = (maxNum + 1).toString();
      }
    });

    return Scaffold(
      body: Padding(
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
                  TextFormField(
                    readOnly: widget.editedDocument != null,
                    initialValue: _docDate,
                    decoration: const InputDecoration(labelText: 'Date du document'),
                    onChanged: (value) {
                      setState(() {
                        _docDate = value;
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
                      setState(() => _docType = val!);
                    },
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _client?.numeroClient,
                    decoration: const InputDecoration(labelText: 'Client'),
                    items: clients
                        .map((c) => DropdownMenuItem<String>(value: c.numeroClient, child: Text('${c.numeroClient} - ${c.nomLivraison}')))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _client = clients.firstWhere((c) => c.numeroClient == val));
                    },
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 400,
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
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            setState(() => _isSubmitting = true);

                            final doc = Document(
                              docType: _docType,
                              docDate: _docDate,
                              numeroDocument: _numDoc,
                              client: _client!,
                              lignes: lignes,
                            );

                            try {
                              await ref.read(connexionProvider).postDocument(doc);
                              ref
                                  .read(notifProvider.notifier)
                                  .displayNotif(widget.editedDocument != null ? 'Document modifié' : 'Document ajouté');
                              ref.invalidate(documentsProvider);
                            } catch (e) {
                              ref.read(notifProvider.notifier).displayNotif('Erreur : $e');
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          },
                    child: _isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(widget.editedDocument != null ? 'Modifier' : 'Ajouter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

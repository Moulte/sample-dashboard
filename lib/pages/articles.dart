// ======================
// Page : Ajout d'une ligne Article
// ======================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_entreprise_web/data_model/article.dart';
import 'package:micro_entreprise_web/state.dart';

class ArticleListPage extends ConsumerWidget {
  const ArticleListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesProvider);
    final search = ref.watch(articleSearchProvider);

    return Scaffold(
      body: articlesAsync.when(
        data: (articles) {
          final filtered = articles.where((a) {
            final q = search.toLowerCase();
            return a.codeArticle.toLowerCase().contains(q) || a.libArticle.toLowerCase().contains(q);
          }).toList();

          return Column(
            children: [
              // 🔍 Champ de recherche
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Rechercher un article (code ou libellé)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => ref.read(articleSearchProvider.notifier).state = value,
                ),
              ),

              // 📋 Liste
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final a = filtered[index];
                    final deleting = ref.watch(deletingArticleProvider).contains(a.codeArticle);

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text('${a.codeArticle} – ${a.libArticle}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Prix HT : ${a.prixUnitaireHT.toStringAsFixed(2)} € • TVA : ${a.tvaPrct.toStringAsFixed(2)} %'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.blue,
                              onPressed: () => context.go('/articles/edit', extra: a),
                            ),
                            IconButton(
                              icon: deleting
                                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: deleting
                                  ? null
                                  : () async {
                                      final notifier = ref.read(deletingArticleProvider.notifier);

                                      notifier.state = {...notifier.state, a.codeArticle};

                                      try {
                                        await ref.read(connexionProvider).deleteArticle(a);
                                        ref.read(notifProvider.notifier).displayNotif('Article supprimé');
                                        ref.invalidate(articlesProvider);
                                      } catch (e) {
                                        ref.read(notifProvider.notifier).displayNotif('Erreur : $e');
                                      } finally {
                                        notifier.state = notifier.state..remove(a.codeArticle);
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

class AddArticlePage extends ConsumerStatefulWidget {
  const AddArticlePage({this.editedArticle, super.key});
  final Article? editedArticle;

  @override
  ConsumerState<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends ConsumerState<AddArticlePage> {
  final codeCtrl = TextEditingController();
  final libCtrl = TextEditingController();
  final puCtrl = TextEditingController();
  final tvaPrct = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.editedArticle != null) {
      codeCtrl.text = widget.editedArticle!.codeArticle;
      libCtrl.text = widget.editedArticle!.libArticle;
      puCtrl.text = widget.editedArticle!.prixUnitaireHT.toString();
      tvaPrct.text = widget.editedArticle!.tvaPrct.toString();
    }
  }

  @override
  void dispose() {
    codeCtrl.dispose();
    libCtrl.dispose();
    puCtrl.dispose();
    tvaPrct.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                TextField(
                  readOnly: widget.editedArticle != null,
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Code article'),
                ),
                TextField(
                  controller: libCtrl,
                  decoration: const InputDecoration(labelText: 'Libellé article'),
                ),
                TextField(
                  controller: puCtrl,
                  decoration: const InputDecoration(labelText: 'Prix unitaire HT'),
                ),
                TextField(
                  controller: tvaPrct,
                  decoration: const InputDecoration(labelText: 'TVA en %'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          setState(() => _isSubmitting = true);

                          final pu = double.tryParse(puCtrl.text) ?? 0;
                          final tva = double.tryParse(tvaPrct.text) ?? 0;

                          final newArticle = Article(
                            codeArticle: codeCtrl.text,
                            libArticle: libCtrl.text,
                            prixUnitaireHT: pu,
                            tvaPrct: tva,
                          );

                          try {
                            await ref.read(connexionProvider).postArticle(newArticle);
                            ref
                                .read(notifProvider.notifier)
                                .displayNotif(widget.editedArticle != null ? 'Article modifié avec succès' : 'Article ajouté avec succès');
                            ref.invalidate(articlesProvider);
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
                      : Text(widget.editedArticle != null ? 'Modifier' : 'Ajouter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

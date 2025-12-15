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
    final articles = ref.watch(articlesProvider);
    return articles.when(
      data: (articles) {
        return Scaffold(
          appBar: AppBar(title: const Text('Articles')),
          body: ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final a = articles[index];
              return ListTile(
                title: Text('Code: ${a.codeArticle} - Lib: ${a.libArticle}'),
                subtitle: Text('Prix ${a.prixUnitaireHT.toStringAsFixed(2)} €   Tva: ${a.tvaPrct.toStringAsFixed(2)} %'),
                trailing: Row(
                   mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        context.go('/articles/edit', extra: a);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        try {
                          await ref.read(connexionProvider).deleteArticle(a);
                          ref.read(notifProvider.notifier).displayNotif('Article supprimé avec succès');
                        } catch (e) {
                          ref.read(notifProvider.notifier).displayNotif('Erreur lors de la suppression de l\'article : $e');
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
      appBar: AppBar(title: Text(widget.editedArticle != null ? 'Modifier un article' : 'Ajouter un article')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
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
              onPressed: () async {
                final pu = double.tryParse(puCtrl.text) ?? 0;
                final tva = double.tryParse(tvaPrct.text) ?? 0;
                final newArticle = Article(codeArticle: codeCtrl.text, libArticle: libCtrl.text, prixUnitaireHT: pu, tvaPrct: tva);
                try {
                  await ref.read(connexionProvider).postArticle(newArticle);
                  ref.read(notifProvider.notifier).displayNotif(widget.editedArticle != null ? 'Article modifié avec succès' : 'Article ajouté avec succès');
                } catch (e) {
                  ref.read(notifProvider.notifier).displayNotif(widget.editedArticle != null ? 'Erreur lors de la modification de l\'article : $e' : 'Erreur lors de l\'ajout de l\'article : $e');
                }
              },
              child: Text(widget.editedArticle != null ? 'Modifier' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}

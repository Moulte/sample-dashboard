import 'package:micro_entreprise_web/data_model/article.dart';
import 'package:micro_entreprise_web/data_model/db_client.dart';

class DocumentRow {
  String numeroDocument;
  final String numeroLigne;
  String? commentaireLigne;
  Article? article;
  double? qte;
  double? remisePrct;

  DocumentRow({required this.numeroDocument, required this.numeroLigne, this.article, this.qte, this.remisePrct, this.commentaireLigne});
  factory DocumentRow.fromJson(Map<String, dynamic> json) => DocumentRow(
    numeroDocument: json['numeroDocument'],
    numeroLigne: json['numeroLigne'],
    qte: (json['qte'] as num).toDouble(),
    commentaireLigne: json['commentaireLigne'],
    remisePrct: (json['remisePrct'] as num).toDouble(),
    article: Article.fromJson((json['article'] as Map<String, dynamic>)),
  );

  double get totalLigneHT => ((article?.prixUnitaireHT ?? 0.0) * (qte ?? 0.0)) * (1 - (remisePrct ?? 0.0) / 100);
  double get totalLigneTTC => totalLigneHT * (1 + ((article?.tvaPrct ?? 0.0) / 100));

  Map<String, dynamic> toJson() => {
    'numeroDocument': numeroDocument,
    'numeroLigne': numeroLigne,
    'article': article?.toJson(),
    'qte': qte,
    'remisePrct': remisePrct,
    'commentaireLigne': commentaireLigne,
  };
}

class Document {
  final String docType;
  final String docDate;
  final String numeroDocument;
  final DBClient client;

  final List<DocumentRow> lignes;

  Document({required this.docType, required this.docDate, required this.numeroDocument, required this.client, required this.lignes});
  factory Document.fromJson(Map<String, dynamic> json) => Document(
    docType: json['docType'],
    docDate: json['docDate'],
    numeroDocument: json['numeroDocument'],
    client: DBClient.fromJson(json),
    lignes: (json['lignes'] as List).map((x) => DocumentRow.fromJson(x)).toList(),
  );

  double get totalTTC => lignes.fold(0.0, (sum, item) => sum + item.totalLigneTTC);
  double get totalHT => lignes.fold(0.0, (sum, item) => sum + item.totalLigneHT);

  Map<String, dynamic> toJson() => {
    'docType': docType,
    'docDate': docDate,
    'numeroDocument': numeroDocument,
    'client': client.toJson(),
    'lignes': lignes.map((a) => a.toJson()).toList(),
  };
}

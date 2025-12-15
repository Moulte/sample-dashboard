// ======================
// Model Classes
// ======================

class Article {
  final String codeArticle;
  final String libArticle;
  final double prixUnitaireHT;
  final double tvaPrct;

  Article({
    required this.codeArticle,
    required this.libArticle,
    required this.prixUnitaireHT,
    required this.tvaPrct,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    codeArticle: json['codeArticle'],
    libArticle: json['libArticle'],
    prixUnitaireHT: (json['prixUnitaireHT'] as num).toDouble(),
    tvaPrct: (json['tvaPrct'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'codeArticle': codeArticle,
    'libArticle': libArticle,
    'prixUnitaireHT': prixUnitaireHT,
    'tvaPrct': tvaPrct,
  };
}

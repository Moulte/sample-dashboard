// ======================
// Model Class
// ======================
// Ajout JSON sur la classe Client existante
class DBClient {
  final String numeroClient;
  final String nomLivraison;
  final String rueLivraison;
  final String codePostalLivraison;
  final String villeLivraison;
  final String telephoneLivraison;
  final String contactLivraison;
  final String nomFacturation;
  final String rueFacturation;
  final String codePostalFacturation;
  final String villeFacturation;
  final String telephoneFacturation;
  final String contactFacturation;

  DBClient({
    required this.nomLivraison,
    required this.nomFacturation,
    required this.numeroClient,
    required this.rueLivraison,
    required this.codePostalLivraison,
    required this.villeLivraison,
    required this.telephoneLivraison,
    required this.contactLivraison,
    required this.rueFacturation,
    required this.codePostalFacturation,
    required this.villeFacturation,
    required this.telephoneFacturation,
    required this.contactFacturation,
  });

  factory DBClient.fromJson(Map<String, dynamic> json) => DBClient(
    nomLivraison: json['nomLivraison'],
    nomFacturation: json['nomFacturation'],
    numeroClient: json['numeroClient'],
    rueLivraison: json['rueLivraison'],
    codePostalLivraison: json['codePostalLivraison'],
    villeLivraison: json['villeLivraison'],
    telephoneLivraison: json['telephoneLivraison'],
    contactLivraison: json['contactLivraison'],
    rueFacturation: json['rueFacturation'],
    codePostalFacturation: json['codePostalFacturation'],
    villeFacturation: json['villeFacturation'],
    telephoneFacturation: json['telephoneFacturation'],
    contactFacturation: json['contactFacturation'],
  );

  Map<String, dynamic> toJson() => {
    'nomLivraison': nomLivraison,
    'nomFacturation': nomFacturation,
    'numeroClient': numeroClient,
    'rueLivraison': rueLivraison,
    'codePostalLivraison': codePostalLivraison,
    'villeLivraison': villeLivraison,
    'telephoneLivraison': telephoneLivraison,
    'contactLivraison': contactLivraison,
    'rueFacturation': rueFacturation,
    'codePostalFacturation': codePostalFacturation,
    'villeFacturation': villeFacturation,
    'telephoneFacturation': telephoneFacturation,
    'contactFacturation': contactFacturation,
  };
}

class AppConfiguration {
  String societe;
  String adresse;
  String codePostal;
  String ville;
  String telephone;
  String email;
  String nom;
  String prenom;
  String siret;
  String rcs;
  String siren;
  String iban;
  String logoUrl;

  AppConfiguration({
    required this.societe,
    required this.adresse,
    required this.codePostal,
    required this.ville,
    required this.telephone,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.siret,
    required this.rcs,
    required this.siren,
    required this.iban,
    required this.logoUrl,
  });

  factory AppConfiguration.fromJson(Map<String, dynamic> json) {
    return AppConfiguration(
      societe: json['Société'] ?? '',
      adresse: json['Adresse'] ?? '',
      codePostal: json['Code postal'] ?? '',
      ville: json['Ville'] ?? '',
      telephone: json['Téléphone'] ?? '',
      email: json['Email'] ?? '',
      nom: json['Nom'] ?? '',
      prenom: json['Prénom'] ?? '',
      siret: json['Siret'] ?? '',
      rcs: json['RCS'] ?? '',
      siren: json['Siren'] ?? '',
      iban: json['IBAN'] ?? '',
      logoUrl: json['logo_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'Société': societe,
    'Adresse': adresse,
    'Code postal': codePostal,
    'Ville': ville,
    'Téléphone': telephone,
    'Email': email,
    'Nom': nom,
    'Prénom': prenom,
    'Siret': siret,
    'RCS': rcs,
    'Siren': siren,
    'IBAN': iban,
    'logo_url': logoUrl,
  };

  bool checkConfigurationComplete() {
    return societe.isNotEmpty &&
        adresse.isNotEmpty &&
        codePostal.isNotEmpty &&
        ville.isNotEmpty &&
        telephone.isNotEmpty &&
        email.isNotEmpty &&
        nom.isNotEmpty &&
        prenom.isNotEmpty &&
        siret.isNotEmpty &&
        rcs.isNotEmpty &&
        siren.isNotEmpty &&
        iban.isNotEmpty;
  }
}

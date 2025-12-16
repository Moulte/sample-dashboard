import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:micro_entreprise_web/auth/auth.dart';
import 'package:micro_entreprise_web/data_model/article.dart';
import 'package:micro_entreprise_web/data_model/document.dart';
import 'package:micro_entreprise_web/data_model/db_client.dart';

import 'http_adapter_stub.dart' if (dart.library.html) 'http_adapter_web.dart' if (dart.library.io) 'http_adapter_io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class API {
  final String baseUrl;
  final FlutterSecureStorage? secureStorage;
  late final Client client;

  API({required this.baseUrl, required this.secureStorage});

  void init() {
    client = getClient();
  }

  Future<Response> post(Uri url, {Map<String, String>? headers, Object? body, int retryCount = 0}) async {
    headers ??= {};
    if (!headers.containsKey('Authorization') && kIsWeb == false) {
      final token = await secureStorage?.read(key: 'access_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    final response = await client.post(url, headers: headers, body: body);
    if (response.statusCode == 401 && retryCount < 3) {
      if (kIsWeb) {
        await signInWeb();
      } else {
        await signInDesktop(secureStorage!);
      }
      // Retry the request after re-authentication
      return await get(url, headers: headers, retryCount: retryCount + 1);
    }
    return response;
  }

  Future<Response> delete(Uri url, {Map<String, String>? headers, Object? body, int retryCount = 0}) async {
    headers ??= {};
    if (!headers.containsKey('Authorization') && kIsWeb == false) {
      final token = await secureStorage?.read(key: 'access_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    final response = await client.delete(url, headers: headers, body: body);
    if (response.statusCode == 401 && retryCount < 3) {
      if (kIsWeb) {
        await signInWeb();
      } else {
        await signInDesktop(secureStorage!);
      }
      // Retry the request after re-authentication
      return await get(url, headers: headers, retryCount: retryCount + 1);
    }
    return response;
  }

  Future<Response> get(Uri url, {Map<String, String>? headers, int retryCount = 0}) async {
    headers ??= {};
    if (!headers.containsKey('Authorization') && kIsWeb == false) {
      final token = await secureStorage?.read(key: 'access_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    final response = await client.get(url, headers: headers);
    if (response.statusCode == 401 && retryCount < 3) {
      if (kIsWeb) {
        await signInWeb();
      } else {
        await signInDesktop(secureStorage!);
      }
      // Retry the request after re-authentication
      return await get(url, headers: headers, retryCount: retryCount + 1);
    }
    return response;
  }

  Future<List<Article>> fetchArticles() async {
    final response = await get(Uri.parse('$baseUrl/cmulteau/gestion/articles'));
    final data = json.decode(response.body);
    return (data as List).map((item) => Article.fromJson(item)).toList();
  }

  Future<bool> postArticle(Article article) async {
    final response = await post(Uri.parse('$baseUrl/cmulteau/gestion/articles'), body: json.encode(article.toJson()));
    if (response.statusCode != 200) {
      throw Exception('Failed to post article: ${response.body}');
    }
    return response.statusCode == 200;
  }

  Future<List<Document>> fetchDocuments() async {
    final response = await get(Uri.parse('$baseUrl/cmulteau/gestion/documents'));
    final List<dynamic> rows = json.decode(response.body);
    final Map<String, Document> documentsMap = {};

    for (final row in rows) {
      final String numeroDocument = row['numeroDocument'];

      // Création du document s'il n'existe pas
      if (!documentsMap.containsKey(numeroDocument)) {
        documentsMap[numeroDocument] = Document(
          docType: row['docType'],
          docDate: row['docDate'],
          numeroDocument: numeroDocument,
          client: DBClient.fromJson(row),
          lignes: [],
        );
      }

      // Si une ligne existe (LEFT JOIN peut renvoyer NULL)
      if (row['numeroDocumentLigne'] != null) {
        documentsMap[numeroDocument]!.lignes.add(
          DocumentRow(
            numeroDocument: numeroDocument,
            numeroLigne: row['numeroLigne'],
            commentaireLigne: row['commentaireLigne'],
            qte: (row['quantite'] as num?)?.toDouble(),
            remisePrct: (row['remisePrct'] as num?)?.toDouble(),
            article: Article(
              codeArticle: row['codeArticle'],
              libArticle: row['libArticle'],
              prixUnitaireHT: (row['prixUnitaireHT'] as num).toDouble(),
              tvaPrct: (row['tvaPrct'] as num).toDouble(),
            ),
          ),
        );
      }
    }

    return documentsMap.values.toList();
  }

  Future<bool> postDocument(Document document) async {
    final response = await post(Uri.parse('$baseUrl/cmulteau/gestion/documents'), body: json.encode(document.toJson()));
    if (response.statusCode != 200) {
      throw Exception('Failed to post document: ${response.body}');
    }
    return response.statusCode == 200;
  }

  Future<List<DBClient>> fetchClients() async {
    final response = await get(Uri.parse('$baseUrl/cmulteau/gestion/clients'));
    final data = json.decode(response.body);
    return (data as List).map((item) => DBClient.fromJson(item)).toList();
  }

  Future<bool> postClient(DBClient client) async {
    final response = await post(Uri.parse('$baseUrl/cmulteau/gestion/clients'), body: json.encode(client.toJson()));
    if (response.statusCode != 200) {
      throw Exception('Failed to post client: ${response.body}');
    }
    return response.statusCode == 200;
  }

  Future<bool> deleteArticle(Article article) async {
    final response = await delete(Uri.parse('$baseUrl/cmulteau/gestion/articles'), body: json.encode(article.toJson()));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete article: ${response.body}');
    }
    return response.statusCode == 200;
  }

  Future<bool> deleteClient(DBClient client) async {
    final response = await delete(Uri.parse('$baseUrl/cmulteau/gestion/clients'), body: json.encode(client.toJson()));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete client: ${response.body}');
    }
    return response.statusCode == 200;
  }

  Future<bool> deleteDocument(Document document) async {
    final response = await delete(Uri.parse('$baseUrl/cmulteau/gestion/documents'), body: json.encode(document.toJson()));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete document: ${response.body}');
    }
    return response.statusCode == 200;
  }
}

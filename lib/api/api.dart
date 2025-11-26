import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:template_dashboard/auth/auth.dart';

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
}

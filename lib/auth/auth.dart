import 'dart:io';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

// Config
final authorizationEndpoint = Uri.parse('https://cloud-cmd.com/oauth/authorize');
final tokenEndpoint = Uri.parse('https://cloud-cmd.com/oauth/token');
const clientId = 'U5hthqvUWSH9Jvn09LpbaOvZ';
final scopes = ["GESTION"];

Future<int> findFixedPort(int port) async {
  try {
    // Tente d'ouvrir le port fixe
    final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
    await socket.close();
    return port;
  } catch (e) {
    throw Exception('Port $port indisponible. Veuillez libérer ce port ou en choisir un autre.');
  }
}
Future<void> signInWeb() async {}

Future<void> signInDesktop(FlutterSecureStorage secureStorage) async {
  final port = await findFixedPort(4000);
  final redirectUri = Uri.parse('http://127.0.0.1:$port/callback');

  // Build the authorization URL (PKCE will be used by oauth2 package if requested)
  final grant = oauth2.AuthorizationCodeGrant(
    clientId,
    authorizationEndpoint,
    tokenEndpoint,
    // Optionally: provide a custom http client
    // httpClient: http.Client(),
  );

  final authorizationUrl = grant.getAuthorizationUrl(
    redirectUri,
    scopes: scopes,
    // state/extraParameters if needed
  );

  // Start a local server to listen for the redirect
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);

  // Open the system browser
  await launchUrl(authorizationUrl, mode: LaunchMode.externalApplication);

  // Wait for redirect
  final request = await server.first;
  final uri = request.uri;

  // Serve a simple page to the browser then close
  request.response
    ..statusCode = 200
    ..headers.set('Content-Type', 'text/html')
    ..write('<html><h3>You can close this window and return to the app.</h3></html>');
  await request.response.close();
  await server.close();

  // Finish the grant and obtain credentials
  final client = await grant.handleAuthorizationResponse(uri.queryParameters);

  // Save tokens securely
  await secureStorage.write(key: 'access_token', value: client.credentials.accessToken);
  if (client.credentials.refreshToken != null) {
    await secureStorage.write(key: 'refresh_token', value: client.credentials.refreshToken);
  }

}

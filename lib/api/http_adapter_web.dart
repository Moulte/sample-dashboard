import 'package:http/browser_client.dart';
import 'package:http/http.dart';

Client getClient() {
  BrowserClient browserClient = BrowserClient();
  browserClient.withCredentials = true;
  return browserClient;
}

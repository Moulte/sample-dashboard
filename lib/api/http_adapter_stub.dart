// Fallback par défaut (mobile + desktop)
import 'package:http/http.dart';

Client getClient() {
  throw UnimplementedError("No HttpClientAdapter implementation for this platform");
}

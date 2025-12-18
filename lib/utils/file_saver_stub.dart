import 'dart:typed_data';

Future<void> saveFileImpl({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
}) async {
  throw UnsupportedError('Plateforme non supportée');
}

import 'dart:typed_data';

import 'file_saver_stub.dart' if (dart.library.html) 'file_saver_web.dart' if (dart.library.io) 'file_saver_desktop.dart';

Future<void> saveFile({required Uint8List bytes, required String filename, String mimeType = 'application/octet-stream'}) {
  return saveFileImpl(bytes: bytes, filename: filename, mimeType: mimeType);
}

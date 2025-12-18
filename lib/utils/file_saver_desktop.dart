import 'dart:io';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';

Future<void> saveFileImpl({required Uint8List bytes, required String filename, required String mimeType}) async {
  final path = await getSaveLocation(suggestedName: filename);

  if (path == null) return;

  final file = File(path.path);
  await file.writeAsBytes(bytes, flush: true);
}

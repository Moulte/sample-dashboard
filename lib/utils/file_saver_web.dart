import 'dart:convert';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> saveFileImpl(Uint8List bytes, String filename) async {
  final web.HTMLAnchorElement anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = "data:application/octet-stream;base64,${base64Encode(bytes)}"
    ..style.display = 'none'
    ..download = filename;

  web.document.body!.appendChild(anchor);
  anchor.click();
  web.document.body!.removeChild(anchor);
}

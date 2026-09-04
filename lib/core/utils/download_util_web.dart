import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Web implementation: creates a Blob URL and triggers a download via an
/// anchor click, then revokes the URL. Replaces the previous `data:` URL
/// approach, which Chrome blocks for top-level navigation.
///
/// Uses package:web (not dart:html) so the app compiles to dart2wasm as
/// well as dart2js.
void downloadTextFileWeb(String fileName, String content) {
  final bytes = utf8.encode(content);
  final parts = <JSUint8Array>[bytes.toJS].toJS;
  final blob = web.Blob(parts, web.BlobPropertyBag(type: 'text/csv'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

import 'dart:convert';
import 'dart:html' as html;

/// Web implementation: creates a Blob URL and triggers a download via an
/// anchor click, then revokes the URL. Replaces the previous `data:` URL
/// approach, which Chrome blocks for top-level navigation.
void downloadTextFileWeb(String fileName, String content) {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement()
    ..href = url
    ..download = fileName;
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

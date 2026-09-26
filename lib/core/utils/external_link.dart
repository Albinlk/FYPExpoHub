/// A project link typed by an admin, as a safe web address: `https://` is
/// assumed when the scheme is missing, and anything that isn't http(s) (e.g.
/// `javascript:`) is refused. Null when there is nothing to open.
Uri? safeExternalUri(String? raw) {
  final text = raw?.trim() ?? '';
  if (text.isEmpty) return null;
  final hasScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').hasMatch(text);
  final uri = Uri.tryParse(hasScheme ? text : 'https://$text');
  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https')) || uri.host.isEmpty) {
    return null;
  }
  return uri;
}

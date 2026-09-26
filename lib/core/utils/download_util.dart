// `dart.library.js_interop`, not `dart.library.html`: dart:html doesn't
// exist under dart2wasm, so the html check picked the no-op stub in the
// Wasm build that deploy.yml ships and CSV export silently did nothing.
import 'package:fyp_expo_hub/core/utils/download_util_stub.dart'
    if (dart.library.js_interop) 'package:fyp_expo_hub/core/utils/download_util_web.dart'
    as impl;

/// Downloads [content] as a UTF-8 text file named [fileName].
/// On web this uses a Blob URL + anchor click (the `data:` URL approach is
/// blocked by Chrome for top-level navigation); the stub is a no-op
/// elsewhere (this app is web-only).
void downloadTextFileWeb(String fileName, String content) {
  impl.downloadTextFileWeb(fileName, content);
}

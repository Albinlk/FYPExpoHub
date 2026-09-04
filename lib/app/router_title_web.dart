/// Web implementation: sets document.title (browser tab / history) via
/// dart:js_interop.
library;

import 'dart:js_interop';

@JS('document')
external JSObject get _document;

extension _DocumentTitle on JSObject {
  external set title(JSString value);
}

void setDocumentTitleImpl(String title) {
  _document.title = title.toJS;
}

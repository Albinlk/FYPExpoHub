import 'package:web/web.dart' as web;

import 'shared_session_storage.dart';

class _DocumentCookieJar implements CookieJar {
  @override
  String read() => web.document.cookie;

  @override
  void write(String cookie) => web.document.cookie = cookie;
}

CookieJar? documentCookieJar() => _DocumentCookieJar();
String? readLocalStorage(String key) => web.window.localStorage.getItem(key);
void removeLocalStorage(String key) => web.window.localStorage.removeItem(key);

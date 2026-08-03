import 'package:flutter/foundation.dart';

/// Logger that only outputs in debug mode.
/// In release builds, all calls are no-ops, preventing
/// error details from leaking into the browser console.
void logDebug(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print(message);
  }
}

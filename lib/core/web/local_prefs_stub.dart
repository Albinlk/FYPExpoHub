import 'local_prefs.dart';

/// Outside the browser there is no localStorage: keep preferences in memory.
LocalPrefs createLocalPrefs() => MemoryLocalPrefs();

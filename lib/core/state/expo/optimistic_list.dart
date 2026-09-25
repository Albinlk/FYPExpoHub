import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a list mutation immediately, then waits for the database write.
/// If the write fails the previous list is restored and the error is
/// rethrown, so the caller (an admin page) can report it instead of a
/// success message for a change that never persisted.
mixin OptimisticList<T> on Notifier<List<T>> {
  // Bumped when a commit starts AND when it finishes, so a fetch that
  // overlapped any part of a write can be recognised (see [loadRemote]).
  int _generation = 0;

  Future<void> commit(List<T> next, Future<void> Function() write) async {
    final previous = state;
    _generation++;
    state = next;
    try {
      await write();
    } catch (_) {
      // Only roll back if nothing else changed the list in the meantime —
      // restoring [previous] then would silently drop that other change.
      if (identical(state, next)) state = previous;
      rethrow;
    } finally {
      _generation++;
    }
  }

  /// Applies a fetched list — unless a local write started or finished
  /// while the fetch was in flight. That fetch may predate the write, and
  /// applying it would make a just-saved item vanish, so it's retried once.
  /// [fetch] returns null to mean "keep what's there" (e.g. an empty remote
  /// result while bundled fallback data is showing).
  Future<void> loadRemote(Future<List<T>?> Function() fetch) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      final generation = _generation;
      final rows = await fetch();
      if (generation != _generation) continue;
      if (rows != null) state = rows;
      return;
    }
  }
}

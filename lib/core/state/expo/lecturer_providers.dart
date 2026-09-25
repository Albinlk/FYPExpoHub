import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;
import '../../domain/models/lecturer.dart';
import '../../supabase/supabase_client_provider.dart';
import 'service_providers.dart';

// ==========================================
// LECTURER CONFIG & AUTH STATE
// ==========================================
final allLecturersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Refetch per signed-in user (RLS decides which profiles are visible).
  ref.watch(currentAuthUserProvider.select((u) => u?.id));
  final db = ref.read(supabaseDbServiceProvider);
  return db.getLecturersOnce();
});

/// Lowercased email -> display name for every profile with role
/// 'lecturer'. Keyed ONLY by email: a row without one is skipped rather
/// than keyed by its display name (which could never match a sign-in).
final lecturerConfigProvider = Provider<Map<String, String>>((ref) {
  final all = ref.watch(allLecturersProvider);
  final result = <String, String>{};
  final list = all.asData?.value ?? [];
  for (final doc in list) {
    final email = doc['email'] as String?;
    if (email == null || email.trim().isEmpty) continue;
    final name = (doc['displayName'] ?? doc['display_name']) as String?;
    result[email.trim().toLowerCase()] =
        (name == null || name.trim().isEmpty) ? email.split('@').first.toUpperCase() : name;
  }
  return result;
});

final lecturerAuthProvider = NotifierProvider<LecturerAuthNotifier, Lecturer?>(
  LecturerAuthNotifier.new,
);

/// Lecturer config gated on sign-in: anonymous visitors never initialize
/// the config (and therefore never fire the lecturers-table query).
final _lecturerConfigWhenSignedIn = Provider<Map<String, String>?>((ref) {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) return null;
  return ref.watch(lecturerConfigProvider);
});

class LecturerAuthNotifier extends Notifier<Lecturer?> {
  @override
  Lecturer? build() {
    // Only react to auth changes. The lecturer CONFIG (display names via
    // allLecturersProvider -> getLecturersOnce) is read lazily below when a
    // user is actually signed in — previously this notifier eagerly fired a
    // lecturers-table query on every anonymous page load.
    final initial = _evaluate(user: ref.read(currentAuthUserProvider));
    ref.listen(
      currentAuthUserProvider,
      (_, next) => state = _evaluate(user: next),
    );
    // Re-resolve the display name once the config arrives (only possible
    // when signed in — the gated provider is a no-op otherwise).
    ref.listen(_lecturerConfigWhenSignedIn, (_, __) {
      state = _evaluate(user: ref.read(currentAuthUserProvider));
    });
    return initial;
  }

  Lecturer? _evaluate({User? user}) {
    if (user == null || user.email == null) return null;
    // Signed in: now (and only now) read the config for the display name.
    // lecturerConfigProvider watching allLecturersProvider only triggers
    // the lecturers-table query from authenticated sessions.
    final config = ref.read(lecturerConfigProvider);
    final emailLower = user.email!.toLowerCase();
    // Only an actual lecturer profile counts. This used to return a
    // Lecturer for ANY signed-in user, so FYPMS students and other staff
    // were routed to /lecturer/visits after signing in.
    final configName = config[emailLower];
    if (configName == null) return null;
    final displayName = configName;

    return Lecturer(
      id: user.id,
      uid: user.id,
      displayName: displayName,
      email: user.email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void signOut() async {
    state = null;
    await ref.read(supabaseClientProvider).auth.signOut();
  }
}

final lecturerDisplayNameProvider = Provider<String?>((ref) {
  return ref.watch(lecturerAuthProvider)?.displayName;
});

final lecturerUidProvider = Provider<String?>((ref) {
  return ref.watch(lecturerAuthProvider)?.uid;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;
import '../../domain/models/lecturer.dart';
import '../../supabase/supabase_client_provider.dart';
import 'service_providers.dart';

// ==========================================
// LECTURER CONFIG & AUTH STATE
// ==========================================
const hardcodedLecturerConfig = <String, String>{
  'albin1841@uitm.edu.my': 'ALBIN LEMUEL KUSHAN',
};

final allLecturersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = ref.read(supabaseDbServiceProvider);
  return db.getLecturersOnce();
});

final lecturerConfigProvider = Provider<Map<String, String>>((ref) {
  final all = ref.watch(allLecturersProvider);
  final result = <String, String>{};
  final list = all.asData?.value ?? [];
  for (final doc in list) {
    final email = (doc['email'] ?? doc['display_name']) as String?;
    final name = (doc['displayName'] ?? doc['display_name']) as String?;
    if (email != null && name != null) {
      result[email.toLowerCase()] = name;
    }
  }
  result.addAll(hardcodedLecturerConfig);
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
    final displayName = config[emailLower] ??
        (user.userMetadata?['display_name'] as String?) ??
        user.email!.split('@').first.toUpperCase();

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

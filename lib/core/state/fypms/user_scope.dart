import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../supabase/supabase_client_provider.dart';

/// The signed-in user's id. Every FYPMS data provider watches this so its
/// cached result is thrown away when the user changes: RLS decides what
/// those queries return, so rows fetched for one user (or while signed
/// out) must never be shown to the next person on a shared lab computer.
final fypmsUserScopeProvider = Provider<String?>(
  (ref) => ref.watch(currentAuthUserProvider.select((u) => u?.id)),
);

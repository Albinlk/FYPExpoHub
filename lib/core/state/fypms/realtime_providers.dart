import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../supabase/fypms_realtime_service.dart';
import '../../supabase/supabase_client_provider.dart';
import '../../supabase/supabase_realtime_service.dart';
import '../../utils/logger.dart';
import 'coordinator_providers.dart';
import 'record_resources_providers.dart';

// ==============================================================================
// FYPMS REALTIME (minimal, optional, additive)
// ==============================================================================

/// Bridges Supabase Postgres changes for the five active-workflow tables into
/// provider refreshes. Kept alive by `FypmsShell` while any FYPMS page is
/// mounted and auto-disposed (channels removed) when the shell unmounts.
///
/// Realtime is NOT required for operation: if Supabase is unavailable/offline,
/// channel setup fails and the existing refetch-after-mutation paths remain
/// the refresh mechanism.
final fypmsRealtimeProvider =
    Provider<FypmsRealtimeSubscriptions>((ref) {
  bool isSupabaseReady() {
    try {
      return Supabase.instance.isInitialized;
    } catch (_) {
      return false;
    }
  }

  if (!isSupabaseReady()) {
    final empty = FypmsRealtimeSubscriptions();
    ref.onDispose(() => empty.dispose());
    return empty;
  }

  final client = ref.watch(supabaseClientProvider);
  final subs = FypmsRealtimeSubscriptions(client);
  ref.onDispose(() => subs.dispose());
  final realtime = SupabaseRealtimeService(client);

  try {
    subs.add(realtime.subscribeToFypmsLive(onTableChange: {
      'fyp_supervision_requests': () {
        ref.invalidate(fypPendingSupervisionRequestsProvider);
        ref.invalidate(mySupervisionRequestsProvider);
        ref.invalidate(fypSupervisionRequestsProvider);
      },
      'fyp_progress_logs': () => ref.invalidate(fypProgressLogsProvider),
      'fyp_form_submissions': () => ref.invalidate(fypFormSubmissionsProvider),
      'fyp_correction_items': () => ref.invalidate(fypCorrectionItemsProvider),
      'fyp_expo_publications': () => ref.invalidate(fypExpoPublicationsProvider),
    }));
  } catch (e) {
    logDebug('FYPMS realtime (multiplex) unavailable - polling fallback active: $e');
  }

  return subs;
});

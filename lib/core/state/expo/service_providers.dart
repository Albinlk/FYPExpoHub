import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../supabase/supabase_client_provider.dart';
import '../../supabase/supabase_database_service.dart';
import '../../supabase/supabase_rpc_service.dart';
import '../../supabase/supabase_realtime_service.dart';
import '../../supabase/supabase_storage_service.dart';

// ==============================================================================
// SERVICE PROVIDERS
// ==============================================================================
final supabaseDbServiceProvider = Provider<SupabaseDatabaseService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseDatabaseService(client);
});

final supabaseRpcServiceProvider = Provider<SupabaseRpcService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseRpcService(client);
});

final supabaseRealtimeServiceProvider = Provider<SupabaseRealtimeService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseRealtimeService(client);
});

final supabaseStorageServiceProvider = Provider<SupabaseStorageService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseStorageService(client);
});

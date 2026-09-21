import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/logger.dart';

/// Supabase client singleton provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Stream provider for auth state changes
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// Current authenticated user provider
final currentAuthUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.asData?.value.session?.user ??
      ref.watch(supabaseClientProvider).auth.currentUser;
});

/// Profile model for Supabase profiles table
class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String role; // 'admin' | 'lecturer'
  final bool isActive;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.isActive = true,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      role: json['role'] as String? ?? 'lecturer',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'role': role,
      'is_active': isActive,
    };
  }
}

/// Fetches the profile of the currently logged-in user from the database
final currentProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) return null;

  final client = ref.watch(supabaseClientProvider);
  try {
    final data = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return UserProfile.fromJson(data);
  } on ClientException catch (e) {
    logDebug('Profile fetch failed (offline): $e');
    return _profileFromMetadataFallback(user);
  } on TimeoutException catch (e) {
    logDebug('Profile fetch failed (timeout): $e');
    return _profileFromMetadataFallback(user);
  } catch (e) {
    // Unlike a network/offline failure, this means the backend responded
    // with an error (e.g. a Postgres/RLS error) — log it distinctly so it
    // isn't mistaken for expected offline behaviour, then still fall back
    // to metadata so the UI doesn't hard-fail on a transient backend issue.
    logDebug('Profile fetch failed (backend error, not offline): $e');
    return _profileFromMetadataFallback(user);
  }
});

UserProfile _profileFromMetadataFallback(User user) {
  return UserProfile(
    id: user.id,
    email: user.email ?? '',
    displayName: (user.userMetadata?['display_name'] as String?) ??
        user.email?.split('@').first.toUpperCase() ??
        '',
    role: (user.userMetadata?['role'] as String?) ?? 'lecturer',
  );
}

/// Admin validation provider (checks database profile role)
final isAdminProvider = FutureProvider<bool>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  return profile != null && profile.role == 'admin' && profile.isActive;
});

/// Lecturer validation provider (checks database profile role)
final isLecturerProvider = FutureProvider<bool>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  return profile != null && profile.role == 'lecturer' && profile.isActive;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;
import '../core/state/fypms_state_providers.dart';
import '../core/state/state_providers.dart';
import '../core/supabase/supabase_client_provider.dart';

/// Resolves the redirect target for [goRouterProvider], if any. Each
/// authorization concern (FYPMS auth/workspace gating, the admin-domain
/// root redirect, the admin path gate, and the post-login redirect) is its
/// own named guard below rather than one large inline closure.
Future<String?> resolveRouterRedirect(Ref ref, String location) async {
  final uri = Uri.parse(location);
  final path = uri.path;
  final user = ref.read(currentAuthUserProvider);
  final isLoggingIn = path == '/admin/sign-in';
  final isAdminPath = path.startsWith('/admin');
  final isFypmsPath = path.startsWith('/fypms');
  final isAdminDomain = Uri.base.host == 'admin.fskmjasinfypexhibition.site';

  if (isFypmsPath) {
    return _fypmsAuthGuard(ref, path: path, location: location, user: user);
  }

  final adminDomainRedirect = _adminDomainRootGuard(
    path: path,
    isAdminDomain: isAdminDomain,
    user: user,
  );
  if (adminDomainRedirect != null) return adminDomainRedirect;

  if (path.startsWith('/lecturer/visits')) {
    return _lecturerVisitsGuard(ref, location: location, user: user);
  }

  if (isAdminPath && !isLoggingIn) {
    final redirect = await _adminPathGuard(ref, location: location, user: user);
    if (redirect != null) return redirect;
  }

  if (user != null && isLoggingIn) {
    return _postLoginRedirect(ref, from: uri.queryParameters['from']);
  }

  return null;
}

/// The sign-in page, remembering where the user was headed so they land
/// back there afterwards instead of on a generic dashboard.
String signInRedirect(String location) =>
    Uri(path: '/admin/sign-in', queryParameters: {'from': location}).toString();

/// [from] if it's a same-origin app path, else null. Rejects
/// protocol-relative (`//evil.example`) and absolute URLs so the `from`
/// parameter can't be abused as an open redirect.
String? safeReturnPath(String? from) {
  if (from == null || !from.startsWith('/') || from.startsWith('//')) return null;
  if (from.contains('://') || from.contains(r'\')) return null;
  if (Uri.tryParse(from)?.path == '/admin/sign-in') return null;
  return from;
}

/// Reads a role FutureProvider, treating a failed lookup as "no".
Future<bool> _safeFlag(Ref ref, FutureProvider<bool> provider) async {
  try {
    return await ref.read(provider.future);
  } catch (_) {
    return false;
  }
}

/// FYPMS routes require authentication and, once signed in, gate each
/// per-workspace path (`/fypms/student`, `/fypms/supervisor`, ...) to the
/// role codes that hold access to it.
Future<String?> _fypmsAuthGuard(
  Ref ref, {
  required String path,
  required String location,
  required User? user,
}) async {
  if (user == null) {
    return signInRedirect(location);
  }
  final roles = await ref.read(fypmsCurrentRolesProvider.future);
  if (roles.isEmpty) {
    // Keep the shell, which renders the "No FYPMS Access" screen.
    return null;
  }
  final home = _fypmsHomeForRoles(roles);
  if (path == '/fypms' || path == '/fypms/') {
    return home;
  }
  final workspace = _fypmsWorkspaceForPath(path);
  if (workspace != null && !_roleAllowsWorkspace(roles, workspace)) {
    return home;
  }
  return null;
}

/// On the admin subdomain's root path, route to sign-in when signed out or
/// straight to the dashboard when already authenticated.
String? _adminDomainRootGuard({
  required String path,
  required bool isAdminDomain,
  required User? user,
}) {
  if (!isAdminDomain || path != '/') return null;
  return user == null ? '/admin/sign-in' : '/admin';
}

/// Any other `/admin/*` path requires a signed-in user with the admin role.
Future<String?> _adminPathGuard(
  Ref ref, {
  required String location,
  required User? user,
}) async {
  if (user == null) {
    return signInRedirect(location);
  }
  final isAdmin = await ref.read(isAdminProvider.future);
  if (!isAdmin) {
    return '/admin/sign-in';
  }
  return null;
}

/// `/lecturer/visits/**` is the lecturer workspace. It used to have no
/// guard at all (the page just rendered a sign-in prompt); RLS still limits
/// the data, but a non-lecturer shouldn't land in it.
Future<String?> _lecturerVisitsGuard(
  Ref ref, {
  required String location,
  required User? user,
}) async {
  if (user == null) return signInRedirect(location);
  if (ref.read(lecturerAuthProvider) != null) return null;
  // The lecturer config loads asynchronously; the profile role is the
  // authoritative answer while it does.
  if (await _safeFlag(ref, isLecturerProvider)) return null;
  if (await _safeFlag(ref, isAdminProvider)) return null;
  return '/';
}

/// Once signed in while on the sign-in page, send the user back to the page
/// they were trying to reach, or else to their own workspace. Previously
/// every non-admin was treated as a lecturer, so FYPMS students were sent
/// to /lecturer/visits and lost their original deep link.
Future<String?> _postLoginRedirect(Ref ref, {String? from}) async {
  final isAdmin = await ref.read(isAdminProvider.future);
  final back = safeReturnPath(from);
  if (back != null && (isAdmin || !back.startsWith('/admin'))) {
    return back;
  }
  if (isAdmin) {
    return '/admin';
  }
  final lecturer = ref.read(lecturerAuthProvider);
  if (lecturer != null || await _safeFlag(ref, isLecturerProvider)) {
    return '/lecturer/visits';
  }
  try {
    final roles = await ref.read(fypmsCurrentRolesProvider.future);
    if (roles.isNotEmpty) return _fypmsHomeForRoles(roles);
  } catch (_) {
    // No FYPMS access — stay on the sign-in page, which explains that.
  }
  return null;
}

/// Resolves the landing workspace for a set of FYPMS role codes.
String _fypmsHomeForRoles(List<String> roles) {
  if (roles.contains('student')) return '/fypms/student';
  if (roles.contains('supervisor') || roles.contains('co_supervisor')) {
    return '/fypms/supervisor';
  }
  if (roles.contains('examiner')) return '/fypms/examiner';
  if (roles.contains('csp600_lecturer') || roles.contains('csp650_lecturer')) {
    return '/fypms/csp';
  }
  if (roles.contains('fyp_coordinator') || roles.contains('admin')) {
    return '/fypms/coordinator';
  }
  return '/fypms';
}

/// Identifies which FYPMS workspace a path belongs to, or null for the
/// workspace-agnostic `/fypms` root.
String? _fypmsWorkspaceForPath(String path) {
  const workspaces = [
    'student',
    'supervisor',
    'examiner',
    'csp',
    'coordinator',
  ];
  final segments = path.split('/');
  if (segments.length < 3 || segments[1] != 'fypms') return null;
  final workspace = segments[2];
  return workspaces.contains(workspace) ? workspace : null;
}

/// Whether the given role codes permit access to the given workspace.
bool _roleAllowsWorkspace(List<String> roles, String workspace) {
  bool has(String code) => roles.contains(code);
  switch (workspace) {
    case 'student':
      return has('student');
    case 'supervisor':
      return has('supervisor') || has('co_supervisor');
    case 'examiner':
      return has('examiner');
    case 'csp':
      return has('csp600_lecturer') || has('csp650_lecturer');
    case 'coordinator':
      return has('fyp_coordinator') || has('admin');
    default:
      return false;
  }
}

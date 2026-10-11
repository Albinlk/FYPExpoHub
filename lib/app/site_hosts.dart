import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/supabase/supabase_client_provider.dart';

/// The public exhibition site (Exhibition + Past Projects Guide).
const kMainHost = 'fskmjasinfypexhibition.site';

/// Host of the FYP Workspace (CSP600 / CSP650), set at build time with
/// `--dart-define=CSP_HOST=fyp.fskmjasinfypexhibition.site`. Empty (today)
/// means the Workspace lives on this same site under `/fypms`.
const kCspHostDefine = String.fromEnvironment('CSP_HOST');

/// The Workspace host ('' = same site). Overridable in tests.
final cspHostProvider = Provider<String>((ref) => kCspHostDefine);

/// The host this page was served from. Overridable in tests.
final currentHostProvider = Provider<String>((ref) => Uri.base.host);

/// Path of the in-app hop to another site: `/go?to=<absolute url>`.
/// go_router cannot redirect across origins, so guards send the user here
/// and [ExternalRedirectPage] performs the jump.
const kExternalRedirectPath = '/go';

/// Paths the Workspace host serves itself; everything else belongs to the
/// exhibition site.
bool isWorkspacePath(String path) =>
    path.startsWith('/fypms') ||
    path == '/sign-in' ||
    path == '/reset-password' ||
    path == kExternalRedirectPath;

/// Absolute URL on the Workspace host.
String cspUrl(String cspHost, String location) => 'https://$cspHost$location';

/// Absolute URL on the exhibition site.
String mainSiteUrl(String location) => 'https://$kMainHost$location';

/// The in-app route that hops to [url].
String externalRedirect(String url) =>
    Uri(path: kExternalRedirectPath, queryParameters: {'to': url}).toString();

/// Hosts [ExternalRedirectPage] may send people to (no open redirect).
Set<String> allowedRedirectHosts(String cspHost) => {kMainHost, if (cspHost.isNotEmpty) cspHost};

/// Opens the FYP Workspace (CSP600 / CSP650): on its own host once the
/// subdomain is live, otherwise `/fypms` here (the guard asks signed-out
/// visitors to sign in first and brings them back).
void openCspWorkspace(BuildContext context, WidgetRef ref) {
  final cspHost = ref.read(cspHostProvider);
  if (cspHost.isNotEmpty && ref.read(currentHostProvider) != cspHost) {
    context.go(externalRedirect(cspUrl(cspHost, '/fypms')));
    return;
  }
  final signedIn = ref.read(currentAuthUserProvider) != null;
  context.go(signedIn ? '/fypms' : '/sign-in?from=%2Ffypms');
}

/// Opens [path] on the exhibition site, leaving the Workspace host if needed.
void openExhibitionSite(BuildContext context, WidgetRef ref, [String path = '/']) {
  final cspHost = ref.read(cspHostProvider);
  if (cspHost.isNotEmpty && ref.read(currentHostProvider) == cspHost) {
    context.go(externalRedirect(mainSiteUrl(path)));
    return;
  }
  context.go(path);
}

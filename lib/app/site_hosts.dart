import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/supabase/supabase_client_provider.dart';

/// The public exhibition site (Exhibition + Past Projects Guide).
const kMainHost = 'fskmjasinfypexhibition.site';

/// Host of the FYP Workspace (CSP600 / CSP650), set at build time with
/// `--dart-define=CSP_HOST=fyp.fskmjasinfypexhibition.site` (repo variable
/// `CSP_HOST`). Empty (local runs, or after a rollback) means the Workspace
/// lives on this same site under `/fypms`.
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

/// Handbook guides (`docs/guides/<guide>.md`), built by mkdocs.yml into
/// `/handbook/` on both hosts.
const kHandbookVisitorGuide = 'visitor';
const kHandbookStudentGuide = 'student';
const kHandbookLecturerGuide = 'lecturer';
const kHandbookCoordinatorGuide = 'coordinator';
const kHandbookAdminGuide = 'exhibition-admin';
const kHandbookAccountsGuide = 'accounts';

/// Path of a handbook guide on the current host, e.g. `/handbook/guides/visitor/`.
String handbookGuideUrl(String guide) => '/handbook/guides/$guide/';

/// The guide for the Workspace menu section holding [location] (path, query
/// ignored): student pages → student; supervisor, examiner, CSP lecturer and
/// programme unit pages → lecturer; coordinator pages → coordinator;
/// anything else (notifications, the Workspace root) → accounts.
String handbookGuideForWorkspacePath(String location) {
  final path = Uri.parse(location).path;
  bool under(String prefix) => path == prefix || path.startsWith('$prefix/');
  if (under('/fypms/student')) return kHandbookStudentGuide;
  if (under('/fypms/supervisor') ||
      under('/fypms/examiner') ||
      under('/fypms/csp') ||
      under('/fypms/pu')) {
    return kHandbookLecturerGuide;
  }
  if (under('/fypms/coordinator')) return kHandbookCoordinatorGuide;
  return kHandbookAccountsGuide;
}

/// Opens a handbook [guide] in a new tab. The handbook is a static site
/// outside the Flutter router, so it is loaded by the browser, not go_router.
Future<bool> openHandbook(String guide) =>
    launchUrl(Uri.base.resolve(handbookGuideUrl(guide)), webOnlyWindowName: '_blank');

/// Opens [path] on the exhibition site, leaving the Workspace host if needed.
void openExhibitionSite(BuildContext context, WidgetRef ref, [String path = '/']) {
  final cspHost = ref.read(cspHostProvider);
  if (cspHost.isNotEmpty && ref.read(currentHostProvider) == cspHost) {
    context.go(externalRedirect(mainSiteUrl(path)));
    return;
  }
  context.go(path);
}

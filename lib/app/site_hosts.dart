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

/// Where "Help" lands for each app page: path prefix → handbook guide and
/// section id (the `{#id}` on a heading in `docs/guides/<guide>.md`; null =
/// top of the guide). A prefix matches itself and the pages below it
/// (`/admin` matches `/admin/x`, not `/administer`); the longest match wins.
/// `/` matches only the home page. Keep the anchors in sync with the guides
/// (test/app/handbook_routes_test.dart checks them).
const kHandbookRoutes = <String, ({String guide, String? anchor})>{
  // Exhibition site.
  '/': (guide: kHandbookVisitorGuide, anchor: 'home'),
  '/projects': (guide: kHandbookVisitorGuide, anchor: 'projects'),
  '/projects/junior-guide': (guide: kHandbookVisitorGuide, anchor: 'past-projects'),
  '/booths': (guide: kHandbookVisitorGuide, anchor: 'booths'),
  '/schedule': (guide: kHandbookVisitorGuide, anchor: 'schedule'),
  '/awards': (guide: kHandbookVisitorGuide, anchor: 'awards'),
  '/announcements': (guide: kHandbookVisitorGuide, anchor: 'awards'),
  '/lecturer': (guide: kHandbookVisitorGuide, anchor: 'by-lecturer'),
  '/lecturer/sign-in': (guide: kHandbookLecturerGuide, anchor: 'open-my-visits'),
  '/lecturer/visits': (guide: kHandbookLecturerGuide, anchor: 'visits'),
  '/archive': (guide: kHandbookVisitorGuide, anchor: 'archive'),
  '/info': (guide: kHandbookVisitorGuide, anchor: 'info'),
  '/faq': (guide: kHandbookVisitorGuide, anchor: 'info'),
  '/privacy': (guide: kHandbookVisitorGuide, anchor: 'info'),
  // Accounts.
  '/sign-in': (guide: kHandbookAccountsGuide, anchor: 'sign-in'),
  '/admin/sign-in': (guide: kHandbookAccountsGuide, anchor: 'sign-in'),
  '/reset-password': (guide: kHandbookAccountsGuide, anchor: 'reset-password'),
  kExternalRedirectPath: (guide: kHandbookAccountsGuide, anchor: 'two-sites'),
  // FYP Workspace.
  '/fypms': (guide: kHandbookAccountsGuide, anchor: null),
  '/fypms/notifications': (guide: kHandbookAccountsGuide, anchor: null),
  // Student.
  '/fypms/student': (guide: kHandbookStudentGuide, anchor: 'workspace'),
  '/fypms/student/records': (guide: kHandbookStudentGuide, anchor: 'record'),
  '/fypms/student/supervision': (guide: kHandbookStudentGuide, anchor: 'supervision'),
  '/fypms/student/progress': (guide: kHandbookStudentGuide, anchor: 'progress-logs'),
  '/fypms/student/forms': (guide: kHandbookStudentGuide, anchor: 'forms'),
  '/fypms/student/reports': (guide: kHandbookStudentGuide, anchor: 'reports'),
  '/fypms/student/lean-canvas': (guide: kHandbookStudentGuide, anchor: 'lean-canvas'),
  '/fypms/student/milestones': (guide: kHandbookStudentGuide, anchor: 'milestones'),
  '/fypms/student/corrections': (guide: kHandbookStudentGuide, anchor: 'corrections'),
  '/fypms/student/deliverables': (guide: kHandbookStudentGuide, anchor: 'deliverables'),
  '/fypms/student/presentations': (guide: kHandbookStudentGuide, anchor: 'presentations'),
  '/fypms/student/marks': (guide: kHandbookStudentGuide, anchor: 'marks'),
  // Supervisor.
  '/fypms/supervisor': (guide: kHandbookLecturerGuide, anchor: 'supervisor'),
  '/fypms/supervisor/requests': (guide: kHandbookLecturerGuide, anchor: 'approve-supervision'),
  '/fypms/supervisor/progress': (guide: kHandbookLecturerGuide, anchor: 'consultation-logs'),
  '/fypms/supervisor/reports': (guide: kHandbookLecturerGuide, anchor: 'endorse-report'),
  '/fypms/supervisor/evaluations': (guide: kHandbookLecturerGuide, anchor: 'evaluations'),
  '/fypms/supervisor/corrections': (guide: kHandbookLecturerGuide, anchor: 'corrections'),
  '/fypms/supervisor/milestones': (guide: kHandbookLecturerGuide, anchor: 'supervisor-milestones'),
  // Examiner.
  '/fypms/examiner': (guide: kHandbookLecturerGuide, anchor: 'examiner'),
  // CSP600 / CSP650 lecturer.
  '/fypms/csp': (guide: kHandbookLecturerGuide, anchor: 'csp-lecturer'),
  '/fypms/csp/requests': (guide: kHandbookLecturerGuide, anchor: 'approve-supervision'),
  '/fypms/csp/nominations': (guide: kHandbookLecturerGuide, anchor: 'nominate'),
  '/fypms/csp/cohort': (guide: kHandbookLecturerGuide, anchor: 'handover'),
  '/fypms/csp/milestones': (guide: kHandbookLecturerGuide, anchor: 'csp-milestones'),
  '/fypms/csp/presentations': (guide: kHandbookLecturerGuide, anchor: 'csp-presentations'),
  '/fypms/csp/evaluations': (guide: kHandbookLecturerGuide, anchor: 'csp-evaluations'),
  '/fypms/csp/marks': (guide: kHandbookLecturerGuide, anchor: 'finalize-marks'),
  // Programme Unit head.
  '/fypms/pu': (guide: kHandbookLecturerGuide, anchor: 'pu-decide'),
  // Coordinator.
  '/fypms/coordinator': (guide: kHandbookCoordinatorGuide, anchor: 'dashboard'),
  '/fypms/coordinator/records': (guide: kHandbookCoordinatorGuide, anchor: 'records'),
  '/fypms/coordinator/reports': (guide: kHandbookCoordinatorGuide, anchor: 'reports'),
  '/fypms/coordinator/users': (guide: kHandbookCoordinatorGuide, anchor: 'users-roles'),
  '/fypms/coordinator/enrol': (guide: kHandbookCoordinatorGuide, anchor: 'enrol'),
  '/fypms/coordinator/assignments': (guide: kHandbookCoordinatorGuide, anchor: 'assignments'),
  '/fypms/coordinator/requests': (guide: kHandbookCoordinatorGuide, anchor: 'supervision-requests'),
  '/fypms/coordinator/nominations': (guide: kHandbookCoordinatorGuide, anchor: 'nomination-cvs'),
  '/fypms/coordinator/letters': (guide: kHandbookCoordinatorGuide, anchor: 'letters'),
  '/fypms/coordinator/presentations': (guide: kHandbookCoordinatorGuide, anchor: 'presentations'),
  '/fypms/coordinator/mark-allocation': (guide: kHandbookCoordinatorGuide, anchor: 'mark-allocation'),
  '/fypms/coordinator/rubrics': (guide: kHandbookCoordinatorGuide, anchor: 'rubrics'),
  '/fypms/coordinator/semesters': (guide: kHandbookCoordinatorGuide, anchor: 'semesters'),
  '/fypms/coordinator/expo': (guide: kHandbookCoordinatorGuide, anchor: 'expo'),
  '/fypms/coordinator/audit': (guide: kHandbookCoordinatorGuide, anchor: 'audit'),
  // Exhibition admin.
  '/admin': (guide: kHandbookAdminGuide, anchor: 'dashboard'),
  '/admin/event': (guide: kHandbookAdminGuide, anchor: 'event'),
  '/admin/schedule': (guide: kHandbookAdminGuide, anchor: 'schedule'),
  '/admin/announcements': (guide: kHandbookAdminGuide, anchor: 'announcements'),
  '/admin/awards': (guide: kHandbookAdminGuide, anchor: 'awards'),
  '/admin/projects': (guide: kHandbookAdminGuide, anchor: 'projects'),
  '/admin/booths': (guide: kHandbookAdminGuide, anchor: 'booths'),
  '/admin/imports': (guide: kHandbookAdminGuide, anchor: 'import'),
  '/admin/lecturers': (guide: kHandbookAdminGuide, anchor: 'lecturers'),
  '/admin/assignments': (guide: kHandbookAdminGuide, anchor: 'lecturer-assignments'),
  '/admin/visits': (guide: kHandbookAdminGuide, anchor: 'visits'),
  '/admin/feedback': (guide: kHandbookAdminGuide, anchor: 'feedback'),
  '/admin/audit': (guide: kHandbookAdminGuide, anchor: 'audit'),
  '/admin/settings': (guide: kHandbookAdminGuide, anchor: 'settings'),
};

/// Handbook URL (path on the current host) for the app page at [location]:
/// `/handbook/guides/<guide>/#<id>`, or the guide's top when the page has no
/// section. Query and fragment are ignored; pages outside [kHandbookRoutes]
/// get the visitor guide.
String handbookUrlForLocation(String location) {
  var path = Uri.tryParse(location)?.path ?? '/';
  if (path.isEmpty) path = '/';
  if (path.length > 1 && path.endsWith('/')) path = path.substring(0, path.length - 1);
  String? best;
  for (final prefix in kHandbookRoutes.keys) {
    final matches = prefix == '/' ? path == '/' : path == prefix || path.startsWith('$prefix/');
    if (matches && (best == null || prefix.length > best.length)) best = prefix;
  }
  if (best == null) return handbookGuideUrl(kHandbookVisitorGuide);
  final route = kHandbookRoutes[best]!;
  final anchor = route.anchor;
  return anchor == null ? handbookGuideUrl(route.guide) : '${handbookGuideUrl(route.guide)}#$anchor';
}

/// Opens the handbook section for the app page at [location] in a new tab.
/// The handbook is a static site outside the Flutter router, so it is loaded
/// by the browser, not go_router.
Future<bool> openHandbookAt(String location) =>
    launchUrl(Uri.base.resolve(handbookUrlForLocation(location)), webOnlyWindowName: '_blank');

/// Opens [path] on the exhibition site, leaving the Workspace host if needed.
void openExhibitionSite(BuildContext context, WidgetRef ref, [String path = '/']) {
  final cspHost = ref.read(cspHostProvider);
  if (cspHost.isNotEmpty && ref.read(currentHostProvider) == cspHost) {
    context.go(externalRedirect(mainSiteUrl(path)));
    return;
  }
  context.go(path);
}

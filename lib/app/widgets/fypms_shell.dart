import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../site_hosts.dart';
import '../../core/supabase/supabase_client_provider.dart';
import '../../core/state/fypms_state_providers.dart';
import '../../core/widgets/scholar_lab.dart';
import '../theme/theme.dart';
import '../../features/fypms/presentation/widgets/semester_selector.dart';
import '../../features/fypms/presentation/pages/notifications_page.dart';
import '../../features/admin_auth/presentation/widgets/my_account_dialog.dart';
import '../../core/widgets/async_state.dart';
import '../../core/layout/responsive.dart';

/// Workspace dashboard routes match exactly only — their sub-pages (e.g.
/// /fypms/supervisor/evaluations) must not also highlight the dashboard
/// entry alongside the sub-page entry.
const _dashboardRoutes = [
  '/fypms/pu',
  '/fypms/student',
  '/fypms/supervisor',
  '/fypms/examiner',
  '/fypms/csp',
  '/fypms/coordinator',
];

bool _navRouteIsActive(String route, String currentPath) {
  final isDashboard = _dashboardRoutes.contains(route);
  return (isDashboard && currentPath == route) ||
      (!isDashboard && currentPath.startsWith(route));
}

class FypmsShell extends ConsumerWidget {
  final Widget child;

  const FypmsShell({super.key, required this.child});

  void _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(supabaseClientProvider).auth.signOut();
    ref.invalidate(currentAuthUserProvider);
    ref.invalidate(fypmsCurrentRolesProvider);
    // Same place as signing out of the admin CMS: the exhibition home (on the
    // Workspace host this is the Workspace sign-in).
    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    final location = GoRouterState.of(context).uri.toString();
    final roles = ref.watch(fypmsCurrentRolesProvider);
    final isAdmin = ref.watch(isFypAdminProvider);
    final isCoordinator = ref.watch(isFypCoordinatorProvider);
    final isStudent = ref.watch(isFypStudentProvider);
    final isSupervisor = ref.watch(isFypSupervisorProvider);
    final isExaminer = ref.watch(isFypExaminerProvider);
    final isCsp = ref.watch(isCspLecturerProvider);
    final isPu = ref.watch(isFypProgrammeHeadProvider);
    final isStaff = isAdmin || isCoordinator || isSupervisor || isExaminer || isCsp || isPu;

    // A role lookup that is still running or has failed is not "no access".
    if (!roles.hasValue) {
      return Scaffold(
        body: roles.hasError
            ? AsyncErrorView(
                error: roles.error!,
                what: 'your FYPMS access',
                onRetry: () => ref.invalidate(fypmsCurrentRolesProvider),
              )
            : const AsyncLoadingView(what: 'your FYPMS access'),
      );
    }

    final hasAccess =
        roles.value?.isNotEmpty == true && (isAdmin || isCoordinator || isStudent || isSupervisor || isExaminer || isCsp || isPu);

    if (!hasAccess) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48, color: DesignSystem.primary),
                const SizedBox(height: DesignSystem.spaceMd),
                Text('No FYPMS Access', style: DesignSystem.h2),
                const SizedBox(height: DesignSystem.spaceSm),
                Text(
                  'Your account is not assigned an active FYPMS role yet. '
                  'Please contact your coordinator.',
                  style: DesignSystem.bodyMd,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignSystem.spaceLg),
                FilledButton(
                  onPressed: () => _logout(context, ref),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Keep the optional realtime bridge alive while any FYPMS page is mounted.
    // It auto-disposes (channels removed) when the shell unmounts; if Supabase
    // is unavailable it no-ops and refetch-after-mutation remains the fallback.
    ref.watch(fypmsRealtimeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: BrandMark(
                    color: Colors.white,
                    accent: DesignSystem.secondaryContainer,
                    // Phones need the room for the action icons.
                    subtitle: Breakpoints.isNarrow(context) ? null : 'WORKSPACE · CSP600 · CSP650',
                  ),
                ),
              ),
            ),
            if (isDesktop)
              Row(
                children: [
                  // Staff lists follow the chosen semester (backlog S2).
                  if (isStaff) ...[const SemesterSelector(), const SizedBox(width: 24)],
                  const NotificationBell(),
                  const SizedBox(width: 8),
                  const MyAccountButton(),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white70),
                    onPressed: () => _logout(context, ref),
                    tooltip: 'Sign Out',
                  ),
                ],
              ),
          ],
        ),
        actions: !isDesktop
            ? [
                if (isStaff) const SemesterSelector(),
                const NotificationBell(),
                const MyAccountButton(compact: true),
                // On the narrowest phones Sign Out lives in the menu instead.
                if (!Breakpoints.isNarrow(context))
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _logout(context, ref),
                    tooltip: 'Sign Out',
                  ),
              ]
            : null,
      ),
      drawer: !isDesktop ? _FypmsDrawer(onSignOut: () => _logout(context, ref), currentPath: location, isAdmin: isAdmin, isCoordinator: isCoordinator, isStudent: isStudent, isSupervisor: isSupervisor, isExaminer: isExaminer, isCsp: isCsp, isPu: isPu) : null,
      body: Row(
        children: [
          if (isDesktop)
            _FypmsSidebar(
              currentPath: location,
              isAdmin: isAdmin,
              isCoordinator: isCoordinator,
              isStudent: isStudent,
              isSupervisor: isSupervisor,
              isExaminer: isExaminer,
              isCsp: isCsp,
      isPu: isPu,
            ),
          Expanded(
            child: Container(
              color: DesignSystem.background,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Whether a student has a CSP650 record, so the CSP650-only pages (Lean
/// Canvas, Deliverables, Corrections) belong in their menu. Defaults to true
/// while records load, so nothing disappears and reappears.
bool _studentHasProjectCourse(WidgetRef ref, bool isStudent) {
  if (!isStudent) return false;
  final records = ref.watch(myFypRecordsProvider).value;
  if (records == null) return true;
  return records.any((r) => r.currentCourseCode == 'CSP650');
}

typedef _NavItem = ({String title, IconData icon, String route});

/// A labelled cluster of links inside a section ("Review", "People"…).
typedef _NavGroup = ({String? label, List<_NavItem> items});

/// One role's part of the menu ("Supervisor", "Coordinator"…). People with
/// several roles see one collapsible section per role instead of one long
/// list with repeated "Milestones" / "Evaluations" entries.
typedef _NavSection = ({String title, IconData icon, List<_NavGroup> groups});

List<_NavSection> _navSections({
  bool showProjectPages = true,
  String cspTitle = 'CSP Dashboard',
  bool teachesCsp600 = false,
  required bool isAdmin,
  required bool isCoordinator,
  required bool isStudent,
  required bool isSupervisor,
  required bool isExaminer,
  required bool isCsp,
  bool isPu = false,
}) {
  final sections = <_NavSection>[];

  if (isStudent) {
    sections.add((
      title: 'Student',
      icon: Icons.school_outlined,
      groups: [
        (label: null, items: [
          (title: 'Student Dashboard', icon: Icons.dashboard, route: '/fypms/student'),
          (title: 'My Records', icon: Icons.folder_open, route: '/fypms/student/records'),
          (title: 'Supervision', icon: Icons.supervisor_account, route: '/fypms/student/supervision'),
        ]),
        (label: 'My work', items: [
          (title: 'Progress Logs', icon: Icons.timeline, route: '/fypms/student/progress'),
          (title: 'Forms', icon: Icons.description, route: '/fypms/student/forms'),
          (title: 'Reports', icon: Icons.upload_file, route: '/fypms/student/reports'),
          // CSP650 only (FSKM handbook): Lean Canvas (F13), Corrections (F12), Deliverables.
          if (showProjectPages) (title: 'Lean Canvas', icon: Icons.grid_view, route: '/fypms/student/lean-canvas'),
          if (showProjectPages) (title: 'Corrections', icon: Icons.fact_check, route: '/fypms/student/corrections'),
          if (showProjectPages) (title: 'Deliverables', icon: Icons.checklist, route: '/fypms/student/deliverables'),
        ]),
        (label: 'Dates & results', items: [
          (title: 'Milestones', icon: Icons.flag, route: '/fypms/student/milestones'),
          (title: 'Presentations', icon: Icons.event, route: '/fypms/student/presentations'),
          (title: 'Marks', icon: Icons.scoreboard, route: '/fypms/student/marks'),
        ]),
      ],
    ));
  }

  if (isSupervisor) {
    sections.add((
      title: 'Supervisor',
      icon: Icons.supervisor_account,
      groups: [
        (label: null, items: [
          (title: 'Supervisor Dashboard', icon: Icons.dashboard, route: '/fypms/supervisor'),
          (title: 'Assigned Records', icon: Icons.folder_open, route: '/fypms/supervisor/records'),
          (title: 'Supervision Requests', icon: Icons.mail, route: '/fypms/supervisor/requests'),
        ]),
        (label: 'Review', items: [
          (title: 'Progress Reviews', icon: Icons.timeline, route: '/fypms/supervisor/progress'),
          (title: 'Report Endorsement', icon: Icons.fact_check, route: '/fypms/supervisor/reports'),
          (title: 'Evaluations', icon: Icons.description, route: '/fypms/supervisor/evaluations'),
          (title: 'Corrections', icon: Icons.fact_check, route: '/fypms/supervisor/corrections'),
          (title: 'Milestones', icon: Icons.flag, route: '/fypms/supervisor/milestones'),
        ]),
      ],
    ));
  }

  if (isExaminer) {
    sections.add((
      title: 'Examiner',
      icon: Icons.rate_review_outlined,
      groups: [
        (label: null, items: [
          (title: 'Examiner Dashboard', icon: Icons.dashboard, route: '/fypms/examiner'),
          (title: 'Assigned Records', icon: Icons.folder_open, route: '/fypms/examiner/records'),
          (title: 'Evaluations', icon: Icons.description, route: '/fypms/examiner/evaluations'),
          (title: 'Corrections', icon: Icons.fact_check, route: '/fypms/examiner/corrections'),
        ]),
      ],
    ));
  }

  if (isCsp) {
    sections.add((
      title: '${cspTitle.replaceAll(' Dashboard', '')} Lecturer',
      icon: Icons.menu_book_outlined,
      groups: [
        (label: null, items: [
          (title: cspTitle, icon: Icons.dashboard, route: '/fypms/csp'),
          (title: 'Offerings', icon: Icons.school, route: '/fypms/csp/offerings'),
          (title: 'Supervision Requests', icon: Icons.mail, route: '/fypms/csp/requests'),
        ]),
        (label: 'Cohort', items: [
          // Handbook Table 2.1 #19 and #29: CSP600 lecturers assign examiners and hand over to CSP650.
          if (teachesCsp600) (title: 'Examiners & Handover', icon: Icons.swap_horiz, route: '/fypms/csp/cohort'),
          // Appendix N: the nominator attaches the nominee's CV and declaration for the PU.
          (title: 'Nomination CVs', icon: Icons.badge_outlined, route: '/fypms/csp/nominations'),
          (title: 'Milestones', icon: Icons.flag, route: '/fypms/csp/milestones'),
        ]),
        (label: 'Assessment', items: [
          (title: 'Presentations', icon: Icons.event, route: '/fypms/csp/presentations'),
          (title: 'Evaluations', icon: Icons.description, route: '/fypms/csp/evaluations'),
          (title: 'Marks', icon: Icons.scoreboard, route: '/fypms/csp/marks'),
        ]),
      ],
    ));
  }

  if (isPu) {
    sections.add((
      title: 'Programme Unit',
      icon: Icons.how_to_reg,
      groups: [
        (label: null, items: [(title: 'Nominations', icon: Icons.how_to_reg, route: '/fypms/pu')]),
      ],
    ));
  }

  if (isCoordinator || isAdmin) {
    sections.add((
      title: 'Coordinator',
      icon: Icons.admin_panel_settings_outlined,
      groups: [
        (label: null, items: [
          (title: 'Coordinator Dashboard', icon: Icons.dashboard, route: '/fypms/coordinator'),
          (title: 'All Records', icon: Icons.folder_open, route: '/fypms/coordinator/records'),
          (title: 'Reports', icon: Icons.insights, route: '/fypms/coordinator/reports'),
        ]),
        (label: 'People', items: [
          (title: 'Users & Roles', icon: Icons.manage_accounts, route: '/fypms/coordinator/users'),
          (title: 'Enrol Students', icon: Icons.group_add, route: '/fypms/coordinator/enrol'),
          (title: 'Assignments', icon: Icons.assignment_ind, route: '/fypms/coordinator/assignments'),
          (title: 'Supervision Requests', icon: Icons.mail, route: '/fypms/coordinator/requests'),
          (title: 'Nomination CVs', icon: Icons.badge_outlined, route: '/fypms/coordinator/nominations'),
          if (!isPu) (title: 'Appointment Letters', icon: Icons.description_outlined, route: '/fypms/coordinator/letters'),
        ]),
        (label: 'Assessment', items: [
          (title: 'Presentations', icon: Icons.event, route: '/fypms/coordinator/presentations'),
          (title: 'Mark Allocation', icon: Icons.pie_chart_outline, route: '/fypms/coordinator/mark-allocation'),
          (title: 'Rubrics', icon: Icons.rule, route: '/fypms/coordinator/rubrics'),
        ]),
        (label: 'Setup', items: [
          (title: 'Semesters & Courses', icon: Icons.date_range, route: '/fypms/coordinator/semesters'),
          (title: 'Expo Publications', icon: Icons.public, route: '/fypms/coordinator/expo'),
          (title: 'Audit Logs', icon: Icons.history, route: '/fypms/coordinator/audit'),
          // Admins run the exhibition too; the CMS links back here via "FYP Management".
          if (isAdmin) (title: 'Exhibition Admin', icon: Icons.storefront_outlined, route: '/admin'),
        ]),
      ],
    ));
  }

  // Drop sub-groups emptied by the role checks above.
  return [
    for (final s in sections)
      (title: s.title, icon: s.icon, groups: [for (final g in s.groups) if (g.items.isNotEmpty) g]),
  ];
}

/// The menu body shared by the desktop sidebar and the mobile drawer. With
/// one role it is a plain list with small group labels; with several, each
/// role is a collapsible section and the one holding the current page starts
/// open.
class _NavMenu extends StatefulWidget {
  const _NavMenu({required this.sections, required this.currentPath, required this.onOpen});

  final List<_NavSection> sections;
  final String currentPath;
  final void Function(String route) onOpen;

  @override
  State<_NavMenu> createState() => _NavMenuState();
}

class _NavMenuState extends State<_NavMenu> {
  late final Set<String> _open = {_activeSection() ?? widget.sections.firstOrNull?.title ?? ''};

  String? _activeSection() {
    for (final s in widget.sections) {
      for (final g in s.groups) {
        if (g.items.any((i) => _navRouteIsActive(i.route, widget.currentPath))) return s.title;
      }
    }
    return null;
  }

  @override
  void didUpdateWidget(_NavMenu old) {
    super.didUpdateWidget(old);
    // Navigating into a collapsed section (e.g. from a dashboard link) opens it.
    final active = _activeSection();
    if (active != null) _open.add(active);
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.sections;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceSm),
      children: sections.length == 1
          ? _groups(sections.single)
          : [
              for (final s in sections) ...[
                _sectionHeader(s),
                if (_open.contains(s.title)) ..._groups(s),
              ],
            ],
    );
  }

  Widget _sectionHeader(_NavSection s) {
    final open = _open.contains(s.title);
    final count = s.groups.fold<int>(0, (n, g) => n + g.items.length);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          key: Key('nav-section-${s.title}'),
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
          leading: Icon(s.icon, color: DesignSystem.secondaryContainer, size: 20),
          title: Text(
            s.title.toUpperCase(),
            style: DesignSystem.kicker.copyWith(color: Colors.white, fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!open) Text('$count', style: DesignSystem.kicker.copyWith(color: Colors.white54, fontSize: 11)),
              Icon(open ? Icons.expand_less : Icons.expand_more, color: Colors.white70, size: 20),
            ],
          ),
          onTap: () => setState(() => open ? _open.remove(s.title) : _open.add(s.title)),
        ),
      ),
    );
  }

  List<Widget> _groups(_NavSection s) => [
        for (final g in s.groups) ...[
          if (g.label != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 16, 4),
              child: Text(
                g.label!.toUpperCase(),
                style: DesignSystem.kicker.copyWith(color: DesignSystem.onPrimaryContainer, fontSize: 10.5),
              ),
            ),
          for (final i in g.items) _item(i),
        ],
      ];

  Widget _item(_NavItem i) {
    final active = _navRouteIsActive(i.route, widget.currentPath);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      decoration: BoxDecoration(
        color: active ? DesignSystem.secondary.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: DesignSystem.radiusLg,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          leading: Icon(i.icon, color: active ? DesignSystem.secondaryContainer : Colors.white70, size: 20),
          title: Text(
            i.title,
            style: DesignSystem.bodySm.copyWith(
              color: active ? Colors.white : Colors.white70,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: active,
          onTap: () => widget.onOpen(i.route),
          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
          dense: true,
          visualDensity: const VisualDensity(vertical: -2),
        ),
      ),
    );
  }
}

class _FypmsSidebar extends ConsumerWidget {
  final String currentPath;
  final bool isAdmin;
  final bool isCoordinator;
  final bool isStudent;
  final bool isSupervisor;
  final bool isExaminer;
  final bool isCsp;
  final bool isPu;

  const _FypmsSidebar({
    required this.currentPath,
    required this.isAdmin,
    required this.isCoordinator,
    required this.isStudent,
    required this.isSupervisor,
    required this.isExaminer,
    required this.isCsp,
    this.isPu = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = _navSections(
      showProjectPages: _studentHasProjectCourse(ref, isStudent),
      cspTitle: cspWorkspaceTitle(ref.watch(cspTaughtCoursesProvider)),
      teachesCsp600: ref.watch(cspTaughtCoursesProvider).contains('CSP600'),
      isAdmin: isAdmin,
      isCoordinator: isCoordinator,
      isStudent: isStudent,
      isSupervisor: isSupervisor,
      isExaminer: isExaminer,
      isCsp: isCsp,
      isPu: isPu,
    );

    return Container(
      width: 260.0,
      decoration: const BoxDecoration(
        color: DesignSystem.primaryContainer,
        border: Border(
          right: BorderSide(color: DesignSystem.surfaceContainer, width: 1.0),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: _NavMenu(
              sections: sections,
              currentPath: currentPath,
              onOpen: (route) => context.go(route),
            ),
          ),
          const Divider(color: Colors.white10),
          Material(
            type: MaterialType.transparency,
            child: ListTile(
              leading: const Icon(Icons.arrow_back, color: Colors.white70, size: 20),
              title: Text(
                'Exhibition Site',
                style: DesignSystem.bodySm.copyWith(color: Colors.white70),
              ),
              onTap: () => openExhibitionSite(context, ref),
              shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
              dense: true,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceMd),
        ],
      ),
    );
  }
}

class _FypmsDrawer extends ConsumerWidget {
  final String currentPath;
  final bool isAdmin;
  final bool isCoordinator;
  final bool isStudent;
  final bool isSupervisor;
  final bool isExaminer;
  final bool isCsp;
  final bool isPu;
  final VoidCallback onSignOut;

  const _FypmsDrawer({
    required this.onSignOut,
    required this.currentPath,
    required this.isAdmin,
    required this.isCoordinator,
    required this.isStudent,
    required this.isSupervisor,
    required this.isExaminer,
    required this.isCsp,
    this.isPu = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = _navSections(
      showProjectPages: _studentHasProjectCourse(ref, isStudent),
      cspTitle: cspWorkspaceTitle(ref.watch(cspTaughtCoursesProvider)),
      teachesCsp600: ref.watch(cspTaughtCoursesProvider).contains('CSP600'),
      isAdmin: isAdmin,
      isCoordinator: isCoordinator,
      isStudent: isStudent,
      isSupervisor: isSupervisor,
      isExaminer: isExaminer,
      isCsp: isCsp,
      isPu: isPu,
    );

    return Drawer(
      backgroundColor: DesignSystem.primaryContainer,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignSystem.spaceMd),
              alignment: Alignment.centerLeft,
              child: const BrandMark(color: Colors.white, accent: DesignSystem.secondaryContainer, subtitle: 'WORKSPACE · CSP600 · CSP650'),
            ),
            const Divider(color: Colors.white10),
            Expanded(
              child: _NavMenu(
                sections: sections,
                currentPath: currentPath,
                onOpen: (route) {
                  Navigator.pop(context);
                  context.go(route);
                },
              ),
            ),
            const Divider(color: Colors.white10),
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.white70, size: 20),
                title: Text('Sign Out', style: DesignSystem.bodySm.copyWith(color: Colors.white70)),
                onTap: () {
                  Navigator.pop(context);
                  onSignOut();
                },
                shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                dense: true,
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                leading: const Icon(Icons.arrow_back, color: Colors.white70, size: 20),
                title: Text(
                  'Exhibition Site',
                  style: DesignSystem.bodySm.copyWith(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.pop(context);
                  openExhibitionSite(context, ref);
                },
                shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                dense: true,
              ),
            ),
            const SizedBox(height: DesignSystem.spaceMd),
          ],
        ),
      ),
    );
  }
}

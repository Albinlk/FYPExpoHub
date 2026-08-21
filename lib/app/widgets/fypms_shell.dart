import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/supabase/supabase_client_provider.dart';
import '../../core/state/fypms_state_providers.dart';
import '../theme/theme.dart';

class FypmsShell extends ConsumerWidget {
  final Widget child;

  const FypmsShell({super.key, required this.child});

  void _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(supabaseClientProvider).auth.signOut();
    ref.invalidate(currentAuthUserProvider);
    ref.invalidate(fypmsCurrentRolesProvider);
    if (context.mounted) {
      context.go('/admin/sign-in');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final location = GoRouterState.of(context).uri.toString();
    final user = ref.watch(currentAuthUserProvider);
    final roles = ref.watch(fypmsCurrentRolesProvider);
    final isAdmin = ref.watch(isFypAdminProvider);
    final isCoordinator = ref.watch(isFypCoordinatorProvider);
    final isStudent = ref.watch(isFypStudentProvider);
    final isSupervisor = ref.watch(isFypSupervisorProvider);
    final isExaminer = ref.watch(isFypExaminerProvider);
    final isCsp = ref.watch(isCspLecturerProvider);

    final hasAccess =
        roles.value?.isNotEmpty == true && (isAdmin || isCoordinator || isStudent || isSupervisor || isExaminer || isCsp);

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

    final userEmail = user?.email ?? 'FYPMS User';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'FYP Management System',
              style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (isDesktop)
              Row(
                children: [
                  const Icon(Icons.account_circle, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    userEmail,
                    style: DesignSystem.bodySm.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 24),
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
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _logout(context, ref),
                ),
              ]
            : null,
      ),
      drawer: !isDesktop ? _FypmsDrawer(currentPath: location, isAdmin: isAdmin, isCoordinator: isCoordinator, isStudent: isStudent, isSupervisor: isSupervisor, isExaminer: isExaminer, isCsp: isCsp) : null,
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

List<({String title, IconData icon, String route})> _navItems({
  required bool isAdmin,
  required bool isCoordinator,
  required bool isStudent,
  required bool isSupervisor,
  required bool isExaminer,
  required bool isCsp,
}) {
  final items = <({String title, IconData icon, String route})>[];

  if (isStudent) {
    items.addAll([
      (title: 'Student Dashboard', icon: Icons.dashboard, route: '/fypms/student'),
      (title: 'My Records', icon: Icons.folder_open, route: '/fypms/student/records'),
      (title: 'Supervision', icon: Icons.supervisor_account, route: '/fypms/student/supervision'),
      (title: 'Progress Logs', icon: Icons.timeline, route: '/fypms/student/progress'),
      (title: 'Forms', icon: Icons.description, route: '/fypms/student/forms'),
      (title: 'Lean Canvas', icon: Icons.grid_view, route: '/fypms/student/lean-canvas'),
      (title: 'Reports', icon: Icons.upload_file, route: '/fypms/student/reports'),
      (title: 'Deliverables', icon: Icons.checklist, route: '/fypms/student/deliverables'),
      (title: 'Milestones', icon: Icons.flag, route: '/fypms/student/milestones'),
      (title: 'Corrections', icon: Icons.fact_check, route: '/fypms/student/corrections'),
      (title: 'Presentations', icon: Icons.event, route: '/fypms/student/presentations'),
      (title: 'Marks', icon: Icons.scoreboard, route: '/fypms/student/marks'),
    ]);
  }

  if (isSupervisor) {
    items.addAll([
      (title: 'Supervisor Dashboard', icon: Icons.dashboard, route: '/fypms/supervisor'),
      (title: 'Assigned Records', icon: Icons.folder_open, route: '/fypms/supervisor/records'),
      (title: 'Progress Reviews', icon: Icons.timeline, route: '/fypms/supervisor/progress'),
      (title: 'Evaluations', icon: Icons.description, route: '/fypms/supervisor/evaluations'),
      (title: 'Corrections', icon: Icons.fact_check, route: '/fypms/supervisor/corrections'),
      (title: 'Milestones', icon: Icons.flag, route: '/fypms/supervisor/milestones'),
    ]);
  }

  if (isExaminer) {
    items.addAll([
      (title: 'Examiner Dashboard', icon: Icons.dashboard, route: '/fypms/examiner'),
      (title: 'Assigned Records', icon: Icons.folder_open, route: '/fypms/examiner/records'),
      (title: 'Evaluations', icon: Icons.description, route: '/fypms/examiner/evaluations'),
      (title: 'Corrections', icon: Icons.fact_check, route: '/fypms/examiner/corrections'),
    ]);
  }

  if (isCsp) {
    items.addAll([
      (title: 'CSP Dashboard', icon: Icons.dashboard, route: '/fypms/csp'),
      (title: 'Supervision Requests', icon: Icons.mail, route: '/fypms/csp/requests'),
      (title: 'Offerings', icon: Icons.school, route: '/fypms/csp/offerings'),
      (title: 'Milestones', icon: Icons.flag, route: '/fypms/csp/milestones'),
      (title: 'Presentations', icon: Icons.event, route: '/fypms/csp/presentations'),
      (title: 'Marks', icon: Icons.scoreboard, route: '/fypms/csp/marks'),
    ]);
  }

  if (isCoordinator || isAdmin) {
    items.addAll([
      (title: 'Coordinator Dashboard', icon: Icons.dashboard, route: '/fypms/coordinator'),
      (title: 'All Records', icon: Icons.folder_open, route: '/fypms/coordinator/records'),
      (title: 'Assignments', icon: Icons.assignment_ind, route: '/fypms/coordinator/assignments'),
      (title: 'Supervision Requests', icon: Icons.mail, route: '/fypms/coordinator/requests'),
      (title: 'Presentations', icon: Icons.event, route: '/fypms/coordinator/presentations'),
      (title: 'Expo Publications', icon: Icons.public, route: '/fypms/coordinator/expo'),
      (title: 'Audit Logs', icon: Icons.history, route: '/fypms/coordinator/audit'),
    ]);
  }

  return items;
}

class _FypmsSidebar extends StatelessWidget {
  final String currentPath;
  final bool isAdmin;
  final bool isCoordinator;
  final bool isStudent;
  final bool isSupervisor;
  final bool isExaminer;
  final bool isCsp;

  const _FypmsSidebar({
    required this.currentPath,
    required this.isAdmin,
    required this.isCoordinator,
    required this.isStudent,
    required this.isSupervisor,
    required this.isExaminer,
    required this.isCsp,
  });

  @override
  Widget build(BuildContext context) {
    final items = _navItems(
      isAdmin: isAdmin,
      isCoordinator: isCoordinator,
      isStudent: isStudent,
      isSupervisor: isSupervisor,
      isExaminer: isExaminer,
      isCsp: isCsp,
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
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceMd),
              children: [
                for (final item in items)
                  _buildSidebarItem(context, item.title, item.icon, item.route),
              ],
            ),
          ),
          const Divider(color: Colors.white10),
          Material(
            type: MaterialType.transparency,
            child: ListTile(
              leading: const Icon(Icons.arrow_back, color: Colors.white70, size: 20),
              title: Text(
                'Back to Public Portal',
                style: DesignSystem.bodySm.copyWith(color: Colors.white70),
              ),
              onTap: () => context.go('/'),
              shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
              dense: true,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceMd),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, String title, IconData icon, String route) {
    final active = (route == '/fypms/student' && currentPath == '/fypms/student') ||
        (route != '/fypms/student' && currentPath.startsWith(route));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: active ? DesignSystem.secondary.withOpacity(0.15) : Colors.transparent,
        borderRadius: DesignSystem.radiusLg,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          leading: Icon(icon, color: active ? DesignSystem.secondaryContainer : Colors.white70, size: 20),
          title: Text(
            title,
            style: DesignSystem.bodySm.copyWith(
              color: active ? Colors.white : Colors.white70,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () => context.go(route),
          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
          dense: true,
        ),
      ),
    );
  }
}

class _FypmsDrawer extends StatelessWidget {
  final String currentPath;
  final bool isAdmin;
  final bool isCoordinator;
  final bool isStudent;
  final bool isSupervisor;
  final bool isExaminer;
  final bool isCsp;

  const _FypmsDrawer({
    required this.currentPath,
    required this.isAdmin,
    required this.isCoordinator,
    required this.isStudent,
    required this.isSupervisor,
    required this.isExaminer,
    required this.isCsp,
  });

  @override
  Widget build(BuildContext context) {
    final items = _navItems(
      isAdmin: isAdmin,
      isCoordinator: isCoordinator,
      isStudent: isStudent,
      isSupervisor: isSupervisor,
      isExaminer: isExaminer,
      isCsp: isCsp,
    );

    return Drawer(
      backgroundColor: DesignSystem.primaryContainer,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignSystem.spaceMd),
              alignment: Alignment.centerLeft,
              child: Text(
                'FYP Management System',
                style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(color: Colors.white10),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final item in items)
                    _buildDrawerItem(context, item.title, item.icon, item.route),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                leading: const Icon(Icons.arrow_back, color: Colors.white70, size: 20),
                title: Text(
                  'Back to Public Portal',
                  style: DesignSystem.bodySm.copyWith(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/');
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

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, String route) {
    final active = (route == '/fypms/student' && currentPath == '/fypms/student') ||
        (route != '/fypms/student' && currentPath.startsWith(route));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: active ? DesignSystem.secondary.withOpacity(0.15) : Colors.transparent,
        borderRadius: DesignSystem.radiusLg,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          leading: Icon(icon, color: active ? DesignSystem.secondaryContainer : Colors.white70, size: 20),
          title: Text(
            title,
            style: DesignSystem.bodySm.copyWith(
              color: active ? Colors.white : Colors.white70,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            context.go(route);
          },
          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
          dense: true,
        ),
      ),
    );
  }
}
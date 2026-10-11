import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/supabase/supabase_client_provider.dart';
import '../../core/widgets/scholar_lab.dart';
import '../theme/theme.dart';
import 'feedback_form_widget.dart';
import '../../features/admin_auth/presentation/widgets/my_account_dialog.dart';

/// Back to the portal home in the same tab (it used to open the public site
/// as an external link).
void _goToPublicPortal(BuildContext context) => GoRouter.of(context).go('/');


typedef _AdminNavItem = ({String title, IconData icon, String route});

/// The exhibition admin menu, grouped so the 17 links read as a few short
/// lists instead of one long one.
const List<({String? label, List<_AdminNavItem> items})> _adminNavGroups = [
  (label: null, items: [
    (title: 'Overview Dashboard', icon: Icons.dashboard, route: '/admin'),
  ]),
  (label: 'Exhibition', items: [
    (title: 'Event Information', icon: Icons.info_outline, route: '/admin/event'),
    (title: 'Schedule Management', icon: Icons.schedule, route: '/admin/schedule'),
    (title: 'Announcements', icon: Icons.campaign, route: '/admin/announcements'),
    (title: 'Award Winners', icon: Icons.emoji_events, route: '/admin/awards'),
  ]),
  (label: 'Projects & booths', items: [
    (title: 'Project Catalogue', icon: Icons.folder_open, route: '/admin/projects'),
    (title: 'Booth Management', icon: Icons.map, route: '/admin/booths'),
    (title: 'Import Master File', icon: Icons.file_upload, route: '/admin/imports'),
  ]),
  (label: 'Lecturers & visits', items: [
    (title: 'Lecturer Management', icon: Icons.school, route: '/admin/lecturers'),
    (title: 'Lecturer Assignments', icon: Icons.assignment_ind, route: '/admin/assignments'),
    (title: 'Booth Visits', icon: Icons.visibility, route: '/admin/visits'),
    (title: 'My Visits (Lecturer)', icon: Icons.person_pin, route: '/lecturer/visits'),
  ]),
  (label: 'System', items: [
    (title: 'Users & Roles', icon: Icons.manage_accounts, route: '/fypms/coordinator/users'),
    (title: 'Feedback', icon: Icons.feedback_outlined, route: '/admin/feedback'),
    (title: 'Audit Log', icon: Icons.history, route: '/admin/audit'),
    (title: 'Settings', icon: Icons.settings, route: '/admin/settings'),
    (title: 'FYP Management', icon: Icons.school, route: '/fypms/coordinator'),
  ]),
];

Widget _adminGroupLabel(String label) => Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: DesignSystem.kicker.copyWith(color: DesignSystem.onPrimaryContainer, fontSize: 10.5),
      ),
    );

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  void _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(supabaseClientProvider).auth.signOut();
    ref.invalidate(currentAuthUserProvider);
    ref.invalidate(currentProfileProvider);
    ref.invalidate(isAdminProvider);
    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    final location = GoRouterState.of(context).uri.toString();

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
                  child: BrandMark(color: Colors.white, accent: DesignSystem.secondaryContainer, subtitle: 'EXHIBITION ADMIN'),
                ),
              ),
            ),
            if (isDesktop)
              Row(
                children: [
                  const MyAccountButton(),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white70),
                    onPressed: () => _logout(context, ref),
                    tooltip: 'Sign Out (Logout)',
                  ),
                ],
              ),
          ],
        ),
        actions: !isDesktop
            ? [
                const MyAccountButton(compact: true),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _logout(context, ref),
                  tooltip: 'Sign Out (Logout)',
                ),
              ]
            : null,
      ),
      drawer: !isDesktop
          ? _AdminDrawer(
              currentPath: location,
              onSendFeedback: () => FeedbackFormWidget.show(context, ref),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop) _AdminSidebar(currentPath: location),
          Expanded(
            child: Container(
              color: DesignSystem.background,
              child: Stack(
                children: [
                  child,
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0, right: 24.0),
                      child: isDesktop
                          ? FloatingActionButton.extended(
                              onPressed: () => FeedbackFormWidget.show(context, ref),
                              icon: const Icon(Icons.feedback_outlined, size: 20),
                              label: const Text('Feedback'),
                              backgroundColor: DesignSystem.secondary,
                              foregroundColor: Colors.white,
                            )
                          // On phones the button would cover Save buttons and table
                          // rows, so Send Feedback lives in the menu instead.
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  final String currentPath;

  const _AdminSidebar({required this.currentPath});

  @override
  Widget build(BuildContext context) {
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
                for (final g in _adminNavGroups) ...[
                  if (g.label != null) _adminGroupLabel(g.label!),
                  for (final i in g.items) _buildSidebarItem(context, i.title, i.icon, i.route),
                ],
              ],
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
              onTap: () => _goToPublicPortal(context),
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
    final active = (route == '/admin' && currentPath == '/admin') || (route != '/admin' && currentPath.startsWith(route));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: active ? DesignSystem.secondary.withValues(alpha: 0.15) : Colors.transparent,
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
          selected: active,
          onTap: () => context.go(route),
          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
          dense: true,
        ),
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final String currentPath;
  final VoidCallback onSendFeedback;

  const _AdminDrawer({required this.currentPath, required this.onSendFeedback});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: DesignSystem.primaryContainer,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignSystem.spaceMd),
              alignment: Alignment.centerLeft,
              child: const BrandMark(color: Colors.white, accent: DesignSystem.secondaryContainer, subtitle: 'EXHIBITION ADMIN'),
            ),
            const Divider(color: Colors.white10),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final g in _adminNavGroups) ...[
                    if (g.label != null) _adminGroupLabel(g.label!),
                    for (final i in g.items) _buildDrawerItem(context, i.title, i.icon, i.route),
                  ],
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                leading: const Icon(Icons.rate_review_outlined, color: Colors.white70, size: 20),
                title: Text('Send Feedback', style: DesignSystem.bodySm.copyWith(color: Colors.white70)),
                onTap: () {
                  Navigator.pop(context);
                  onSendFeedback();
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
                  final router = GoRouter.of(context);
                  Navigator.pop(context);
                  router.go('/');
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
    final active = (route == '/admin' && currentPath == '/admin') || (route != '/admin' && currentPath.startsWith(route));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: active ? DesignSystem.secondary.withValues(alpha: 0.15) : Colors.transparent,
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
          selected: active,
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

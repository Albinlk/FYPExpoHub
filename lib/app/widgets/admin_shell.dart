import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../core/supabase/supabase_client_provider.dart';
import '../theme/theme.dart';
import 'feedback_form_widget.dart';

void _goToPublicPortal() {
  launchUrlString('https://fskmjasinfypexhibition.site/');
}

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
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final location = GoRouterState.of(context).uri.toString();
    final user = ref.watch(currentAuthUserProvider);
    final userEmail = user?.email ?? 'Admin';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'FYP Expo Hub CMS',
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
                    tooltip: 'Sign Out (Logout)',
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
      drawer: !isDesktop ? _AdminDrawer(currentPath: location) : null,
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
                          : FloatingActionButton(
                              onPressed: () => FeedbackFormWidget.show(context, ref),
                              backgroundColor: DesignSystem.secondary,
                              foregroundColor: Colors.white,
                              child: const Icon(Icons.feedback_outlined, size: 24),
                            ),
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
                _buildSidebarItem(context, 'Overview Dashboard', Icons.dashboard, '/admin'),
                _buildSidebarItem(context, 'Event Information', Icons.info_outline, '/admin/event'),
                _buildSidebarItem(context, 'Schedule Management', Icons.schedule, '/admin/schedule'),
                _buildSidebarItem(context, 'Project Catalogue', Icons.folder_open, '/admin/projects'),
                _buildSidebarItem(context, 'Booth Management', Icons.map, '/admin/booths'),
                _buildSidebarItem(context, 'Lecturer Management', Icons.school, '/admin/lecturers'),
                _buildSidebarItem(context, 'Announcements', Icons.campaign, '/admin/announcements'),
                _buildSidebarItem(context, 'Feedback', Icons.feedback_outlined, '/admin/feedback'),
                _buildSidebarItem(context, 'Student Visits', Icons.visibility, '/admin/visits'),
                _buildSidebarItem(context, 'My Visits (Lecturer)', Icons.person_pin, '/lecturer/visits'),
                _buildSidebarItem(context, 'Award Winners', Icons.emoji_events, '/admin/awards'),
                _buildSidebarItem(context, 'Import Master File', Icons.file_upload, '/admin/imports'),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Divider(color: Colors.white24),
                ),
                _buildSidebarItem(context, 'FYP Management', Icons.school, '/fypms/coordinator'),
                _buildSidebarItem(context, 'Settings', Icons.settings, '/admin/settings'),
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
              onTap: _goToPublicPortal,
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

class _AdminDrawer extends StatelessWidget {
  final String currentPath;

  const _AdminDrawer({required this.currentPath});

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
              child: Text(
                'FYP Expo Hub CMS',
                style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(color: Colors.white10),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(context, 'Overview Dashboard', Icons.dashboard, '/admin'),
                  _buildDrawerItem(context, 'Event Information', Icons.info_outline, '/admin/event'),
                  _buildDrawerItem(context, 'Schedule Management', Icons.schedule, '/admin/schedule'),
                  _buildDrawerItem(context, 'Project Catalogue', Icons.folder_open, '/admin/projects'),
                  _buildDrawerItem(context, 'Booth Management', Icons.map, '/admin/booths'),
                  _buildDrawerItem(context, 'Lecturer Management', Icons.school, '/admin/lecturers'),
                  _buildDrawerItem(context, 'Announcements', Icons.campaign, '/admin/announcements'),
                  _buildDrawerItem(context, 'Feedback', Icons.feedback_outlined, '/admin/feedback'),
                  _buildDrawerItem(context, 'Student Visits', Icons.visibility, '/admin/visits'),
                  _buildDrawerItem(context, 'My Visits (Lecturer)', Icons.person_pin, '/lecturer/visits'),
                  _buildDrawerItem(context, 'Award Winners', Icons.emoji_events, '/admin/awards'),
                  _buildDrawerItem(context, 'Import Master File', Icons.file_upload, '/admin/imports'),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Divider(color: Colors.white24),
                  ),
                  _buildDrawerItem(context, 'FYP Management', Icons.school, '/fypms/coordinator'),
                  _buildDrawerItem(context, 'Settings', Icons.settings, '/admin/settings'),
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
                  _goToPublicPortal();
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

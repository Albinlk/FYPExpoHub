import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/firebase/firebase_providers.dart';
import '../theme/theme.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  void _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(firebaseAuthProvider).signOut();
    if (context.mounted) {
      context.go('/admin/sign-in');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final location = GoRouterState.of(context).uri.toString();
    final authState = ref.watch(authStateChangesProvider);
    final userEmail = authState.value?.email ?? 'Admin';

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
                    tooltip: 'Log Keluar (Logout)',
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
              child: child,
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
                _buildSidebarItem(context, 'Maklumat Event', Icons.info_outline, '/admin/event'),
                _buildSidebarItem(context, 'Pengurusan Tentatif', Icons.schedule, '/admin/schedule'),
                _buildSidebarItem(context, 'Projek Katalog', Icons.folder_open, '/admin/projects'),
                _buildSidebarItem(context, 'Pengurusan Booth', Icons.map, '/admin/booths'),
                _buildSidebarItem(context, 'Pengumuman', Icons.campaign, '/admin/announcements'),
                _buildSidebarItem(context, 'Pemenang Anugerah', Icons.emoji_events, '/admin/awards'),
                _buildSidebarItem(context, 'Import Master File', Icons.file_upload, '/admin/imports'),
                _buildSidebarItem(context, 'Tetapan (Settings)', Icons.settings, '/admin/settings'),
              ],
            ),
          ),
          const Divider(color: Colors.white10),
          _buildSidebarItem(context, 'Kembali ke Portal Awam', Icons.arrow_back, '/'),
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
                  _buildDrawerItem(context, 'Maklumat Event', Icons.info_outline, '/admin/event'),
                  _buildDrawerItem(context, 'Pengurusan Tentatif', Icons.schedule, '/admin/schedule'),
                  _buildDrawerItem(context, 'Projek Katalog', Icons.folder_open, '/admin/projects'),
                  _buildDrawerItem(context, 'Pengurusan Booth', Icons.map, '/admin/booths'),
                  _buildDrawerItem(context, 'Pengumuman', Icons.campaign, '/admin/announcements'),
                  _buildDrawerItem(context, 'Pemenang Anugerah', Icons.emoji_events, '/admin/awards'),
                  _buildDrawerItem(context, 'Import Master File', Icons.file_upload, '/admin/imports'),
                  _buildDrawerItem(context, 'Tetapan (Settings)', Icons.settings, '/admin/settings'),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            _buildDrawerItem(context, 'Kembali ke Portal Awam', Icons.arrow_back, '/'),
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
          Navigator.pop(context); // close drawer
          context.go(route);
        },
        shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
        dense: true,
      ),
    );
  }
}

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme.dart';

void _openAdminPortal() {
  final location = globalContext['location'] as JSObject;
  location['href'] = 'https://admin.fskmjasinfypexhibition.site/admin/sign-in'.toJS;
}

class PublicShell extends StatelessWidget {
  final Widget child;

  const PublicShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      appBar: isDesktop
          ? PreferredSize(
              preferredSize: const Size.fromHeight(64.0),
              child: _DesktopNavBar(currentPath: location),
            )
          : null,
      body: child,
      bottomNavigationBar: !isDesktop ? _MobileBottomNavBar(currentPath: location) : null,
    );
  }
}

class _DesktopNavBar extends StatelessWidget {
  final String currentPath;

  const _DesktopNavBar({required this.currentPath});

  bool _isActive(String path) {
    if (path == '/' && currentPath == '/') return true;
    if (path != '/' && currentPath.startsWith(path)) return true;
    return false;
  }

  void _navigateTo(BuildContext context, String route) {
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.0,
      decoration: const BoxDecoration(
        color: DesignSystem.background,
        border: Border(
          bottom: BorderSide(color: DesignSystem.surfaceContainer, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.marginDesktop),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: App Logo
          GestureDetector(
            onTap: () => _navigateTo(context, '/'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                'FYP Expo Hub',
                style: DesignSystem.h3.copyWith(
                  color: DesignSystem.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Center: Links
          Row(
            children: [
              _buildNavLink(context, 'Home', '/'),
              const SizedBox(width: DesignSystem.spaceLg),
              _buildNavLink(context, 'Schedule', '/schedule'),
              const SizedBox(width: DesignSystem.spaceLg),
              _buildNavLink(context, 'Projects', '/projects'),
              const SizedBox(width: DesignSystem.spaceLg),
              _buildNavLink(context, 'Booths', '/booths'),
              const SizedBox(width: DesignSystem.spaceLg),
              _buildNavLink(context, 'Announcements', '/announcements'),
              const SizedBox(width: DesignSystem.spaceLg),
              _buildNavLink(context, 'Awards', '/awards'),
              const SizedBox(width: DesignSystem.spaceLg),
              _buildNavLink(context, 'Lecturer Portal', '/lecturer'),
            ],
          ),

          // Right: Action Button
          ElevatedButton(
            onPressed: _openAdminPortal,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primary,
              foregroundColor: DesignSystem.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spaceLg,
                vertical: DesignSystem.spaceSm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: DesignSystem.radiusFull,
              ),
            ),
            child: Text(
              'Admin CMS',
              style: DesignSystem.button.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(BuildContext context, String title, String route) {
    final active = _isActive(route);
    return InkWell(
      onTap: () => _navigateTo(context, route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: DesignSystem.bodyMd.copyWith(
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? DesignSystem.primary : DesignSystem.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 24,
            color: active ? DesignSystem.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _MobileBottomNavBar extends StatelessWidget {
  final String currentPath;

  const _MobileBottomNavBar({required this.currentPath});

  int _getSelectedIndex() {
    if (currentPath == '/') return 0;
    if (currentPath.startsWith('/projects')) return 1;
    if (currentPath.startsWith('/schedule')) return 2;
    if (currentPath.startsWith('/lecturer')) return 3;
    return 4;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/projects');
        break;
      case 2:
        context.go('/schedule');
        break;
      case 3:
        context.go('/lecturer');
        break;
      case 4:
        _showMobileMenu(context);
        break;
    }
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DesignSystem.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuItem(context, 'Schedule', Icons.event_note, '/schedule'),
                _buildMenuItem(context, 'Announcements', Icons.campaign, '/announcements'),
                _buildMenuItem(context, 'Award Winners', Icons.emoji_events, '/awards'),
                _buildMenuItem(context, 'Lecturer Portal', Icons.person_search, '/lecturer'),
                _buildMenuItem(context, 'Exhibition Info', Icons.info, '/info'),
                _buildMenuItem(context, 'Frequently Asked Questions', Icons.help_outline, '/faq'),
                _buildMenuItem(context, 'Privacy Policy', Icons.privacy_tip_outlined, '/privacy'),
                const Divider(),
                _buildMenuItemExternal(context, 'Admin CMS Portal', Icons.admin_panel_settings),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon, color: DesignSystem.primary),
      title: Text(title, style: DesignSystem.bodyMd),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }

  Widget _buildMenuItemExternal(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: DesignSystem.primary),
      title: Text(title, style: DesignSystem.bodyMd),
      onTap: () {
        Navigator.pop(context);
        _openAdminPortal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex();

    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onItemTapped(context, index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: DesignSystem.secondaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: DesignSystem.onSecondaryContainer),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            selectedIcon: Icon(Icons.folder_open, color: DesignSystem.onSecondaryContainer),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note, color: DesignSystem.onSecondaryContainer),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_search_outlined),
            selectedIcon: Icon(Icons.person_search, color: DesignSystem.onSecondaryContainer),
            label: 'Lecturer',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}

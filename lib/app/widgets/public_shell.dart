import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../core/state/state_providers.dart';
import '../theme/theme.dart';
import 'feedback_form_widget.dart';

void _openAdminPortal() {
  launchUrlString('https://admin.fskmjasinfypexhibition.site/admin/sign-in');
}

class PublicShell extends ConsumerWidget {
  final Widget child;

  const PublicShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // Only rebuild the shell when the sign-in *state* flips, not on every
    // lecturer/auth/Firestore emit (avoids rebuilding the whole nav).
    final lecturerSignedIn = ref.watch(lecturerAuthProvider.select((l) => l != null));

    return Scaffold(
      appBar: isDesktop
          ? PreferredSize(
              preferredSize: const Size.fromHeight(64.0),
              child: _DesktopNavBar(currentPath: location, lecturerSignedIn: lecturerSignedIn),
            )
          : null,
      body: Stack(
        children: [
          child,
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isDesktop ? 24.0 : 80.0 + bottomInset,
                right: 24.0,
              ),
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
      bottomNavigationBar: !isDesktop ? _MobileBottomNavBar(currentPath: location, lecturerSignedIn: lecturerSignedIn) : null,
    );
  }
}

class _DesktopNavBar extends StatelessWidget {
  final String currentPath;
  final bool lecturerSignedIn;

  const _DesktopNavBar({required this.currentPath, required this.lecturerSignedIn});

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
              _buildNavLink(context, 'Booths', '/booths'),
              const SizedBox(width: DesignSystem.spaceLg),
               _buildNavLink(context, 'Projects', '/projects'),
               const SizedBox(width: DesignSystem.spaceLg),
               _buildNavLink(context, 'Project Guide', '/projects/junior-guide'),
               const SizedBox(width: DesignSystem.spaceLg),
              _buildNavLink(context, 'Announcements', '/announcements'),
              const SizedBox(width: DesignSystem.spaceLg),
              _buildNavLink(context, 'Awards', '/awards'),
              const SizedBox(width: DesignSystem.spaceLg),
              _buildNavLink(context, 'Lecturer Portal', '/lecturer'),
              if (lecturerSignedIn) ...[
                const SizedBox(width: DesignSystem.spaceLg),
                _buildNavLink(context, 'My Visits', '/lecturer/visits'),
              ],
            ],
          ),

          // Right: Login Button
          if (!lecturerSignedIn)
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
                'Sign In',
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
  final bool lecturerSignedIn;

  const _MobileBottomNavBar({required this.currentPath, required this.lecturerSignedIn});

  int _getSelectedIndex() {
    if (currentPath == '/') return 0;
    if (currentPath.startsWith('/booths')) return 1;
    if (currentPath.startsWith('/projects/junior-guide')) return 2;
    if (currentPath.startsWith('/lecturer')) return 3;
    return 4;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/booths');
        break;
      case 2:
        context.go('/projects/junior-guide');
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
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      backgroundColor: DesignSystem.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!lecturerSignedIn)
                  _buildMenuItemExternal(context, 'Sign In', Icons.login),
                if (!lecturerSignedIn) const Divider(),
                 _buildMenuItem(context, 'Booths', Icons.location_pin, '/booths'),
                 _buildMenuItem(context, 'Schedule', Icons.event_note, '/schedule'),
                 _buildMenuItem(context, 'Project Guide', Icons.school, '/projects/junior-guide'),
                 _buildMenuItem(context, 'Announcements', Icons.campaign, '/announcements'),
                _buildMenuItem(context, 'Award Winners', Icons.emoji_events, '/awards'),
                if (lecturerSignedIn)
                  _buildMenuItem(context, 'My Visits', Icons.visibility, '/lecturer/visits'),

                _buildMenuItem(context, 'Exhibition Info', Icons.info, '/info'),
                _buildMenuItem(context, 'Frequently Asked Questions', Icons.help_outline, '/faq'),
                _buildMenuItem(context, 'Privacy Policy', Icons.privacy_tip_outlined, '/privacy'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String route) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: Icon(icon, color: DesignSystem.primary),
        title: Text(title, style: DesignSystem.bodyMd),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
      ),
    );
  }

  Widget _buildMenuItemExternal(BuildContext context, String title, IconData icon) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: Icon(icon, color: DesignSystem.primary),
        title: Text(title, style: DesignSystem.bodyMd),
        onTap: () {
          Navigator.pop(context);
          _openAdminPortal();
        },
      ),
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        // On very narrow screens (<360px) the M3 label padding makes even
        // short words wrap; scale label text down slightly so every label
        // stays on one centered line.
        child: Builder(
          builder: (scaleContext) {
            final narrow =
                MediaQuery.sizeOf(scaleContext).width < 360;
            final parent = MediaQuery.of(scaleContext);
            final bar = NavigationBar(
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
                  icon: Icon(Icons.location_on_outlined),
                  selectedIcon: Icon(Icons.location_on, color: DesignSystem.onSecondaryContainer),
                  label: 'Map',
                ),
                NavigationDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school, color: DesignSystem.onSecondaryContainer),
                  label: 'Guide',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: DesignSystem.onSecondaryContainer),
                  label: 'Visits',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu),
                  label: 'Menu',
                ),
              ],
            );
            if (!narrow) return bar;
            // Very narrow screens: icons only (Material pattern) — labels
            // would wrap to clipped multi-line text at this slot width.
            return MediaQuery(
              data: parent,
              child: NavigationBar(
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) => _onItemTapped(context, index),
                backgroundColor: Colors.transparent,
                elevation: 0,
                height: 64,
                indicatorColor: DesignSystem.secondaryContainer,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home, color: DesignSystem.onSecondaryContainer),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.location_on_outlined),
                    selectedIcon: Icon(Icons.location_on, color: DesignSystem.onSecondaryContainer),
                    label: 'Map',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.school_outlined),
                    selectedIcon: Icon(Icons.school, color: DesignSystem.onSecondaryContainer),
                    label: 'Guide',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person, color: DesignSystem.onSecondaryContainer),
                    label: 'Visits',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.menu),
                    label: 'Menu',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

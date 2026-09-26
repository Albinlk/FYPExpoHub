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
    // Only rebuild the shell when the sign-in *state* flips, not on every
    // lecturer/auth/Firestore emit (avoids rebuilding the whole nav).
    final lecturerSignedIn = ref.watch(
      lecturerAuthProvider.select((l) => l != null),
    );

    return Scaffold(
      appBar: isDesktop
          ? PreferredSize(
              preferredSize: const Size.fromHeight(64.0),
              child: _DesktopNavBar(
                currentPath: location,
                lecturerSignedIn: lecturerSignedIn,
              ),
            )
          : null,
      body: Stack(
        children: [
          child,
          // Desktop only: on mobile the FAB covered buttons and card text,
          // so Feedback lives in the bottom-nav Menu sheet instead.
          if (isDesktop)
            Positioned(
              right: 24,
              bottom: 24,
              child: FloatingActionButton.extended(
                onPressed: () => FeedbackFormWidget.show(context, ref),
                icon: const Icon(Icons.feedback_outlined, size: 20),
                label: const Text('Feedback'),
                backgroundColor: DesignSystem.secondary,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? _MobileBottomNavBar(
              currentPath: location,
              lecturerSignedIn: lecturerSignedIn,
              onFeedback: () => FeedbackFormWidget.show(context, ref),
            )
          : null,
    );
  }
}

class _DesktopNavBar extends StatelessWidget {
  final String currentPath;
  final bool lecturerSignedIn;

  const _DesktopNavBar({
    required this.currentPath,
    required this.lecturerSignedIn,
  });

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
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.marginDesktop,
      ),
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

          // Center: Links. Flexible + horizontal scroll so the row never runs
          // into the logo on narrow desktop widths (~800 px).
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spaceMd),
              child: Row(
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
              const SizedBox(width: DesignSystem.spaceMd),
              // Info, FAQ and Privacy were only reachable from the mobile menu.
              PopupMenuButton<String>(
                tooltip: 'More',
                onSelected: (route) => _navigateTo(context, route),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: '/info', child: Text('Exhibition Info')),
                  PopupMenuItem(value: '/faq', child: Text('FAQ')),
                  PopupMenuItem(value: '/privacy', child: Text('Privacy Policy')),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'More',
                      style: DesignSystem.bodyMd.copyWith(
                        color: _isActive('/info') || _isActive('/faq') || _isActive('/privacy')
                            ? DesignSystem.primary
                            : DesignSystem.onSurfaceVariant,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: DesignSystem.onSurfaceVariant),
                  ],
                ),
              ),
            ],
          ),
            ),
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
              color: active
                  ? DesignSystem.primary
                  : DesignSystem.onSurfaceVariant,
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
  final VoidCallback onFeedback;

  const _MobileBottomNavBar({
    required this.currentPath,
    required this.lecturerSignedIn,
    required this.onFeedback,
  });

  int _getSelectedIndex() {
    if (currentPath == '/') return 0;
    if (currentPath.startsWith('/booths')) return 1;
    if (currentPath.startsWith('/projects/junior-guide')) return 2;
    final tabFour = lecturerSignedIn ? '/lecturer/visits' : '/lecturer';
    if (currentPath.startsWith(tabFour)) return 3;
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
        context.go(lecturerSignedIn ? '/lecturer/visits' : '/lecturer');
        break;
      case 4:
        _showMobileMenu(context);
        break;
    }
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet<void>(
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
                _buildMenuItem(
                  context,
                  'Project Catalogue',
                  Icons.grid_view,
                  '/projects',
                ),
                _buildMenuItem(
                  context,
                  'Booths',
                  Icons.location_pin,
                  '/booths',
                ),
                _buildMenuItem(
                  context,
                  'Schedule',
                  Icons.event_note,
                  '/schedule',
                ),
                _buildMenuItem(
                  context,
                  'Project Guide',
                  Icons.school,
                  '/projects/junior-guide',
                ),
                _buildMenuItem(
                  context,
                  'Announcements',
                  Icons.campaign,
                  '/announcements',
                ),
                _buildMenuItem(
                  context,
                  'Award Winners',
                  Icons.emoji_events,
                  '/awards',
                ),
                // The Lecturers tab becomes Visits once signed in, so keep
                // the directory reachable here.
                if (lecturerSignedIn)
                  _buildMenuItem(
                    context,
                    'Lecturer Portal',
                    Icons.person,
                    '/lecturer',
                  ),

                _buildMenuItem(context, 'Exhibition Info', Icons.info, '/info'),
                _buildMenuItem(
                  context,
                  'Frequently Asked Questions',
                  Icons.help_outline,
                  '/faq',
                ),
                _buildMenuItem(
                  context,
                  'Privacy Policy',
                  Icons.privacy_tip_outlined,
                  '/privacy',
                ),
                const Divider(),
                Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    leading: const Icon(
                      Icons.feedback_outlined,
                      color: DesignSystem.secondary,
                    ),
                    title: Text('Send Feedback', style: DesignSystem.bodyMd),
                    onTap: () {
                      Navigator.pop(context);
                      onFeedback();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
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

  Widget _buildMenuItemExternal(
    BuildContext context,
    String title,
    IconData icon,
  ) {
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
    // Tab 4 is role-aware: visitors get the public lecturer directory,
    // signed-in lecturers get their visit list.
    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(
          Icons.home,
          color: DesignSystem.onSecondaryContainer,
        ),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.location_on_outlined),
        selectedIcon: Icon(
          Icons.location_on,
          color: DesignSystem.onSecondaryContainer,
        ),
        label: 'Map',
      ),
      const NavigationDestination(
        icon: Icon(Icons.school_outlined),
        selectedIcon: Icon(
          Icons.school,
          color: DesignSystem.onSecondaryContainer,
        ),
        label: 'Guide',
      ),
      lecturerSignedIn
          ? const NavigationDestination(
              icon: Icon(Icons.visibility_outlined),
              selectedIcon: Icon(
                Icons.visibility,
                color: DesignSystem.onSecondaryContainer,
              ),
              label: 'Visits',
            )
          : const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(
                Icons.person,
                color: DesignSystem.onSecondaryContainer,
              ),
              label: 'Staff',
            ),
      const NavigationDestination(icon: Icon(Icons.menu), label: 'Menu'),
    ];

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
        // short words wrap, so labels are hidden (Material icon-only pattern).
        child: Builder(
          builder: (scaleContext) {
            final narrow = MediaQuery.sizeOf(scaleContext).width < 360;
            return NavigationBar(
              labelBehavior: narrow
                  ? NavigationDestinationLabelBehavior.alwaysHide
                  : null,
              height: narrow ? 64 : null,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _onItemTapped(context, index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: DesignSystem.secondaryContainer,
              destinations: destinations,
            );
          },
        ),
      ),
    );
  }
}

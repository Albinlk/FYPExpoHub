import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/state/state_providers.dart';
import '../theme/theme.dart';
import 'feedback_form_widget.dart';

/// One sign-in page on this site for students, lecturers and admins (it used
/// to open the admin subdomain in a new tab).
void _openSignIn(BuildContext context) => context.go('/sign-in');

/// Desktop widths where every nav link fits, and where five do (with the
/// labelled Feedback button).
const kNavAllLinksWidth = 1440.0;
const kNavFiveLinksWidth = 1024.0;

class PublicShell extends ConsumerWidget {
  final Widget child;

  const PublicShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Path only: a query (?utm_source=..., filters) must not unselect the tab.
    final location = GoRouterState.of(context).uri.path;
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
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
          // Below 1024 px the labelled button covered card text, so it
          // shrinks to an icon with a tooltip.
          if (isDesktop)
            Positioned(
              right: 24,
              bottom: 24,
              child: MediaQuery.sizeOf(context).width >= kNavFiveLinksWidth
                  ? FloatingActionButton.extended(
                      onPressed: () => FeedbackFormWidget.show(context, ref),
                      icon: const Icon(Icons.feedback_outlined, size: 20),
                      label: const Text('Feedback'),
                      backgroundColor: DesignSystem.secondary,
                      foregroundColor: Colors.white,
                    )
                  : FloatingActionButton.small(
                      key: const Key('feedback-fab-compact'),
                      onPressed: () => FeedbackFormWidget.show(context, ref),
                      tooltip: 'Feedback',
                      backgroundColor: DesignSystem.secondary,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.feedback_outlined, size: 20),
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
          Semantics(
            link: true,
            label: 'FYP Expo Hub, go to the home page',
            excludeSemantics: true,
            child: InkWell(
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
          ),

          // Center: Links. Below 1440 px the full row does not fit beside the
          // logo and Sign In (at 800 px "Announcements" ran under the button),
          // so the lower-priority links move into More. The scroll view stays
          // as a last resort for very long translations.
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spaceMd),
              child: Builder(builder: (context) {
                final width = MediaQuery.sizeOf(context).width;
                final links = <(String, String)>[
                  ('Home', '/'),
                  ('Projects', '/projects'),
                  ('Booths', '/booths'),
                  ('Schedule', '/schedule'),
                  ('Past Projects Guide', '/projects/junior-guide'),
                  ('Announcements', '/announcements'),
                  ('Awards', '/awards'),
                  ('Find by Lecturer', '/lecturer'),
                  if (lecturerSignedIn) ('My Visits', '/lecturer/visits'),
                ];
                final inline = width >= kNavAllLinksWidth
                    ? links.length
                    : width >= kNavFiveLinksWidth
                        ? 5
                        : 3;
                final shown = links.take(inline).toList();
                final overflow = links.skip(inline).toList();
                final gap = width >= kNavAllLinksWidth ? DesignSystem.spaceLg : DesignSystem.spaceMd;
                const moreRoutes = [
                  ('Exhibition Info', '/info'),
                  ('FAQ', '/faq'),
                  ('Past Exhibitions', '/archive'),
                  ('Privacy Policy', '/privacy'),
                ];
                final menu = [...overflow, ...moreRoutes];
                final moreActive = menu.any((l) => _isActive(l.$2));
                return Row(
                  children: [
                    for (final (title, route) in shown) ...[
                      _buildNavLink(context, title, route),
                      SizedBox(width: gap),
                    ],
                    PopupMenuButton<String>(
                      key: const Key('nav-more'),
                      tooltip: 'More',
                      onSelected: (route) => _navigateTo(context, route),
                      itemBuilder: (_) => [
                        for (final (title, route) in menu)
                          PopupMenuItem(value: route, child: Text(title)),
                      ],
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'More',
                            style: DesignSystem.bodyMd.copyWith(
                              color: moreActive ? DesignSystem.primary : DesignSystem.onSurfaceVariant,
                              fontWeight: moreActive ? FontWeight.bold : null,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: DesignSystem.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          // Right: Login Button
          if (!lecturerSignedIn)
            Tooltip(
              message: 'Students and lecturers: CSP600, CSP650 and booth visits',
              child: ElevatedButton(
              onPressed: () => _openSignIn(context),
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
                  'Past Projects Guide',
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
                    'Find by Lecturer',
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
                _buildMenuItem(context, 'Past Exhibitions', Icons.history_edu, '/archive'),
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
          // Read the router before closing the sheet; its context goes away.
          final router = GoRouter.of(context);
          Navigator.pop(context);
          router.go('/sign-in');
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
        label: 'Booths',
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

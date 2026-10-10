import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/theme.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../../../core/utils/schedule_format.dart';

/// The portal landing page: the three parts of the FSKM final year project
/// (FSKM handbook, *Essentials of Computing Sciences: Project
/// Administration*, 4th ed.) side by side — the FYP Exhibition, CSP600 Project
/// Formulation and CSP650 Project — each with what it involves and a way in.
class PortalHomePage extends ConsumerWidget {
  const PortalHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = Breakpoints.isDesktop(context);
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;
    final signedIn = ref.watch(currentAuthUserProvider) != null;
    final event = ref.watch(eventProvider);

    // Course pages need a sign-in; afterwards the router sends each person to
    // their own workspace.
    void openCourses() => context.go(signedIn ? '/fypms' : '/sign-in?from=%2Ffypms');

    final now = DateTime.now();
    final status = now.isAfter(event.endAt)
        ? 'Held ${longDate(mytDate(event.startAt))}'
        : now.isAfter(event.startAt)
            ? 'Happening now'
            : '${longDate(mytDate(event.startAt))} – ${longDate(mytDate(event.endAt))}';

    final cards = [
      _PartCard(
        key: const Key('portal-exhibition'),
        icon: Icons.storefront_outlined,
        eyebrow: 'Open to everyone',
        title: 'FYP Exhibition',
        subtitle: '${event.title} · $status',
        points: const [
          'Browse this year\'s final year projects and award winners',
          'Find booths and the exhibition schedule',
          'Lecturers record booth visits and score F10 on the day',
        ],
        primaryLabel: 'Explore the Exhibition',
        onPrimary: () => context.go('/expo'),
        secondaryLabel: 'Browse Projects',
        onSecondary: () => context.go('/projects'),
      ),
      _PartCard(
        key: const Key('portal-csp600'),
        icon: Icons.edit_note_outlined,
        eyebrow: 'Semester 5',
        title: 'CSP600 · Project Formulation',
        subtitle: 'Find a supervisor, then write and defend your proposal.',
        points: const [
          'F1 Mutual Acceptance with your supervisor',
          'F2–F4 problem, literature review and methodology',
          'F5 consultation log after every meeting',
          'F6(a) proposal submission (similarity ≤ 30%)',
          'F7 and F8 proposal presentation and report',
        ],
        primaryLabel: signedIn ? 'Go to CSP600' : 'Sign In for CSP600',
        onPrimary: openCourses,
        secondaryLabel: 'Past Projects Guide',
        onSecondary: () => context.go('/projects/junior-guide'),
      ),
      _PartCard(
        key: const Key('portal-csp650'),
        icon: Icons.rocket_launch_outlined,
        eyebrow: 'Semester 6',
        title: 'CSP650 · Final Year Project',
        subtitle: 'Build the project, report it and present it at the exhibition.',
        points: const [
          'F9 progress presentation and F13 Lean Canvas',
          'F6(b) final report submission (similarity ≤ 30%)',
          'F10 and F11 final presentation and report',
          'F12 corrections, then final deliverables',
        ],
        primaryLabel: signedIn ? 'Go to CSP650' : 'Sign In for CSP650',
        onPrimary: openCourses,
        secondaryLabel: 'See the Exhibition',
        onSecondary: () => context.go('/expo'),
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [DesignSystem.primary, DesignSystem.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: isDesktop ? 64 : 32),
            child: Column(
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'FSKM Final Year Project Portal',
                    textAlign: TextAlign.center,
                    style: (isDesktop ? DesignSystem.h1 : DesignSystem.h1Mobile).copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: DesignSystem.spaceSm),
                Text(
                  'The exhibition, Project Formulation (CSP600) and the Final Year Project (CSP650) in one place.',
                  textAlign: TextAlign.center,
                  style: (isDesktop ? DesignSystem.bodyLg : DesignSystem.bodyLgMobile)
                      .copyWith(color: Colors.white.withValues(alpha: 0.9)),
                ),
                if (!signedIn) ...[
                  const SizedBox(height: DesignSystem.spaceLg),
                  FilledButton.icon(
                    key: const Key('portal-sign-in'),
                    onPressed: () => context.go('/sign-in'),
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In'),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignSystem.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: DesignSystem.spaceXs),
                  Text(
                    'Students, lecturers and coordinators use the same sign-in.',
                    textAlign: TextAlign.center,
                    style: DesignSystem.bodySm.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
            child: isDesktop
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < cards.length; i++) ...[
                          if (i > 0) const SizedBox(width: DesignSystem.spaceMd),
                          Expanded(child: cards[i].withFillHeight()),
                        ],
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(height: DesignSystem.spaceMd),
                        cards[i],
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PartCard extends StatelessWidget {
  _PartCard withFillHeight() => _PartCard(
        key: key,
        icon: icon,
        eyebrow: eyebrow,
        title: title,
        subtitle: subtitle,
        points: points,
        primaryLabel: primaryLabel,
        onPrimary: onPrimary,
        secondaryLabel: secondaryLabel,
        onSecondary: onSecondary,
        fillHeight: true,
      );

  const _PartCard({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    this.fillHeight = false,
  });

  final bool fillHeight;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<String> points;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: DesignSystem.secondary, size: 28),
                const SizedBox(width: DesignSystem.spaceSm),
                Flexible(
                  child: Text(
                    eyebrow.toUpperCase(),
                    style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spaceSm),
            Semantics(
              header: true,
              child: Text(title, style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
            ),
            const SizedBox(height: DesignSystem.spaceXs),
            Text(subtitle, style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
            const SizedBox(height: DesignSystem.spaceMd),
            for (final point in points)
              Padding(
                padding: const EdgeInsets.only(bottom: DesignSystem.spaceXs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Icon(Icons.check, size: 16, color: DesignSystem.tertiary),
                    ),
                    const SizedBox(width: DesignSystem.spaceSm),
                    Expanded(child: Text(point, style: DesignSystem.bodySm)),
                  ],
                ),
              ),
            // On desktop the three cards share a row height; keep the buttons
            // on one line at the bottom. In a scrolling column there is no
            // height to fill.
            if (fillHeight) const Spacer(),
            const SizedBox(height: DesignSystem.spaceMd),
            Wrap(
              spacing: DesignSystem.spaceSm,
              runSpacing: DesignSystem.spaceSm,
              children: [
                FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
                OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

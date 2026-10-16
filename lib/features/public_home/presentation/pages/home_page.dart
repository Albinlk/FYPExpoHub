import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/award.dart';
import '../../../../core/domain/models/event.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/utils/external_link.dart';
import '../../../../core/widgets/entrance_animation.dart';
import '../../../../core/widgets/project_card.dart';
import '../../../../core/widgets/scholar_lab.dart';
import '../widgets/workspace_band.dart';

/// Widest the home content grows; wider screens get margins instead.
const kHomeMaxWidth = 1200.0;

/// The exhibition home, and the site's homepage ("Scholar + Lab", docs/developer/design-system.md):
/// a left-aligned hero on graph paper with live numbers, then numbered
/// sections, then the FYP Workspace band for students and lecturers.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final query = _searchController.text.trim();
    context.go(query.isEmpty ? '/projects' : Uri(path: '/projects', queryParameters: {'search': query}).toString());
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;
    final event = ref.watch(eventProvider);
    final projects = ref.watch(publicProjectsProvider);
    final winners = ref.watch(publicAwardsProvider);

    // Sections are numbered in order of appearance; winners only once there are some.
    var n = 0;
    String next() => (++n).toString().padLeft(2, '0');

    final sections = <Widget>[
      _Section(
        padding: padding,
        child: _FeaturedProjects(number: next(), isDesktop: isDesktop),
      ),
      if (winners.isNotEmpty)
        _Section(
          padding: padding,
          child: _AwardWinners(number: next(), winners: winners.take(3).toList(), isDesktop: isDesktop),
        ),
      _Section(
        padding: padding,
        background: DesignSystem.surfaceContainerLow,
        child: _GuideTeaser(number: next(), isDesktop: isDesktop),
      ),
      _Section(
        padding: padding,
        child: _PlanYourVisit(number: next(), event: event, isDesktop: isDesktop),
      ),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Hero(
              event: event,
              projects: projects,
              isDesktop: isDesktop,
              padding: padding,
              search: _searchController,
              onSearch: _search,
            ),
            for (var i = 0; i < sections.length; i++) StaggeredEntrance(index: i, child: sections[i]),
            WorkspaceBand(padding: padding),
          ],
        ),
      ),
    );
  }
}

/// Full-width band whose content is centred and capped at [kHomeMaxWidth].
class _Section extends StatelessWidget {
  const _Section({required this.padding, required this.child, this.background});

  final double padding;
  final Widget child;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    return ColoredBox(
      color: background ?? Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: isDesktop ? 56 : 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kHomeMaxWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// "06–07 AUG 2026" from the live event record.
String exhibitionDates(Event event) {
  const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
  final s = event.startAt.toLocal();
  final e = event.endAt.toLocal();
  String d(int v) => v.toString().padLeft(2, '0');
  if (s.year == e.year && s.month == e.month) {
    return s.day == e.day
        ? '${d(s.day)} ${months[s.month - 1]} ${s.year}'
        : '${d(s.day)}–${d(e.day)} ${months[e.month - 1]} ${e.year}';
  }
  return '${d(s.day)} ${months[s.month - 1]} – ${d(e.day)} ${months[e.month - 1]} ${e.year}';
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.event,
    required this.projects,
    required this.isDesktop,
    required this.padding,
    required this.search,
    required this.onSearch,
  });

  final Event event;
  final List<Project> projects;
  final bool isDesktop;
  final double padding;
  final TextEditingController search;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final heroImage = safeExternalUri(event.heroImageUrl);
    final headline = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FSKM · UiTM JASIN', style: DesignSystem.kicker.copyWith(color: DesignSystem.secondary)),
        const SizedBox(height: DesignSystem.spaceMd),
        Semantics(
          header: true,
          child: Text(
            'Final Year Project Exhibition ${event.startAt.toLocal().year}',
            style: (isDesktop ? DesignSystem.display : DesignSystem.displayMobile).copyWith(color: DesignSystem.primary),
          ),
        ),
        const SizedBox(height: DesignSystem.spaceMd),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'This year\'s final year projects from the Faculty of Computer and Mathematical Sciences: '
            'browse them, find their booths and see the winners.',
            style: (isDesktop ? DesignSystem.bodyLg : DesignSystem.bodyLgMobile)
                .copyWith(color: DesignSystem.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: DesignSystem.spaceLg),
        _EventMeta(event: event),
        const SizedBox(height: DesignSystem.spaceSm),
        _EventStatus(eventStart: event.startAt, eventEnd: event.endAt),
        const SizedBox(height: DesignSystem.spaceLg),
        Wrap(
          spacing: DesignSystem.spaceSm,
          runSpacing: DesignSystem.spaceSm,
          children: [
            FilledButton.icon(
              key: const Key('home-explore'),
              onPressed: () => context.go('/projects'),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Explore Projects'),
            ),
            OutlinedButton(
              key: const Key('home-schedule'),
              onPressed: () => context.go('/schedule'),
              child: const Text('View Schedule'),
            ),
          ],
        ),
        const SizedBox(height: DesignSystem.spaceMd),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: TextField(
            controller: search,
            onSubmitted: (_) => onSearch(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: isDesktop ? 'Search projects, supervisors or keywords' : 'Search projects',
              prefixIcon: const Icon(Icons.search, color: DesignSystem.primary),
              suffixIcon: IconButton(
                tooltip: 'Search',
                onPressed: onSearch,
                icon: const Icon(Icons.arrow_forward, color: DesignSystem.secondary),
              ),
            ),
          ),
        ),
      ],
    );

    final side = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (heroImage != null && isDesktop) ...[
          ClipRRect(
            borderRadius: DesignSystem.radiusLg,
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                heroImage.toString(),
                fit: BoxFit.cover,
                semanticLabel: 'Exhibition photo',
                errorBuilder: (_, _, _) => const ColoredBox(color: DesignSystem.surfaceContainerLow),
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spaceMd),
        ],
        _StatCard(projects: projects),
      ],
    );

    return GraphPaper(
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, isDesktop ? 72 : 36, padding, isDesktop ? 72 : 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kHomeMaxWidth),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 7, child: headline),
                      const SizedBox(width: 48),
                      Expanded(flex: 5, child: side),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [headline, const SizedBox(height: DesignSystem.spaceLg), side],
                  ),
          ),
        ),
      ),
    );
  }
}

/// "06–07 AUG 2026 · 9:00 AM - 5:00 PM · Blok Kuliah, FSKM" in mono.
class _EventMeta extends StatelessWidget {
  const _EventMeta({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final parts = [
      (Icons.calendar_today_outlined, exhibitionDates(event)),
      if (event.dailyHours.isNotEmpty) (Icons.schedule, event.dailyHours.toUpperCase()),
      if (event.venue.isNotEmpty) (Icons.place_outlined, event.venue.toUpperCase()),
    ];
    return Wrap(
      key: const Key('home-event-meta'),
      spacing: DesignSystem.spaceMd,
      runSpacing: DesignSystem.spaceXs,
      children: [
        for (final (icon, text) in parts)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: DesignSystem.secondary),
              const SizedBox(width: 6),
              Flexible(child: Text(text, style: DesignSystem.kicker.copyWith(color: DesignSystem.primary))),
            ],
          ),
      ],
    );
  }
}

/// Projects / programmes / booths, counted from the published projects.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.projects});

  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final programmes = projects.map((p) => p.programmeCode).where((c) => c.isNotEmpty).toSet().length;
    final booths = projects.map((p) => p.boothNumber ?? '').where((b) => b.isNotEmpty).toSet().length;
    final stats = [
      StatBlock(label: 'Projects', value: '${projects.length}'),
      StatBlock(label: 'Programmes', value: '$programmes'),
      StatBlock(label: 'Booths', value: '$booths'),
    ];
    return Container(
      key: const Key('home-stats'),
      padding: const EdgeInsets.all(DesignSystem.spaceLg),
      decoration: BoxDecoration(
        color: DesignSystem.surfaceContainerLowest,
        borderRadius: DesignSystem.radiusLg,
        border: Border.all(color: DesignSystem.rule),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) const VerticalDivider(color: DesignSystem.rule, width: DesignSystem.spaceLg, thickness: 1),
              Expanded(child: stats[i]),
            ],
          ],
        ),
      ),
    );
  }
}

/// One mono line: time to opening, live now, or held. Ticks once a minute.
class _EventStatus extends StatefulWidget {
  const _EventStatus({required this.eventStart, required this.eventEnd});

  final DateTime eventStart;
  final DateTime eventEnd;

  @override
  State<_EventStatus> createState() => _EventStatusState();
}

class _EventStatusState extends State<_EventStatus> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (DateTime.now().isBefore(widget.eventEnd)) {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (!mounted) return;
        setState(() {});
        if (!DateTime.now().isBefore(widget.eventEnd)) _timer?.cancel();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String text;
    final Color dot;
    if (now.isAfter(widget.eventEnd)) {
      text = 'CONCLUDED · THANK YOU FOR VISITING';
      dot = DesignSystem.onSurfaceVariant;
    } else if (now.isAfter(widget.eventStart)) {
      text = 'LIVE NOW';
      dot = DesignSystem.secondary;
    } else {
      final left = widget.eventStart.difference(now);
      String d(int v) => v.toString().padLeft(2, '0');
      text = 'OPENS IN ${d(left.inDays)}D ${d(left.inHours % 24)}H ${d(left.inMinutes % 60)}M';
      dot = DesignSystem.tertiary;
    }
    return Row(
      key: const Key('home-event-status'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        const SizedBox(width: DesignSystem.spaceSm),
        Flexible(child: Text(text, style: DesignSystem.kicker.copyWith(color: DesignSystem.onSurfaceVariant))),
      ],
    );
  }
}

class _ViewAll extends StatelessWidget {
  const _ViewAll({required this.label, required this.route});

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.go(route),
      style: TextButton.styleFrom(foregroundColor: DesignSystem.secondary),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: DesignSystem.button.copyWith(fontSize: 14)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward, size: 16),
        ],
      ),
    );
  }
}

class _FeaturedProjects extends ConsumerWidget {
  const _FeaturedProjects({required this.number, required this.isDesktop});

  final String number;
  final bool isDesktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A short, curated row: the catalogue is for browsing everything.
    final display = featuredForHome(ref.watch(mostVisitedProjectsProvider));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          number: number,
          title: 'Featured projects',
          action: isDesktop ? const _ViewAll(label: 'View All', route: '/projects') : null,
        ),
        const SizedBox(height: DesignSystem.spaceLg),
        if (display.isEmpty)
          Text('Projects appear here once they are published.', style: DesignSystem.bodyMd)
        else if (isDesktop)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: ProjectCard.gridDelegate(
              MediaQuery.sizeOf(context).width,
              textScale: MediaQuery.textScalerOf(context).scale(1),
            ),
            itemCount: display.length,
            itemBuilder: (context, i) => ProjectCard(
              project: display[i],
              onTap: () => context.push('/projects/${display[i].slug}'),
            ),
          )
        else
          for (var i = 0; i < display.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == display.length - 1 ? 0 : DesignSystem.spaceMd),
              child: ProjectCard(
                project: display[i],
                imageHeight: 160,
                onTap: () => context.push('/projects/${display[i].slug}'),
              ),
            ),
        if (!isDesktop) ...[
          const SizedBox(height: DesignSystem.spaceSm),
          const Align(alignment: Alignment.centerLeft, child: _ViewAll(label: 'View All Projects', route: '/projects')),
        ],
      ],
    );
  }
}

class _AwardWinners extends StatelessWidget {
  const _AwardWinners({required this.number, required this.winners, required this.isDesktop});

  final String number;
  final List<PublishedAwardWinner> winners;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final cards = [
      for (final w in winners)
        Container(
          padding: const EdgeInsets.all(DesignSystem.spaceMd),
          decoration: BoxDecoration(
            color: DesignSystem.surfaceContainerLowest,
            borderRadius: DesignSystem.radiusLg,
            border: Border.all(color: DesignSystem.rule),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: DesignSystem.spaceXs,
                runSpacing: DesignSystem.spaceXs,
                children: [
                  const CodeTag('WINNER', winner: true, icon: Icons.emoji_events_outlined),
                  if ((w.programmeCode ?? '').isNotEmpty) CodeTag(w.programmeCode!),
                ],
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              Text(
                w.projectTitle,
                style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if ((w.teamDisplayName ?? '').isNotEmpty) ...[
                const SizedBox(height: DesignSystem.spaceXs),
                Text(w.teamDisplayName!, style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
              ],
            ],
          ),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          number: number,
          title: 'Award winners',
          action: isDesktop ? const _ViewAll(label: 'All Winners', route: '/awards') : null,
        ),
        const SizedBox(height: DesignSystem.spaceLg),
        if (isDesktop)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: DesignSystem.spaceMd),
                  Expanded(child: cards[i]),
                ],
                // Keep card widths stable when there are fewer than three.
                for (var i = cards.length; i < 3; i++) ...[
                  const SizedBox(width: DesignSystem.spaceMd),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ],
            ),
          )
        else ...[
          for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: DesignSystem.spaceSm), child: c),
          const _ViewAll(label: 'All Winners', route: '/awards'),
        ],
      ],
    );
  }
}

class _GuideTeaser extends StatelessWidget {
  const _GuideTeaser({required this.number, required this.isDesktop});

  final String number;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse earlier CSP600 proposals and CSP650 projects by programme and topic, '
          'and spot titles that are already taken, before you choose your own.',
          style: (isDesktop ? DesignSystem.bodyLg : DesignSystem.bodyLgMobile).copyWith(color: DesignSystem.onBackground),
        ),
        const SizedBox(height: DesignSystem.spaceMd),
        const Wrap(
          spacing: DesignSystem.spaceXs,
          runSpacing: DesignSystem.spaceXs,
          children: [CodeTag('CSP600'), CodeTag('CSP650'), CodeTag('BY PROGRAMME'), CodeTag('SIMILAR TITLES')],
        ),
      ],
    );
    final button = FilledButton.icon(
      key: const Key('home-guide'),
      onPressed: () => context.go('/projects/junior-guide'),
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.arrow_forward, size: 18),
      label: const Text('Open the Guide'),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(number: number, title: 'Past Projects Guide'),
        const SizedBox(height: DesignSystem.spaceLg),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: text),
              const SizedBox(width: 48),
              button,
            ],
          )
        else ...[
          text,
          const SizedBox(height: DesignSystem.spaceMd),
          Align(alignment: Alignment.centerLeft, child: button),
        ],
      ],
    );
  }
}

class _PlanYourVisit extends StatelessWidget {
  const _PlanYourVisit({required this.number, required this.event, required this.isDesktop});

  final String number;
  final Event event;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    Widget fact(String label, String value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: DesignSystem.kicker.copyWith(color: DesignSystem.onSurfaceVariant)),
            const SizedBox(height: DesignSystem.spaceXs),
            Text(value, style: DesignSystem.bodyLgMobile.copyWith(color: DesignSystem.primary, fontWeight: FontWeight.w600)),
          ],
        );
    final facts = [
      fact('DATES', exhibitionDates(event)),
      fact('HOURS', event.dailyHours.isEmpty ? 'To be announced' : event.dailyHours),
      fact('VENUE', event.venue.isEmpty ? 'To be announced' : event.venue),
    ];
    final map = safeExternalUri(event.mapUrl);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(number: number, title: 'Plan your visit'),
        const SizedBox(height: DesignSystem.spaceLg),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final f in facts) Expanded(child: f)],
          )
        else
          for (final f in facts) Padding(padding: const EdgeInsets.only(bottom: DesignSystem.spaceMd), child: f),
        const SizedBox(height: DesignSystem.spaceLg),
        Wrap(
          spacing: DesignSystem.spaceSm,
          runSpacing: DesignSystem.spaceSm,
          children: [
            OutlinedButton.icon(
              onPressed: () => context.go('/booths'),
              icon: const Icon(Icons.place_outlined, size: 18),
              label: const Text('Find a Booth'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/info'),
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('Exhibition Info'),
            ),
            if (map != null)
              TextButton.icon(
                onPressed: () => launchUrl(map, webOnlyWindowName: '_blank'),
                style: TextButton.styleFrom(foregroundColor: DesignSystem.secondary),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Open Map'),
              ),
          ],
        ),
      ],
    );
  }
}

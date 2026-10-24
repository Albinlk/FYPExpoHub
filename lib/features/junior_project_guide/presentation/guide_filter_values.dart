import 'package:flutter/foundation.dart';

import '../../../core/domain/models/project.dart';
import '../domain/project_similarity.dart';

/// Wraps a [Project] with the section it belongs to.
class SectionedProject {
  final Project project;
  final String section; // 'CSP650' or 'CSP600'

  const SectionedProject({
    required this.project,
    required this.section,
  });
}

/// The Past Projects Guide's Browse filters (everything but the search text,
/// which lives in the page's TextEditingController). Immutable: the page holds
/// one value and replaces it through [copyWith].
@immutable
class GuideFilterValues {
  const GuideFilterValues({
    this.section = 'all',
    this.programme = 'All',
    this.category = 'All',
    this.techStack = 'All',
    this.supervisor = 'All',
    this.session = 'All',
    this.redundancy = 'All',
    this.industryOnly = false,
  });

  final String section; // 'all' | 'CSP650' | 'CSP600'
  final String programme;
  final String category;
  final String techStack;
  final String supervisor;
  final String session;
  final String redundancy; // 'All' | 'Unique' | 'Has Similar'
  final bool industryOnly;

  GuideFilterValues copyWith({
    String? section,
    String? programme,
    String? category,
    String? techStack,
    String? supervisor,
    String? session,
    String? redundancy,
    bool? industryOnly,
  }) =>
      GuideFilterValues(
        section: section ?? this.section,
        programme: programme ?? this.programme,
        category: category ?? this.category,
        techStack: techStack ?? this.techStack,
        supervisor: supervisor ?? this.supervisor,
        session: session ?? this.session,
        redundancy: redundancy ?? this.redundancy,
        industryOnly: industryOnly ?? this.industryOnly,
      );

  /// Number of collapsed filters currently active (drives the toggle badge).
  /// The section pills stay visible, so they don't count.
  int get activeCount {
    var count = 0;
    if (programme != 'All') count++;
    if (category != 'All') count++;
    if (techStack != 'All') count++;
    if (supervisor != 'All') count++;
    if (session != 'All') count++;
    if (redundancy != 'All') count++;
    if (industryOnly) count++;
    return count;
  }

  /// Applies filters passed via query parameters (a shared or refreshed link,
  /// or another page pre-scoped to a supervisor). Values a dropdown no longer
  /// offers fall back to "All" when shown (see the guide's dropdowns).
  GuideFilterValues withQuery(Map<String, String> params) {
    final section = params['section'];
    return GuideFilterValues(
      section: section == 'CSP650' || section == 'CSP600' ? section! : this.section,
      programme: params['programme'] ?? programme,
      category: params['category'] ?? category,
      techStack: params['techStack'] ?? techStack,
      supervisor: params['supervisor'] ?? supervisor,
      session: params['session'] ?? session,
      redundancy: params['redundancy'] ?? redundancy,
      industryOnly: params['industry'] == 'true',
    );
  }

  /// The address-bar query for these filters plus [search]; defaults map to
  /// null so the default view keeps a clean URL.
  Map<String, String?> toQuery(String search) => {
        'search': search,
        'section': section == 'all' ? null : section,
        'programme': programme == 'All' ? null : programme,
        'category': category == 'All' ? null : category,
        'techStack': techStack == 'All' ? null : techStack,
        'supervisor': supervisor == 'All' ? null : supervisor,
        'session': session == 'All' ? null : session,
        'redundancy': redundancy == 'All' ? null : redundancy,
        'industry': industryOnly ? 'true' : null,
      };

  /// The projects in [all] that pass these filters and [search].
  List<SectionedProject> apply(
    List<SectionedProject> all,
    String search,
    Map<String, int> similarityCounts,
  ) {
    final searchLower = search.toLowerCase();

    return all.where((sp) {
      final p = sp.project;

      final matchesSection = section == 'all' || sp.section == section;

      final matchesSearch = searchLower.isEmpty ||
          p.title.toLowerCase().contains(searchLower) ||
          p.supervisorDisplayName.toLowerCase().contains(searchLower) ||
          ProjectSimilarity.displayTags(p)
              .any((t) => t.toLowerCase().contains(searchLower));

      final matchesProgramme =
          programme == 'All' || p.programmeCode == programme;

      final matchesCategory = category == 'All' || p.category == category;

      final matchesTechStack = techStack == 'All' ||
          ProjectSimilarity.categoryTags(p)
              .any((t) => t.toLowerCase() == techStack.toLowerCase());

      final matchesSupervisor =
          supervisor == 'All' || p.supervisorDisplayName == supervisor;

      final matchesSession =
          session == 'All' || p.presentationDay == session;

      final simCount = similarityCounts[p.id] ?? 0;
      final matchesRedundancy = switch (redundancy) {
        'Unique' => simCount == 0,
        'Has Similar' => simCount > 0,
        _ => true,
      };

      final matchesIndustry = !industryOnly || p.calonIndustri;

      return matchesSection &&
          matchesSearch &&
          matchesProgramme &&
          matchesCategory &&
          matchesTechStack &&
          matchesSupervisor &&
          matchesSession &&
          matchesRedundancy &&
          matchesIndustry;
    }).toList();
  }
}

/// The choices each Browse dropdown offers, derived from the loaded projects.
class GuideFilterOptions {
  GuideFilterOptions.from(List<SectionedProject> all, String section)
      : programmes = _programmes(all),
        categories = _categories(all),
        techStacks = _techStacks(all),
        supervisors = _supervisors(all, section),
        sessions = _sessions(all);

  final List<String> programmes;
  final List<String> categories;
  final List<String> techStacks;
  final List<String> supervisors;
  final List<String> sessions;

  static List<String> _programmes(List<SectionedProject> all) {
    final seen = <String>{};
    for (final sp in all) {
      if (sp.project.programmeCode.isNotEmpty) {
        seen.add(sp.project.programmeCode);
      }
    }
    return seen.toList()..sort();
  }

  /// Scoped to the currently selected Section — with both cohorts combined,
  /// the supervisor list would otherwise mix CSP650 and CSP600 names the
  /// user isn't browsing, making it longer and less relevant than it needs
  /// to be once a section is picked.
  static List<String> _supervisors(List<SectionedProject> all, String section) {
    final scoped =
        section == 'all' ? all : all.where((sp) => sp.section == section);
    final seen = <String>{};
    for (final sp in scoped) {
      if (sp.project.supervisorDisplayName.isNotEmpty) {
        seen.add(sp.project.supervisorDisplayName);
      }
    }
    return seen.toList()..sort();
  }

  static List<String> _categories(List<SectionedProject> all) {
    final seen = <String>{};
    for (final sp in all) {
      if (sp.project.category.isNotEmpty) {
        seen.add(sp.project.category);
      }
    }
    return seen.toList()..sort();
  }

  /// Uses [ProjectSimilarity.categoryTags], not the raw [ProjectSimilarity.
  /// displayTags] shown on project cards: CSP650 projects are already
  /// tagged with a standardized category vocabulary (e.g. "Machine
  /// Learning"), but CSP600 CSV proposals carry genuinely raw tags (e.g.
  /// "MQTT", "OSPF", "Snort"). Merging both verbatim would flood this
  /// dropdown with ~80 mixed-vocabulary entries where a broad category and
  /// a specific tool never match each other — categoryTags collapses both
  /// onto the same ~23-term vocabulary so e.g. selecting "Networking"
  /// finds both cohorts' networking projects.
  static List<String> _techStacks(List<SectionedProject> all) {
    final seen = <String>{};
    for (final sp in all) {
      seen.addAll(ProjectSimilarity.categoryTags(sp.project));
    }
    return seen.toList()..sort();
  }

  /// Session/time-slot values, populated for CSP600 proposals via
  /// [Project.presentationDay] (see Csp600CsvLoader). CSP650 projects
  /// generally don't carry a session string, so this filter is only
  /// meaningful once CSP600 data is in view.
  static List<String> _sessions(List<SectionedProject> all) {
    final seen = <String>{};
    for (final sp in all) {
      final day = sp.project.presentationDay;
      if (day != null && day.isNotEmpty) seen.add(day);
    }
    return seen.toList()..sort();
  }
}

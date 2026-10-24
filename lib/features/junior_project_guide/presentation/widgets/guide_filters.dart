import 'package:flutter/material.dart';

import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/collapsible_filter_panel.dart';
import '../guide_filter_values.dart';

/// The Past Projects Guide's Browse search box and filters: a card with every
/// filter on desktop, a collapsible panel on phones (search + section pills
/// stay visible; the dropdowns hide behind a badged toggle).
///
/// Stateless: the page owns the values and the search controller and gets
/// every change back through the callbacks.
class GuideFilters extends StatelessWidget {
  const GuideFilters({
    super.key,
    required this.isDesktop,
    required this.all,
    required this.values,
    required this.onChanged,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onReset,
    required this.mobileExpanded,
    required this.onMobileExpandedChanged,
  });

  final bool isDesktop;

  /// Every loaded project; the dropdown choices are derived from it.
  final List<SectionedProject> all;
  final GuideFilterValues values;
  final ValueChanged<GuideFilterValues> onChanged;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onReset;
  final bool mobileExpanded;
  final ValueChanged<bool> onMobileExpandedChanged;

  @override
  Widget build(BuildContext context) {
    final options = GuideFilterOptions.from(all, values.section);

    if (isDesktop) {
      return Card(
        margin: EdgeInsets.symmetric(
          horizontal: DesignSystem.marginDesktop,
          vertical: DesignSystem.spaceMd,
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spaceMd),
          child: Column(
            children: [
              _searchField('Search by project title, supervisor, or tech tags…', dense: false),
              const SizedBox(height: DesignSystem.spaceMd),
              _desktopFilters(options),
            ],
          ),
        ),
      );
    }

    // Mobile: compact collapsible panel — search + section pills stay
    // visible; the three dropdowns hide behind a badged toggle.
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSystem.marginMobile,
        vertical: DesignSystem.spaceMd,
      ),
      child: CollapsibleFilterPanel(
        header: _searchField('Search projects…', dense: true),
        headerTrailing: Wrap(
          spacing: 8,
          children: [
            _sectionPill('All', 'all'),
            _sectionPill('CSP650', 'CSP650'),
            _sectionPill('CSP600', 'CSP600'),
          ],
        ),
        activeCount: values.activeCount,
        expanded: mobileExpanded,
        onToggle: () => onMobileExpandedChanged(!mobileExpanded),
        filterFields: [
          _programmeDropdown(options),
          _categoryDropdown(options),
          _techStackDropdown(options),
          _supervisorDropdown(options),
          if (options.sessions.isNotEmpty) _sessionDropdown(options),
          _redundancyDropdown(),
          _industryToggle(),
        ],
        resetControl: TextButton.icon(
          onPressed: () {
            onReset();
            onMobileExpandedChanged(false);
          },
          icon: const Icon(Icons.filter_alt_off, size: 18),
          label: const Text('Reset Filters'),
        ),
      ),
    );
  }

  /// The clear (x) icon needs to react to every keystroke, but filtering the
  /// (possibly hundreds-long) list is debounced — listening on the controller
  /// directly keeps the icon instant without forcing the expensive parent
  /// rebuild on every key.
  Widget _searchField(String hint, {required bool dense}) {
    return ListenableBuilder(
      listenable: searchController,
      builder: (context, _) => TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, color: DesignSystem.primary),
          isDense: dense ? true : null,
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  tooltip: 'Clear search',
                  onPressed: onClearSearch,
                )
              : null,
        ),
      ),
    );
  }

  Widget _desktopFilters(GuideFilterOptions options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Section', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    _sectionPill('All', 'all'),
                    _sectionPill('CSP650', 'CSP650'),
                    _sectionPill('CSP600', 'CSP600'),
                  ],
                ),
              ],
            ),
            const SizedBox(width: DesignSystem.spaceLg),
            Expanded(child: _programmeDropdown(options)),
            const SizedBox(width: 16),
            Expanded(child: _categoryDropdown(options)),
            const SizedBox(width: 16),
            Expanded(child: _techStackDropdown(options)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _supervisorDropdown(options)),
            if (options.sessions.isNotEmpty) ...[
              const SizedBox(width: 16),
              Expanded(child: _sessionDropdown(options)),
            ],
            const SizedBox(width: 16),
            Expanded(child: _redundancyDropdown()),
            const SizedBox(width: 16),
            _industryToggle(),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onReset,
              child: const Text('Reset Filters'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _programmeDropdown(GuideFilterOptions o) => _GuideDropdown(
        label: 'Academic Program',
        value: values.programme,
        items: ['All', ...o.programmes],
        onChanged: (v) => onChanged(values.copyWith(programme: v!)),
      );

  Widget _categoryDropdown(GuideFilterOptions o) => _GuideDropdown(
        label: 'Project Category',
        value: values.category,
        items: ['All', ...o.categories],
        onChanged: (v) => onChanged(values.copyWith(category: v!)),
      );

  Widget _techStackDropdown(GuideFilterOptions o) => _GuideDropdown(
        label: 'Tech Stack',
        value: values.techStack,
        items: ['All', ...o.techStacks],
        onChanged: (v) => onChanged(values.copyWith(techStack: v!)),
      );

  Widget _supervisorDropdown(GuideFilterOptions o) => _GuideDropdown(
        label: 'Supervisor',
        value: values.supervisor,
        items: ['All', ...o.supervisors],
        onChanged: (v) => onChanged(values.copyWith(supervisor: v!)),
      );

  Widget _sessionDropdown(GuideFilterOptions o) => _GuideDropdown(
        label: 'Session',
        value: values.session,
        items: ['All', ...o.sessions],
        onChanged: (v) => onChanged(values.copyWith(session: v!)),
      );

  Widget _redundancyDropdown() => _GuideDropdown(
        label: 'Redundancy Status',
        value: values.redundancy,
        items: const ['All', 'Unique', 'Has Similar'],
        onChanged: (v) => onChanged(values.copyWith(redundancy: v!)),
      );

  Widget _industryToggle() {
    final industryOnly = values.industryOnly;
    // calonIndustri is only ever set on CSP650 rows (via the admin panel);
    // Csp600CsvLoader always parses CSP600 proposals with calonIndustri:
    // false, since the CSV has no equivalent column — surface that here
    // rather than leave students wondering why CSP600 never matches.
    final csp600InView = values.section == 'all' || values.section == 'CSP600';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: csp600InView
              ? 'Only CSP650 projects can be flagged as an industry candidate — CSP600 proposals never match this filter.'
              : 'Industry Candidate',
          child: Text(
            'Industry Candidate',
            style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 6),
        FilterChip(
          selected: industryOnly,
          onSelected: (val) => onChanged(values.copyWith(industryOnly: val)),
          label: Text(industryOnly ? 'Showing only' : 'Show only'),
          avatar: Icon(
            Icons.business_center_outlined,
            size: 16,
            color: industryOnly ? Colors.white : DesignSystem.tertiary,
          ),
          selectedColor: DesignSystem.tertiary,
          checkmarkColor: Colors.white,
          showCheckmark: false,
          labelStyle: DesignSystem.bodySm.copyWith(
            color: industryOnly ? Colors.white : DesignSystem.onSurfaceVariant,
          ),
          backgroundColor: DesignSystem.surfaceContainerLowest,
          side: BorderSide(color: DesignSystem.outlineVariant),
        ),
      ],
    );
  }

  Widget _sectionPill(String label, String value) {
    final selected = values.section == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onChanged(values.copyWith(section: value)),
      selectedColor: DesignSystem.secondaryContainer,
      backgroundColor: DesignSystem.surfaceContainerLowest,
      labelStyle: DesignSystem.bodySm.copyWith(
        color: selected
            ? DesignSystem.onSecondaryContainer
            : DesignSystem.onSurfaceVariant,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

/// A labelled filter dropdown. A value from an old link that is no longer
/// offered shows the first option ("All") instead of breaking the dropdown.
class _GuideDropdown extends StatelessWidget {
  const _GuideDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DesignSystem.labelCaps.copyWith(
            color: DesignSystem.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: DesignSystem.surfaceContainerLowest,
            borderRadius: DesignSystem.radiusLg,
            border: Border.all(color: DesignSystem.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            // Named for screen readers (the label above is a separate Text).
            child: Semantics(
              label: label,
              child: DropdownButton<String>(
                value: items.contains(value) ? value : (items.isEmpty ? null : items.first),
                isExpanded: true,
                onChanged: onChanged,
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: DesignSystem.bodySm,
                      softWrap: true,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

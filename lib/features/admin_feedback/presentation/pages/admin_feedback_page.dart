import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/feedback_entry.dart';
import '../../../../core/state/state_providers.dart';
import '../widgets/feedback_csv_export.dart';

class AdminFeedbackPage extends ConsumerStatefulWidget {
  const AdminFeedbackPage({super.key});

  @override
  ConsumerState<AdminFeedbackPage> createState() => _AdminFeedbackPageState();
}

class _AdminFeedbackPageState extends ConsumerState<AdminFeedbackPage> {
  String _filterStatus = 'all';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FeedbackEntry> _applyFilters(List<FeedbackEntry> entries) {
    var filtered = entries;

    if (_filterStatus != 'all') {
      filtered = filtered.where((f) => f.status == _filterStatus).toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((f) {
        return f.subject.toLowerCase().contains(query) ||
               f.message.toLowerCase().contains(query) ||
               (f.userId ?? '').toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  void _exportCsv(List<FeedbackEntry> entries) {
    final csv = exportFeedbackCsv(entries);
    final bytes = utf8.encode(csv);
    final base64 = base64Encode(bytes);
    final href = 'data:text/csv;base64,$base64';

    final document = globalContext['document'] as JSObject;
    final anchor = document.callMethod('createElement'.toJS, ['a'.toJS].toJS) as JSObject;
    anchor['href'] = href.toJS;
    final now = DateTime.now();
    anchor['download'] = 'feedback_export_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.csv'.toJS;
    anchor.callMethod('click'.toJS, null);
  }

  void _showDetailDialog(BuildContext context, FeedbackEntry entry) {
    final statusController = TextEditingController(text: entry.status);
    final noteController = TextEditingController(text: entry.adminNote ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDesktop = MediaQuery.of(context).size.width >= 768;
        return AlertDialog(
          title: Text(
            'Feedback Details',
            style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg)
                .copyWith(color: DesignSystem.primary),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: isDesktop ? 600 : MediaQuery.of(context).size.width * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Subject', entry.subject),
                  _buildInfoRow('Message', entry.message, isMultiline: true),
                  _buildInfoRow('Rating', entry.rating?.toString() ?? '—'),
                  _buildInfoRow('User ID', entry.userId ?? 'Anonymous'),
                  _buildInfoRow('Submitted', _formatDate(entry.createdAt)),
                  _buildInfoRow('Event ID', entry.eventId),
                  const SizedBox(height: DesignSystem.spaceMd),
                  DropdownButtonFormField<String>(
                    initialValue: statusController.text,
                    items: const [
                      DropdownMenuItem(value: 'new', child: Text('New')),
                      DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                      DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => statusController.text = val);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  const SizedBox(height: DesignSystem.spaceMd),
                  TextFormField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'Admin Note'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                ref.read(feedbackEntriesProvider.notifier).deleteFeedbackEntry(entry.id);
                Navigator.of(dialogContext).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feedback deleted.')),
                  );
                }
              },
              child: Text('Delete', style: DesignSystem.bodySm.copyWith(color: DesignSystem.error)),
            ),
            ElevatedButton(
              onPressed: () {
                final newStatus = statusController.text;
                ref.read(feedbackEntriesProvider.notifier).setStatus(entry.id, newStatus);
                ref.read(feedbackEntriesProvider.notifier).setAdminNote(entry.id, noteController.text);
                Navigator.of(dialogContext).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feedback updated.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: DesignSystem.bodySm.copyWith(color: DesignSystem.primary),
            softWrap: true,
            maxLines: isMultiline ? null : 1,
            overflow: isMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'new':
        return DesignSystem.secondary;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return DesignSystem.error;
      default:
        return DesignSystem.onSurfaceVariant;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'new': return 'New';
      case 'in_progress': return 'In Progress';
      case 'resolved': return 'Resolved';
      case 'rejected': return 'Rejected';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;
    final entries = ref.watch(feedbackEntriesProvider);
    final filtered = _applyFilters(entries);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isDesktop
                ? Wrap(
                    spacing: DesignSystem.spaceLg,
                    runSpacing: DesignSystem.spaceMd,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildPageTitle(),
                      Wrap(
                        spacing: DesignSystem.spaceMd,
                        runSpacing: DesignSystem.spaceMd,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            child: TextFormField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search feedback...',
                                prefixIcon: const Icon(Icons.search, size: 18),
                                hintStyle: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          _buildStatusFilter(),
                          ElevatedButton.icon(
                            onPressed: () => _exportCsv(filtered),
                            icon: const Icon(Icons.file_download, size: 16),
                            label: const Text('Export CSV'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPageTitle(),
                      const SizedBox(height: DesignSystem.spaceMd),
                      TextFormField(
                        controller: _searchController,
                        decoration: const InputDecoration(hintText: 'Search feedback...'),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: DesignSystem.spaceMd),
                      _buildStatusFilter(),
                      const SizedBox(height: DesignSystem.spaceMd),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _exportCsv(filtered),
                          icon: const Icon(Icons.file_download, size: 16),
                          label: const Text('Export CSV'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: DesignSystem.spaceXl),

            filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(
                        'No feedback entries found.',
                        style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: DesignSystem.spaceSm),
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      return Card(
                        child: ListTile(
                          onTap: () => _showDetailDialog(context, entry),
                          contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                          leading: CircleAvatar(
                            backgroundColor: _statusColor(entry.status).withValues(alpha: 0.15),
                            child: Icon(Icons.feedback_outlined, color: _statusColor(entry.status), size: 20),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  entry.subject,
                                  style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(entry.status).withValues(alpha: 0.15),
                                  borderRadius: DesignSystem.radiusSm,
                                ),
                                child: Text(
                                  _statusLabel(entry.status),
                                  style: DesignSystem.labelCaps.copyWith(
                                    color: _statusColor(entry.status),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                entry.message,
                                style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant, height: 1.4),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (entry.rating != null) ...[
                                    Icon(Icons.star, color: DesignSystem.secondaryContainer, size: 14),
                                    const SizedBox(width: 2),
                                    Text(entry.rating.toString(), style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                                  ],
                                  Text(_formatDate(entry.createdAt), style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                                  if (entry.userId != null) ...[
                                    Icon(Icons.person, color: DesignSystem.onSurfaceVariant.withValues(alpha: 0.5), size: 14),
                                    const SizedBox(width: 2),
                                    Text(entry.userId!, style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant, fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 1),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Feedback Management', style: DesignSystem.h2Mobile.copyWith(color: DesignSystem.primary)),
        const SizedBox(height: 4),
        Text('Review and manage visitor feedback and issue reports.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Wrap(
      spacing: DesignSystem.spaceSm,
      children: [
        _buildFilterChip('all', 'All'),
        _buildFilterChip('new', 'New'),
        _buildFilterChip('in_progress', 'In Progress'),
        _buildFilterChip('resolved', 'Resolved'),
        _buildFilterChip('rejected', 'Rejected'),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final selected = _filterStatus == value;
    return FilterChip(
      label: Text(label, style: DesignSystem.labelCaps.copyWith(
        color: selected ? Colors.white : DesignSystem.primary,
        fontSize: 10,
      )),
      selected: selected,
      onSelected: (_) {
        setState(() => _filterStatus = value);
      },
      backgroundColor: DesignSystem.surfaceContainer,
      selectedColor: DesignSystem.secondary,
      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusSm),
    );
  }
}

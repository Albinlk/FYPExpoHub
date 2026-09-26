import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/award_category.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/supabase_database_service.dart' show kEventSlug;
import '../../../../core/widgets/admin_actions.dart';

/// G-07: the admin manages award categories (title, description, order,
/// shown / hidden); winners are then filed under one.
class AwardCategoriesSection extends ConsumerWidget {
  const AwardCategoriesSection({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, [AwardCategoryItem? c]) async {
    final result = await showDialog<AwardCategoryItem>(context: context, builder: (_) => _CategoryDialog(category: c));
    if (result == null || !context.mounted) return;
    await runAdminWrite(context, () async {
      final db = ref.read(supabaseDbServiceProvider);
      await db.upsertAwardCategory(result.toRow(eventId: await db.resolveEventId(kEventSlug)));
      ref.invalidate(awardCategoriesProvider);
    }, success: c == null ? 'Category added.' : 'Category updated.');
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, AwardCategoryItem c) async {
    final ok = await confirmAction(
      context,
      title: 'Delete category',
      message: 'Delete "${c.title}"? Winners filed under it keep their record but lose the category.',
      confirmLabel: 'Delete',
    );
    if (!ok || !context.mounted) return;
    await runAdminWrite(context, () async {
      await ref.read(supabaseDbServiceProvider).deleteAwardCategory(c.id);
      ref.invalidate(awardCategoriesProvider);
    }, success: 'Category deleted.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(awardCategoriesProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Award Categories', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
                ),
                TextButton.icon(
                  onPressed: () => _edit(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add category'),
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spaceSm),
            categories.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Could not load categories: ${friendlyError(e)}'),
              data: (list) => list.isEmpty
                  ? Text(
                      'No categories yet. Add one, then file winners under it.',
                      style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                    )
                  : Column(
                      children: [
                        for (final c in list)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              c.isActive ? Icons.emoji_events : Icons.visibility_off,
                              color: c.isActive ? DesignSystem.secondary : DesignSystem.onSurfaceVariant,
                            ),
                            title: Text(c.title),
                            subtitle: Text(
                              [
                                if (!c.isActive) 'Hidden',
                                if ((c.description ?? '').isNotEmpty) c.description!,
                              ].join(' · '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Wrap(
                              children: [
                                IconButton(
                                  tooltip: 'Edit category',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _edit(context, ref, c),
                                ),
                                IconButton(
                                  tooltip: 'Delete category',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _delete(context, ref, c),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.category});

  final AwardCategoryItem? category;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final _title = TextEditingController(text: widget.category?.title ?? '');
  late final _description = TextEditingController(text: widget.category?.description ?? '');
  late final _order = TextEditingController(text: '${widget.category?.sortOrder ?? 0}');
  late bool _active = widget.category?.isActive ?? true;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _order.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('category-title'),
                controller: _title,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Title (e.g. Gold Innovation Award)'),
              ),
              TextField(
                controller: _description,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
              TextField(
                key: const Key('category-order'),
                controller: _order,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Display order (lower first)'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                title: const Text('Shown on the public Awards page'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _title.text.trim().isEmpty
              ? null
              : () => Navigator.pop(
                    context,
                    AwardCategoryItem(
                      id: widget.category?.id ?? '',
                      title: _title.text.trim(),
                      description: _description.text.trim(),
                      sortOrder: int.tryParse(_order.text.trim()) ?? 0,
                      status: _active ? 'active' : 'hidden',
                    ),
                  ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

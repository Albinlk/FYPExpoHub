/// An award category (`award_categories`), e.g. "Gold Innovation Award".
class AwardCategoryItem {
  const AwardCategoryItem({
    required this.id,
    required this.title,
    this.description,
    this.sortOrder = 0,
    this.status = 'active',
  });

  factory AwardCategoryItem.fromRow(Map<String, dynamic> m) => AwardCategoryItem(
        id: m['id'] as String? ?? '',
        title: m['title'] as String? ?? '',
        description: m['description'] as String?,
        sortOrder: (m['sort_order'] as num?)?.toInt() ?? 0,
        status: m['status'] as String? ?? 'active',
      );

  final String id;
  final String title;
  final String? description;
  final int sortOrder;

  /// active (shown publicly) | hidden
  final String status;

  bool get isActive => status == 'active';

  Map<String, dynamic> toRow({required String eventId}) => {
        if (id.isNotEmpty) 'id': id,
        'event_id': eventId,
        'title': title.trim(),
        'description': (description ?? '').trim().isEmpty ? null : description!.trim(),
        'sort_order': sortOrder,
        'status': status,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
}

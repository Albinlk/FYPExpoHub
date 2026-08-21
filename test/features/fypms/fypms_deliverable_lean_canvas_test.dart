import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_deliverable.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_lean_canvas.dart';
import 'package:fyp_expo_hub/core/utils/fypms_key_normalizer.dart';

Map<String, dynamic> _n(Map<String, dynamic> row) => normalizeFypmsKeys(row);

void main() {
  group('FypDeliverable model', () {
    test('serializes and round-trips', () {
      final deliverable = FypDeliverable.fromJson(_n({
        'id': 'del-1',
        'fyp_record_id': 'rec-1',
        'deliverable_type': 'proposal',
        'title': 'F1 Supervision Request',
        'description': 'Signed request form',
        'file_url': 'https://storage.example.com/del-1.pdf',
        'version': 2,
        'is_required': true,
        'submitted_by': 'stu-1',
        'submitted_at': '2026-08-10T09:00:00Z',
        'created_at': '2026-08-01T00:00:00Z',
        'updated_at': '2026-08-10T09:00:00Z',
      }));

      expect(deliverable.deliverableType, 'proposal');
      expect(deliverable.fileUrl, 'https://storage.example.com/del-1.pdf');
      expect(deliverable.version, 2);
      expect(deliverable.isRequired, isTrue);

      final json = deliverable.toJson();
      final roundTrip = FypDeliverable.fromJson(json);
      expect(roundTrip.id, 'del-1');
      expect(roundTrip.fypRecordId, 'rec-1');
      expect(roundTrip.title, 'F1 Supervision Request');
    });

    test('handles nullable fields', () {
      final deliverable = FypDeliverable.fromJson(_n({
        'id': 'del-2',
        'fyp_record_id': 'rec-1',
        'title': 'Project Video',
        'version': 1,
        'is_required': false,
        'created_at': '2026-08-01T00:00:00Z',
        'updated_at': '2026-08-01T00:00:00Z',
      }));

      expect(deliverable.deliverableType, isNull);
      expect(deliverable.fileUrl, isNull);
      expect(deliverable.description, isNull);
      expect(deliverable.isRequired, isFalse);
    });
  });

  group('FypLeanCanvas model', () {
    test('serializes and round-trips', () {
      final canvas = FypLeanCanvas.fromJson(_n({
        'id': 'lc-1',
        'fyp_record_id': 'rec-1',
        'canvas_version': 2,
        'blocks': <String, dynamic>{
          'problem': 'Students struggle to track FYP milestones.',
          'customerSegments': 'Final year students',
        },
        'is_latest': true,
        'created_at': '2026-08-02T10:00:00Z',
        'updated_at': '2026-08-03T10:00:00Z',
      }));

      expect(canvas.canvasVersion, 2);
      expect(canvas.isLatest, isTrue);
      expect(canvas.blocks['problem'], 'Students struggle to track FYP milestones.');
      expect(canvas.blocks['customerSegments'], 'Final year students');

      final json = canvas.toJson();
      final roundTrip = FypLeanCanvas.fromJson(json);
      expect(roundTrip.id, 'lc-1');
      expect(roundTrip.fypRecordId, 'rec-1');
      expect(roundTrip.canvasVersion, 2);
      expect(roundTrip.blocks['problem'], isNotNull);
    });
  });
}
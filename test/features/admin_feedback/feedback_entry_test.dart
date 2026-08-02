import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/feedback_entry.dart';
import 'package:fyp_expo_hub/features/admin_feedback/presentation/widgets/feedback_csv_export.dart';

void main() {
  group('FeedbackEntry model', () {
    test('can be created and serialized/deserialized', () {
      final entry = FeedbackEntry(
        id: 'test-123',
        userId: 'user-456',
        eventId: 'fskm-fyp-2026',
        subject: 'Test Subject',
        message: 'Test message body',
        rating: 5,
        status: 'new',
        createdAt: DateTime(2026, 8, 2, 12, 0, 0),
        updatedAt: DateTime(2026, 8, 2, 12, 0, 0),
      );

      final json = entry.toJson();
      final roundTrip = FeedbackEntry.fromJson(json);

      expect(roundTrip.id, entry.id);
      expect(roundTrip.userId, entry.userId);
      expect(roundTrip.subject, entry.subject);
      expect(roundTrip.message, entry.message);
      expect(roundTrip.rating, entry.rating);
      expect(roundTrip.status, entry.status);
    });

    test('copyWith works correctly', () {
      final entry = FeedbackEntry(
        id: 'test-123',
        eventId: 'fskm-fyp-2026',
        subject: 'Original',
        message: 'Original message',
        createdAt: DateTime(2026, 8, 2),
        updatedAt: DateTime(2026, 8, 2),
      );

      final updated = entry.copyWith(
        status: 'resolved',
        adminNote: 'Fixed in v2.1',
      );

      expect(updated.status, 'resolved');
      expect(updated.adminNote, 'Fixed in v2.1');
      expect(updated.id, 'test-123');
    });

    test('rating and userId are nullable for anonymous feedback', () {
      final entry = FeedbackEntry(
        id: 'anon-456',
        eventId: 'fskm-fyp-2026',
        subject: 'Bug report',
        message: 'Something is broken',
        createdAt: DateTime(2026, 8, 2),
        updatedAt: DateTime(2026, 8, 2),
      );

      expect(entry.userId, isNull);
      expect(entry.rating, isNull);
      expect(entry.status, 'new');
    });

    test('toJson handles nullable fields', () {
      final entry = FeedbackEntry(
        id: 'test-789',
        eventId: 'fskm-fyp-2026',
        subject: 'Subject',
        message: 'Message',
        createdAt: DateTime(2026, 8, 2),
        updatedAt: DateTime(2026, 8, 2),
      );

      final json = entry.toJson();
      expect(json['userId'], isNull);
      expect(json['rating'], isNull);
      expect(json['adminNote'], isNull);
    });
  });

  group('CSV export', () {
    test('escapeCsv does not quote simple strings', () {
      expect(escapeCsv('hello'), 'hello');
      expect(escapeCsv('test subject'), 'test subject');
    });

    test('escapeCsv quotes strings with commas', () {
      expect(escapeCsv('hello, world'), '"hello, world"');
    });

    test('escapeCsv quotes and escapes strings with double quotes', () {
      expect(escapeCsv('say "hi"'), '"say ""hi"""');
    });

    test('escapeCsv quotes strings with newlines', () {
      expect(escapeCsv('line1\nline2'), '"line1\nline2"');
    });

    test('exportFeedbackCsv generates correct header and rows', () {
      final entries = [
        FeedbackEntry(
          id: 'entry-1',
          eventId: 'fskm-fyp-2026',
          subject: 'Great site',
          message: 'Loved it',
          rating: 5,
          status: 'new',
          createdAt: DateTime(2026, 8, 2, 10, 0),
          updatedAt: DateTime(2026, 8, 2, 10, 0),
        ),
        FeedbackEntry(
          id: 'entry-2',
          userId: null,
          eventId: 'fskm-fyp-2026',
          subject: 'Bug, found',
          message: 'Something\'s "broken"',
          rating: null,
          status: 'resolved',
          adminNote: 'Fixed',
          createdAt: DateTime(2026, 8, 2, 11, 0),
          updatedAt: DateTime(2026, 8, 2, 12, 0),
        ),
      ];

      final csv = exportFeedbackCsv(entries);
      final lines = csv.split('\n');

      expect(lines[0], 'ID,User ID,Subject,Message,Rating,Status,Admin Note,Created At,Updated At');
      expect(lines[1], contains('entry-1,'));
      expect(lines[1], contains('Great site'));
      expect(lines[1], contains(',5,'));
      expect(lines[2], contains('"Bug, found"'));
      expect(lines[2], contains('"Something\'s ""broken"""'));
      expect(lines[2], contains(',,'));
      expect(lines[2], contains('Fixed'));
    });

    test('exportFeedbackCsv handles empty list', () {
      final csv = exportFeedbackCsv([]);
      final lines = csv.split('\n');
      expect(lines[0], 'ID,User ID,Subject,Message,Rating,Status,Admin Note,Created At,Updated At');
    });
  });
}

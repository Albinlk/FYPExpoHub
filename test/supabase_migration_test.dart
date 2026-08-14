import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/domain/models/schedule_item.dart';
import 'package:fyp_expo_hub/core/domain/models/student_visit.dart';
import 'package:fyp_expo_hub/core/domain/models/import_models.dart';

void main() {
  group('Supabase Migration & Data Model Tests', () {
    test('Project serialization retains matricId and converts successfully', () {
      final now = DateTime.now();
      final project = Project(
        id: 'proj-001',
        eventId: 'fskm-fyp-2026',
        slug: 'ai-crop-disease-detection',
        title: 'AI Crop Disease Detection System',
        matricId: '2023456789',
        programmeCode: 'CS230',
        programmeName: 'Bachelor of Computer Science (Hons.)',
        shortDescription: 'Computer vision deep learning model for real-time crop disease diagnosis.',
        category: 'AI & Machine Learning',
        technologyTags: ['Flutter', 'Python', 'TensorFlow', 'PostgreSQL'],
        coverImageUrl: 'https://example.com/cover.jpg',
        teamDisplayNames: ['AHMAD BIN ALI (2023456789)'],
        supervisorDisplayName: 'DR. SITI AISHAH BINTI HASHIM',
        featured: true,
        calonIndustri: true,
        publicationStatus: 'published',
        createdAt: now,
        updatedAt: now,
      );

      final json = project.toJson();
      expect(json['id'], equals('proj-001'));
      expect(json['matricId'], equals('2023456789'));
      expect(json['calonIndustri'], isTrue);
      expect(json['publicationStatus'], equals('published'));

      final restored = Project.fromJson(json);
      expect(restored.id, equals('proj-001'));
      expect(restored.matricId, equals('2023456789'));
      expect(restored.technologyTags, contains('PostgreSQL'));
    });

    test('ScheduleItem serialization parses correctly', () {
      final now = DateTime.now();
      final item = ScheduleItem(
        id: 'sch-001',
        eventId: 'fskm-fyp-2026',
        date: DateTime(2026, 8, 6),
        startAt: '09:00',
        endAt: '10:00',
        title: 'Opening Ceremony & Keynote',
        venue: 'Main Auditorium',
        audience: 'General',
        visibility: 'public',
        publicationStatus: 'published',
        createdAt: now,
        updatedAt: now,
      );

      final json = item.toJson();
      expect(json['title'], equals('Opening Ceremony & Keynote'));
      expect(json['visibility'], equals('public'));

      final restored = ScheduleItem.fromJson(json);
      expect(restored.title, equals(item.title));
      expect(restored.startAt, equals('09:00'));
    });

    test('StudentVisit model serialization with void metadata', () {
      final now = DateTime.now();
      final visit = StudentVisit(
        id: 'vis-001',
        eventId: 'fskm-fyp-2026',
        projectId: 'proj-001',
        assignmentId: 'asgn-001',
        lecturerId: 'lect-001',
        visitRole: 'supervisor',
        status: 'voided',
        visitedAt: now.subtract(const Duration(minutes: 10)),
        visitNote: 'Initial assessment completed.',
        source: 'lecturer',
        voidedAt: now,
        voidedBy: 'admin-001',
        voidReason: 'Marked under incorrect candidate booth.',
        createdAt: now,
        updatedAt: now,
      );

      final json = visit.toJson();
      expect(json['status'], equals('voided'));
      expect(json['voidReason'], equals('Marked under incorrect candidate booth.'));

      final restored = StudentVisit.fromJson(json);
      expect(restored.status, equals('voided'));
      expect(restored.voidedBy, equals('admin-001'));
    });

    test('Import models support candidate staging without file storage', () {
      final now = DateTime.now();
      final record = ImportRecord(
        id: 'imp-001',
        eventId: 'fskm-fyp-2026',
        sourceFilePath: 'Master_FYP_2026.xlsx',
        sourceFileName: 'Master_FYP_2026.xlsx',
        sourceFileHash: 'hash-12345',
        uploadedBy: 'admin@uitm.edu.my',
        uploadedAt: now,
        parserVersion: '2.0.0-supabase',
        status: 'staged',
        summary: {'schedule': 12, 'winners': 8},
        warningCounts: {'skips': 2, 'issues': 0},
      );

      final json = record.toJson();
      expect(json['sourceFileName'], equals('Master_FYP_2026.xlsx'));
      expect(json['status'], equals('staged'));
      expect(json['summary']['schedule'], equals(12));
    });
  });
}

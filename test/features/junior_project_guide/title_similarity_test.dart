import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/features/junior_project_guide/domain/title_similarity.dart';

void main() {
  group('TitleSimilarity - isPlaceholderTitle', () {
    test('flags the real "CS251 PROPOSAL - <name>" pattern found in the '
        'live CSP600 CSV (35/103 rows)', () {
      expect(
        TitleSimilarity.isPlaceholderTitle(
            'CS251 PROPOSAL - FARHANA AZREEN BINTI AZEMIL'),
        isTrue,
      );
    });

    test('flags the real "TBD (Project Title Pending)" title found twice '
        'in the live CSP650 dataset', () {
      expect(
        TitleSimilarity.isPlaceholderTitle('TBD (Project Title Pending)'),
        isTrue,
      );
    });

    test('flags an empty title', () {
      expect(TitleSimilarity.isPlaceholderTitle(''), isTrue);
      expect(TitleSimilarity.isPlaceholderTitle('   '), isTrue);
    });

    test('does not flag a real project title', () {
      expect(
        TitleSimilarity.isPlaceholderTitle(
            'MACHINE LEARNING BASED INTRUSION DETECTION SYSTEM'),
        isFalse,
      );
    });
  });

  group('TitleSimilarity - titleTokens', () {
    test('strips stopwords, course codes, and normalizes plurals', () {
      final p = _project(
        id: 'a',
        title: 'A Machine Learning System for Network Intrusion Detections',
      );
      final tokens = TitleSimilarity.titleTokens(p);
      expect(tokens, containsAll(['machine', 'learning', 'network', 'intrusion', 'detection']));
      // stopwords/boilerplate must be gone
      expect(tokens, isNot(contains('a')));
      expect(tokens, isNot(contains('for')));
      expect(tokens, isNot(contains('system')));
      // "detections" -> "detection" (crude pluralization normalization)
      expect(tokens, isNot(contains('detections')));
    });

    test('strips a leading programme code token like "cs600"', () {
      final p = _project(id: 'a', title: 'CS600 Smart Irrigation System');
      expect(TitleSimilarity.titleTokens(p), isNot(contains('cs600')));
    });

    test('a placeholder title yields no tokens', () {
      final p = _project(id: 'a', title: 'CS251 PROPOSAL - JOHN DOE BIN ALI');
      expect(TitleSimilarity.titleTokens(p), isEmpty);
    });
  });

  group('TitleSimilarity - sharedTitleWordCount / titleJaccard', () {
    test('counts overlapping significant words and computes their Jaccard '
        'ratio', () {
      final a = _project(id: 'a', title: 'Machine Learning Intrusion Detection System');
      final b = _project(id: 'b', title: 'Deep Learning Intrusion Detection for IoT');
      // tokens(a) = {machine, learning, intrusion, detection} ("system" is
      // a stripped stopword)
      // tokens(b) = {deep, learning, intrusion, detection, iot} ("for" is
      // a stripped stopword)
      // shared = {learning, intrusion, detection} = 3; union = 6 -> 0.5
      expect(TitleSimilarity.sharedTitleWordCount(a, b), 3);
      expect(TitleSimilarity.titleJaccard(a, b), closeTo(0.5, 0.0001));
    });

    test('jaccard of two placeholder titles is 0.0 (never matches)', () {
      final a = _project(id: 'a', title: 'CS251 PROPOSAL - A');
      final b = _project(id: 'b', title: 'CS251 PROPOSAL - B');
      expect(TitleSimilarity.titleJaccard(a, b), 0.0);
    });
  });

  group('TitleSimilarity - buildTitleClusters (validated against real '
      'title pairs from the live dataset)', () {
    test('two near-identically-worded real titles cluster', () {
      // Real CSP600 titles (jaccard 0.5 shared=[web,testing,penetration]
      // when validated against the live dataset).
      final a = _project(
          id: 'a', title: 'AUTOMATED PENETRATION TESTING FOR WEB APPLICATION');
      final b = _project(
          id: 'b',
          title: 'WEB VULNERABILITY SCANNING AND PENETRATION TESTING SYSTEM');

      final clusters = TitleSimilarity.buildTitleClusters([a, b]);
      expect(clusters, hasLength(1));
      expect(clusters.first.count, 2);
      expect(clusters.first.sharedWords, containsAll(['web', 'penetration', 'testing']));
    });

    test('two titles sharing too few significant words do NOT cluster '
        '(below minSharedTitleWords — only "web" is common here)', () {
      final a = _project(id: 'a', title: 'Smart Web Dashboard for Student Management');
      final b = _project(id: 'b', title: 'Interactive Web Portal for Staff Records');
      final clusters = TitleSimilarity.buildTitleClusters([a, b]);
      expect(clusters, isEmpty);
    });

    test('a placeholder-titled project never joins a cluster even if its '
        'literal text would otherwise overlap', () {
      final placeholder =
          _project(id: 'a', title: 'CS251 PROPOSAL - MACHINE LEARNING FAN');
      final real1 = _project(
          id: 'b', title: 'MACHINE LEARNING BASED PHISHING DETECTION SYSTEM');
      final real2 = _project(
          id: 'c', title: 'MACHINE LEARNING BASED MALWARE DETECTION SYSTEM');

      final clusters =
          TitleSimilarity.buildTitleClusters([placeholder, real1, real2]);
      // real1/real2 may or may not cluster depending on shared word count,
      // but the placeholder must never appear in any cluster.
      for (final c in clusters) {
        expect(c.projects.map((p) => p.id), isNot(contains('a')));
      }
    });

    test('a matched cluster\'s impliedCategories reflects the shared topic',
        () {
      final a = _project(
          id: 'a', title: 'MACHINE LEARNING BASED NETWORK INTRUSION DETECTION SYSTEM');
      final b = _project(
          id: 'b',
          title:
              'DEEP LEARNING BASED NETWORK INTRUSION DETECTION AND ALERTING SYSTEM');

      final clusters = TitleSimilarity.buildTitleClusters([a, b]);
      expect(clusters, hasLength(1));
      // Shared words should include enough of "network"/"intrusion"/
      // "detection" to infer a Network Security / IDS topic label.
      expect(clusters.first.impliedCategories, isNotEmpty);
    });

    test('fewer than 2 projects returns no clusters', () {
      final a = _project(id: 'a', title: 'Some Project');
      expect(TitleSimilarity.buildTitleClusters([a]), isEmpty);
      expect(TitleSimilarity.buildTitleClusters([]), isEmpty);
    });
  });
}

Project _project({required String id, required String title}) {
  return Project(
    id: id,
    eventId: 'fskm-fyp-2026',
    slug: id,
    title: title,
    matricId: null,
    programmeCode: 'CS236',
    programmeName: 'Computer Science',
    shortDescription: 'Test description',
    category: 'Computer Science',
    technologyTags: const [],
    coverImageUrl: 'assets/images/project_placeholder.jpg',
    teamDisplayNames: const ['Tester'],
    supervisorDisplayName: 'Dr. Test',
    examinerDisplayName: null,
    featured: false,
    calonIndustri: false,
    publicationStatus: 'published',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    publishedAt: DateTime.now(),
  );
}

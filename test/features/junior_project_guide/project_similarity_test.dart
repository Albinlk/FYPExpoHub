import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/features/junior_project_guide/domain/project_similarity.dart';

void main() {
  group('ProjectSimilarity - tag normalization', () {
    test('tagSet lowercases and trims tags', () {
      final p = _project(
        id: 'a',
        tags: ['Flutter', '  firebase  ', 'AR Core', 'FLUTTER'],
      );
      final tags = ProjectSimilarity.tagSet(p);
      expect(tags, containsAll(['flutter', 'firebase', 'ar core']));
      expect(tags.length, 3); // duplicates removed via Set
    });

    test('empty tags returns empty set', () {
      final p = _project(id: 'a', tags: []);
      expect(ProjectSimilarity.tagSet(p), isEmpty);
    });
  });

  group('ProjectSimilarity - shared tag count', () {
    test('counts overlapping tags (case-insensitive)', () {
      final a = _project(id: 'a', tags: ['Flutter', 'Firebase', 'AR Core']);
      final b = _project(id: 'b', tags: ['flutter', 'firebase', 'Unity']);
      expect(ProjectSimilarity.sharedTagCount(a, b), 2);
    });

    test('zero shared tags', () {
      final a = _project(id: 'a', tags: ['Flutter', 'Dart']);
      final b = _project(id: 'b', tags: ['React', 'TypeScript']);
      expect(ProjectSimilarity.sharedTagCount(a, b), 0);
    });

    test('all tags shared', () {
      final a = _project(id: 'a', tags: ['A', 'B']);
      final b = _project(id: 'b', tags: ['A', 'B']);
      expect(ProjectSimilarity.sharedTagCount(a, b), 2);
    });
  });

  group('ProjectSimilarity - Jaccard similarity', () {
    test('Jaccard of disjoint sets is 0', () {
      final a = _project(id: 'a', tags: ['A', 'B']);
      final b = _project(id: 'b', tags: ['C', 'D']);
      expect(ProjectSimilarity.jaccardSimilarity(a, b), 0.0);
    });

    test('Jaccard of identical sets is 1.0', () {
      final a = _project(id: 'a', tags: ['A', 'B', 'C']);
      final b = _project(id: 'b', tags: ['A', 'B', 'C']);
      expect(ProjectSimilarity.jaccardSimilarity(a, b), 1.0);
    });

    test('Jaccard of half-overlap is 0.333', () {
      final a = _project(id: 'a', tags: ['A', 'B']);
      final b = _project(id: 'b', tags: ['A', 'C']);
      expect(ProjectSimilarity.jaccardSimilarity(a, b), closeTo(1.0 / 3, 0.001));
    });

    test('Jaccard of two empty sets is 0', () {
      final a = _project(id: 'a', tags: []);
      final b = _project(id: 'b', tags: []);
      expect(ProjectSimilarity.jaccardSimilarity(a, b), 0.0);
    });
  });

  group('ProjectSimilarity - findSimilar / similarCount', () {
    test('similarCount returns projects sharing 3+ tags', () {
      final a = _project(
          id: 'a', tags: ['flutter', 'firebase', 'ar core', 'dart']);
      final b = _project(
          id: 'b', tags: ['flutter', 'firebase', 'ar core', 'unity']);
      final c = _project(
          id: 'c', tags: ['flutter', 'firebase', 'web scraping']);

      // Verify shared tags first
      expect(ProjectSimilarity.sharedTagCount(a, b), 3);
      expect(ProjectSimilarity.sharedTagCount(a, c), 2);

      // similarCount for a should find b (3 shared tags)
      final simA = ProjectSimilarity.findSimilar(a, [a, b, c]);
      expect(simA.length, 1);
      expect(simA.first.id, 'b');

      // similarCount for c should find none (only 2 shared with each)
      final simC = ProjectSimilarity.findSimilar(c, [a, b, c]);
      expect(simC.length, 0);
    });

    test('exclude self from similar list', () {
      final a = _project(id: 'a', tags: ['A', 'B', 'C', 'D']);
      final all = [a];
      expect(ProjectSimilarity.findSimilar(a, all), isEmpty);
    });
  });

  group('ProjectSimilarity - buildClusters', () {
    test('returns empty when fewer than 2 projects', () {
      final projects = [_project(id: 'a', tags: ['A', 'B', 'C'])];
      expect(ProjectSimilarity.buildClusters(projects), isEmpty);
    });

    test('clusters projects sharing 3+ tags (union-find transitive)', () {
      // A shares 3 tags with B, B shares 3 with C, but A and C share only 2.
      // Union-find should still group A, B, C together because A~B and B~C.
      final a = _project(id: 'a', tags: ['X', 'Y', 'Z', 'A']);
      final b = _project(id: 'b', tags: ['X', 'Y', 'Z', 'B']);
      final c = _project(id: 'c', tags: ['X', 'Y', 'Z', 'C']);

      final clusters = ProjectSimilarity.buildClusters([a, b, c]);
      expect(clusters.length, 1);
      expect(clusters.first.count, 3);
      expect(clusters.first.sharedTags, containsAll(['x', 'y', 'z']));
    });

    test('does not cluster projects sharing fewer than 3 tags', () {
      final a = _project(id: 'a', tags: ['A', 'B']);
      final b = _project(id: 'b', tags: ['A', 'B']);
      final clusters = ProjectSimilarity.buildClusters([a, b]);
      expect(clusters, isEmpty);
    });

    test('handles projects with no tags — no clusters', () {
      final a = _project(id: 'a', tags: []);
      final b = _project(id: 'b', tags: []);
      expect(ProjectSimilarity.buildClusters([a, b]), isEmpty);
    });

    test('multiple independent clusters', () {
      final a = _project(id: 'a', tags: ['X', 'Y', 'Z', 'A']);
      final b = _project(id: 'b', tags: ['X', 'Y', 'Z', 'B']);
      final c = _project(id: 'c', tags: ['P', 'Q', 'R', 'S']);
      final d = _project(id: 'd', tags: ['P', 'Q', 'R', 'T']);

      final clusters = ProjectSimilarity.buildClusters([a, b, c, d]);
      expect(clusters.length, 2);
      expect(clusters.first.count, 2);
      expect(clusters.last.count, 2);
    });

    test('clusters sorted by size descending', () {
      final a = _project(id: 'a', tags: ['X', 'Y', 'Z', 'A']);
      final b = _project(id: 'b', tags: ['X', 'Y', 'Z', 'B']);
      final c = _project(id: 'c', tags: ['X', 'Y', 'Z', 'C']);
      final d = _project(id: 'd', tags: ['X', 'Y', 'Z', 'D']);
      final e = _project(id: 'e', tags: ['P', 'Q', 'R', 'S']);
      final f = _project(id: 'f', tags: ['P', 'Q', 'R', 'T']);

      final clusters = ProjectSimilarity.buildClusters([a, b, c, d, e, f]);
      expect(clusters.length, 2);
      expect(clusters.first.count, 4);
      expect(clusters.last.count, 2);
    });
  });

  group('ProjectSimilarity - categoryTags', () {
    test('passes through tags already in knownCategories unchanged', () {
      final p = _project(id: 'a', tags: ['Machine Learning', 'AI / XAI']);
      expect(
        ProjectSimilarity.categoryTags(p),
        {'Machine Learning', 'AI / XAI'},
      );
    });

    // Every raw tag actually used in assets/data/csp600-proposals.csv,
    // mapped to the category bucket it must resolve to so the Tech Stack
    // filter shows one consistent vocabulary across CSP650 (already
    // category-tagged) and CSP600 (raw free-text tags) projects.
    const rawTagToCategory = {
      '5G': 'Networking',
      'AI': 'AI / General',
      'Android': 'Mobile App',
      'Anomaly Detection': 'Network Security / IDS',
      'Artificial Intelligence': 'AI / XAI',
      'Blockchain': 'Blockchain',
      'Cloud Computing': 'Cloud / DevOps',
      'Cyber-Physical Systems': 'IoT / Embedded',
      'Dashboard': 'Web / Dashboard',
      'DDoS': 'Network Security / IDS',
      'Decision Tree': 'Machine Learning',
      'Deepfake': 'Deep Learning / CV',
      'Digital Forensics': 'Cybersecurity',
      'DNS': 'Networking',
      'Docker': 'Cloud / DevOps',
      'Document Management': 'Web / Dashboard',
      'Email Security': 'Cybersecurity',
      'ESP32': 'IoT / Embedded',
      'Explainable AI': 'AI / XAI',
      'Face Recognition': 'Mobile App',
      'Fingerprint': 'Mobile App',
      'GNS3': 'Networking',
      'Honeypot': 'Cybersecurity',
      'HTTP/3': 'Networking',
      'Intrusion Detection': 'Network Security / IDS',
      'IoT': 'IoT / Embedded',
      'IoT Mesh': 'IoT / Embedded',
      'LLM': 'LLM',
      'Load Balancing': 'Networking',
      'LoRa': 'IoT / Embedded',
      'Machine Learning': 'Machine Learning',
      'Malware': 'Cybersecurity',
      'Mininet': 'Networking',
      'Mobile App': 'Mobile App',
      'Monitoring Dashboard': 'Web / Dashboard',
      'MQTT': 'IoT / Embedded',
      'NAS': 'Cloud / DevOps',
      'NestJS': 'Web / Dashboard',
      'Network Forensics': 'Network Security / IDS',
      'Network Traffic Analysis': 'Network Security / IDS',
      'NIDS': 'Network Security / IDS',
      'OSPF': 'Networking',
      'Phishing': 'Cybersecurity',
      'QR Code Security': 'Cybersecurity',
      'Radio-over-IP': 'Networking',
      'Random Forest': 'Machine Learning',
      'Ransomware': 'Cybersecurity',
      'SDN': 'Networking',
      'Smishing Detection': 'Cybersecurity',
      'Snort': 'Network Security / IDS',
      'TCP': 'Networking',
      'UDP': 'Networking',
      'VLAN': 'Networking',
      'VoIP': 'Networking',
      'VPN': 'Networking',
      'Vulnerability Scanning': 'Cybersecurity',
      'Web Application': 'Web / Dashboard',
      'Wi-Fi': 'Networking',
      'Wireshark': 'Network Security / IDS',
      'Zero Trust': 'Cybersecurity',
    };

    rawTagToCategory.forEach((rawTag, expectedCategory) {
      test('"$rawTag" categorizes to "$expectedCategory"', () {
        final p = _project(id: 'a', tags: [rawTag]);
        expect(ProjectSimilarity.categoryTags(p), contains(expectedCategory));
      });
    });

    test('a project with no tags falls back to title inference', () {
      final p = _project(id: 'a', tags: const [], title: 'Blockchain Voting App');
      expect(ProjectSimilarity.categoryTags(p), contains('Blockchain'));
    });

    // These four category names existed in the live dataset (1-4 projects
    // each) before being folded into a larger neighbor. They're no longer
    // in knownCategories, so a project still carrying one of these exact
    // legacy tags must be re-bucketed via inferTagsFromTitle, not passed
    // through unchanged.
    const mergedLegacyTagToCategory = {
      'Reinforcement Learning': 'Machine Learning',
      'Generative AI / RAG': 'LLM',
      'Knowledge Graph': 'NLP / Transformer',
      'GIS / Navigation': 'Data Analytics',
    };

    mergedLegacyTagToCategory.forEach((legacyTag, expectedCategory) {
      test('legacy tag "$legacyTag" is re-bucketed to "$expectedCategory"', () {
        final p = _project(id: 'a', tags: [legacyTag]);
        final tags = ProjectSimilarity.categoryTags(p);
        expect(tags, contains(expectedCategory));
        expect(tags, isNot(contains(legacyTag)),
            reason: 'merged category should not pass through unchanged');
      });
    });

    test('knownCategories no longer contains the four merged categories', () {
      expect(ProjectSimilarity.knownCategories, hasLength(19));
      for (final legacyTag in mergedLegacyTagToCategory.keys) {
        expect(ProjectSimilarity.knownCategories.contains(legacyTag), isFalse);
      }
    });
  });

  group('ProjectSimilarity - category-based clustering (cross-cohort fix)', () {
    test(
        'a CSP600-style raw-tag project and a CSP650-style category-tag '
        'project are seen as sharing 2 categories, despite zero raw-string '
        'overlap', () {
      // CSP600 style: genuinely raw, free-text tags. MQTT -> IoT / Embedded,
      // Wi-Fi -> Networking (two DISTINCT categories from two raw tags).
      final csp600Style = _project(id: 'a', tags: ['MQTT', 'Wi-Fi']);
      // CSP650 style: already-standardized category tags.
      final csp650Style =
          _project(id: 'b', tags: ['IoT / Embedded', 'Networking']);

      // Raw literal tags never intersect.
      expect(ProjectSimilarity.tagSet(csp600Style),
          isNot(containsAll(ProjectSimilarity.tagSet(csp650Style))));

      final categoryIndex = ProjectSimilarity.buildCategoryTagIndex(
          [csp600Style, csp650Style]);
      expect(
        ProjectSimilarity.sharedTagCount(csp600Style, csp650Style,
            tagIndex: categoryIndex),
        greaterThanOrEqualTo(ProjectSimilarity.minSharedCategoriesForCluster),
      );
    });

    test('buildClusters with a category index and minShared clusters the '
        'cross-cohort pair', () {
      final csp600Style = _project(id: 'a', tags: ['MQTT', 'Wi-Fi']);
      final csp650Style =
          _project(id: 'b', tags: ['IoT / Embedded', 'Networking']);
      final categoryIndex = ProjectSimilarity.buildCategoryTagIndex(
          [csp600Style, csp650Style]);

      final clusters = ProjectSimilarity.buildClusters(
        [csp600Style, csp650Style],
        tagIndex: categoryIndex,
        minShared: ProjectSimilarity.minSharedCategoriesForCluster,
      );

      expect(clusters, hasLength(1));
      expect(clusters.first.count, 2);
      expect(clusters.first.sharedTags,
          containsAll(['IoT / Embedded', 'Networking']));
    });

    test('two projects sharing exactly 1 category are NOT clustered', () {
      final a = _project(id: 'a', tags: ['IoT / Embedded']);
      final b = _project(id: 'b', tags: ['IoT / Embedded', 'Networking']);
      final categoryIndex = ProjectSimilarity.buildCategoryTagIndex([a, b]);

      final clusters = ProjectSimilarity.buildClusters(
        [a, b],
        tagIndex: categoryIndex,
        minShared: ProjectSimilarity.minSharedCategoriesForCluster,
      );

      expect(clusters, isEmpty);
    });

    test('buildClusters/computeSimilarityCounts default to raw-tag, '
        'threshold-3 behavior when minShared/category index are omitted '
        '(backward compatibility)', () {
      final a = _project(id: 'a', tags: ['X', 'Y', 'Z', 'A']);
      final b = _project(id: 'b', tags: ['X', 'Y', 'Z', 'B']);
      final c = _project(id: 'c', tags: ['X', 'Y']); // only 2 shared with a/b

      final clusters = ProjectSimilarity.buildClusters([a, b, c]);
      expect(clusters, hasLength(1));
      expect(clusters.first.count, 2); // only a+b (3 shared), not c (2 shared)

      final counts = ProjectSimilarity.computeSimilarityCounts([a, b, c]);
      expect(counts['a'], 1);
      expect(counts['c'], 0);
    });

    test('computeSimilarityCounts finds the cross-cohort pair only when '
        'given the category index + threshold 2, not with the raw-tag '
        'default', () {
      final csp600Style = _project(id: 'a', tags: ['MQTT', 'Wi-Fi']);
      final csp650Style =
          _project(id: 'b', tags: ['IoT / Embedded', 'Networking']);

      final rawCounts =
          ProjectSimilarity.computeSimilarityCounts([csp600Style, csp650Style]);
      expect(rawCounts['a'], 0);
      expect(rawCounts['b'], 0);

      final categoryIndex = ProjectSimilarity.buildCategoryTagIndex(
          [csp600Style, csp650Style]);
      final categoryCounts = ProjectSimilarity.computeSimilarityCounts(
        [csp600Style, csp650Style],
        tagIndex: categoryIndex,
        minShared: ProjectSimilarity.minSharedCategoriesForCluster,
      );
      expect(categoryCounts['a'], 1);
      expect(categoryCounts['b'], 1);
    });
  });

  group('ProjectSimilarity - clusterCohesion', () {
    test('identical tag sets have cohesion 1.0', () {
      final a = _project(id: 'a', tags: ['Networking', 'IoT / Embedded']);
      final b = _project(id: 'b', tags: ['Networking', 'IoT / Embedded']);
      expect(ProjectSimilarity.clusterCohesion([a, b]), 1.0);
    });

    test('partial overlap averages correctly across a 3-member cluster', () {
      final a = _project(id: 'a', tags: ['X', 'Y']);
      final b = _project(id: 'b', tags: ['X', 'Y']);
      final c = _project(id: 'c', tags: ['X', 'Z']);
      // a-b: intersection 2, union 2 -> 1.0
      // a-c: intersection 1, union 3 -> 1/3
      // b-c: intersection 1, union 3 -> 1/3
      final expected = (1.0 + 1 / 3 + 1 / 3) / 3;
      expect(ProjectSimilarity.clusterCohesion([a, b, c]), closeTo(expected, 0.0001));
    });

    test('a single-member list has cohesion 0.0 (defensive)', () {
      final a = _project(id: 'a', tags: ['X']);
      expect(ProjectSimilarity.clusterCohesion([a]), 0.0);
    });
  });
}

Project _project({
  required String id,
  required List<String> tags,
  String title = 'Test Project',
  String supervisor = 'Dr. Test',
  String programme = 'CS236',
  String category = 'Computer Science',
}) {
  return Project(
    id: id,
    eventId: 'fskm-fyp-2026',
    slug: id,
    title: title,
    matricId: null,
    programmeCode: programme,
    programmeName: programme,
    shortDescription: 'Test description',
    category: category,
    technologyTags: tags,
    coverImageUrl: 'assets/images/project_placeholder.jpg',
    teamDisplayNames: ['Tester'],
    supervisorDisplayName: supervisor,
    examinerDisplayName: null,
    featured: false,
    calonIndustri: false,
    publicationStatus: 'published',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    publishedAt: DateTime.now(),
  );
}

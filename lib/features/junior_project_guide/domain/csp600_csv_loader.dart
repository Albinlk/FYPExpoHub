import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/domain/models/project.dart';
import '../../../core/utils/logger.dart';

/// Loader for CSP600 project proposal data.
///
/// Resolution order:
/// 1. Supabase Storage bucket `csp600-proposals` / object `csp600-proposals.csv`
/// 2. Bundled asset `assets/data/csp600-proposals.csv`
/// 3. Empty list (no crash)
///
/// CSV columns (case-insensitive, trimmed):
///   title*, technology_tags (semicolon-separated),
///   supervisor_display_name, programme_code, short_description,
///   category, team_display_names (semicolon-separated),
///   booth_number, booth_zone, demo_url
class Csp600CsvLoader {
  static const csvAssetPath = 'assets/data/csp600-proposals.csv';
  static const storageBucket = 'csp600-proposals';
  static const storageObject = 'csp600-proposals.csv';

  /// Loads CSP600 proposals as [Project] objects.
  /// Each project gets a synthetic id: `csp600-{rowIndex}`.
  static Future<List<Project>> load() async {
    List<String> csvLines;
    String source = 'unknown';

    // 1. Try Supabase Storage
    try {
      final client = Supabase.instance.client;
      final res = await client.storage
          .from(storageBucket)
          .download(storageObject);
      csvLines = utf8.decode(res).split('\n');
      source = 'supabase-storage';
    } catch (e) {
      logDebug('Csp600CsvLoader: Supabase Storage fetch failed, '
          'falling back to bundled asset: $e');
      // 2. Try bundled asset
      try {
        final raw = await rootBundle.loadString(csvAssetPath);
        csvLines = const LineSplitter().convert(raw);
        source = 'bundled-asset';
      } catch (assetErr) {
        logDebug('Csp600CsvLoader: No bundled CSV asset available. '
            'Returning empty list: $assetErr');
        return [];
      }
    }

    logDebug('Csp600CsvLoader: Loaded from $source (${csvLines.length} lines)');
    return _parseCsv(csvLines);
  }

  static List<Project> _parseCsv(List<String> csvLines) {
    final csv = const CsvToListConverter().convert(csvLines.join('\n'), eol: '\n');

    if (csv.isEmpty) return [];

    final headers = csv.first
        .map((h) => h.toString().trim().toLowerCase())
        .toList();
    final colIndex = <String, int>{};
    for (int i = 0; i < headers.length; i++) {
      colIndex[headers[i]] = i;
    }

    final projects = <Project>[];
    final now = DateTime.now();

    for (int r = 1; r < csv.length; r++) {
      final row = csv[r];
      if (row.length < headers.length) continue;
      if (row.every((c) => c.toString().trim().isEmpty)) continue;

      String cell(int idx) =>
          idx >= 0 && idx < row.length ? row[idx].toString().trim() : '';

      final titleCol = colIndex['title'] ?? -1;
      final tagsCol = colIndex['technology_tags'] ?? -1;
      final supervisorCol = colIndex['supervisor_display_name'] ?? -1;
      final progCol = colIndex['programme_code'] ?? -1;
      final descCol = colIndex['short_description'] ?? -1;
      final catCol = colIndex['category'] ?? -1;
      final teamCol = colIndex['team_display_names'] ?? -1;
      final boothNumCol = colIndex['booth_number'] ?? -1;
      final boothZoneCol = colIndex['booth_zone'] ?? -1;
      final demoCol = colIndex['demo_url'] ?? -1;

      final title = cell(titleCol);
      if (title.isEmpty) continue;

      final tagStr = cell(tagsCol);
      final tags = tagStr.isNotEmpty
          ? tagStr.split(';')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .toList()
          : <String>[];

      final teamStr = cell(teamCol);
      final teamNames = teamStr.isNotEmpty
          ? teamStr.split(';')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .toList()
          : <String>[];

      projects.add(Project(
        id: 'csp600-$r',
        eventId: 'fskm-fyp-2026',
        slug: 'csp600-$r',
        title: title,
        matricId: null,
        programmeCode: cell(progCol),
        programmeName: cell(progCol),
        shortDescription: cell(descCol),
        category: cell(catCol),
        technologyTags: tags,
        boothId: null,
        boothNumber: cell(boothNumCol).isEmpty ? null : cell(boothNumCol),
        boothZone: cell(boothZoneCol).isEmpty ? null : cell(boothZoneCol),
        coverImageUrl: 'assets/images/project_placeholder.jpg',
        posterUrl: null,
        teamDisplayNames: teamNames,
        supervisorDisplayName: cell(supervisorCol),
        examinerDisplayName: null,
        demoUrl: cell(demoCol).isEmpty ? null : cell(demoCol),
        videoUrl: null,
        repositoryUrl: null,
        featured: false,
        calonIndustri: false,
        publicationStatus: 'published',
        createdAt: now,
        updatedAt: now,
        publishedAt: now,
        presentationDay: null,
      ));
    }

    logDebug('Csp600CsvLoader: Parsed ${projects.length} proposals');
    return projects;
  }
}

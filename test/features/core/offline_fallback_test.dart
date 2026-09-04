import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/data/offline_fallback.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/utils/fypms_key_normalizer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('OfflineFallback.load returns parsed dataset', () async {
    final data = await OfflineFallback.load();
    expect(data['projects'], isNotEmpty);
    expect(data['booths'], isNotEmpty);
    expect((data['projects']!.first)['title'], isA<String>());
  });

  test('fallback rows parse through the live-row pipeline', () async {
    final data = await OfflineFallback.load();
    for (final m in data['projects']!.take(20)) {
      final project = Project.fromJson(normalizeKeys(m));
      expect(project.id, isNotEmpty);
      expect(project.title, isNotEmpty);
      expect(project.createdAt, isA<DateTime>());
    }
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/student_visit.dart';
import '../../utils/fypms_key_normalizer.dart' show normalizeKeys;
import 'lecturer_providers.dart';
import 'service_providers.dart';

// ==========================================
// STUDENT VISITS STATE
// ==========================================
final allVisitsProvider = FutureProvider<List<StudentVisit>>((ref) async {
  final db = ref.read(supabaseDbServiceProvider);
  final list = await db.getVisitsOnce();
  return list.map((m) => StudentVisit.fromJson(normalizeKeys(m))).toList();
});

final lecturerVisitsProvider = Provider<List<StudentVisit>>((ref) {
  final lecturer = ref.watch(lecturerAuthProvider);
  final all = ref.watch(allVisitsProvider);
  if (lecturer == null) return [];
  final allList = all.asData?.value ?? [];
  return allList.where((v) => v.lecturerId == lecturer.uid).toList();
});

final completedVisitsProvider = Provider<Set<String>>((ref) {
  final visits = ref.watch(lecturerVisitsProvider);
  return visits
      .where((v) => v.status == 'completed')
      .map((v) => '${v.projectId}_${v.visitRole}')
      .toSet();
});

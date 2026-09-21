import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/project_lecturer_assignment.dart';
import '../../utils/fypms_key_normalizer.dart' show normalizeKeys;
import 'lecturer_providers.dart';
import 'service_providers.dart';

// ==========================================
// PROJECT LECTURER ASSIGNMENTS STATE
// ==========================================
final allAssignmentsProvider = FutureProvider<List<ProjectLecturerAssignment>>((ref) async {
  final db = ref.read(supabaseDbServiceProvider);
  final list = await db.getAssignmentsOnce();
  return list.map((m) => ProjectLecturerAssignment.fromJson(normalizeKeys(m))).toList();
});

final lecturerAssignmentsProvider = Provider<List<ProjectLecturerAssignment>>((ref) {
  final lecturer = ref.watch(lecturerAuthProvider);
  final all = ref.watch(allAssignmentsProvider);
  if (lecturer == null) return [];
  final allList = all.asData?.value ?? [];
  return allList
      .where(
        (a) =>
            a.status == 'active' &&
            ((a.lecturerId != null && a.lecturerId == lecturer.uid) ||
                (a.lecturerId == null &&
                    a.lecturerDisplayName.toLowerCase().contains(
                      lecturer.displayName.toLowerCase(),
                    ))),
      )
      .toList();
});

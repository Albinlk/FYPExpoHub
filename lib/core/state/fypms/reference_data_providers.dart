import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fypms/academic_course.dart';
import '../../domain/models/fypms/academic_semester.dart';
import '../../domain/models/fypms/fyp_course_offering.dart';
import '../../supabase/supabase_client_provider.dart';
import '../../utils/fypms_key_normalizer.dart';
import '../expo/service_providers.dart';

// ==============================================================================
// ACADEMIC REFERENCE DATA
// ==============================================================================

final fypmsSemestersProvider = FutureProvider<List<AcademicSemester>>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getAcademicSemestersOnce();
  return data.map((m) => AcademicSemester.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypmsCoursesProvider = FutureProvider<List<AcademicCourse>>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getAcademicCoursesOnce();
  return data.map((m) => AcademicCourse.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypmsOfferingsProvider = FutureProvider<List<FypCourseOffering>>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getFypCourseOfferingsOnce();
  return data.map((m) => FypCourseOffering.fromJson(normalizeFypmsKeys(m))).toList();
});

/// Course offerings belonging to the current lecturer (for the CSP dashboard).
final myFypmsOfferingsProvider =
    FutureProvider<List<FypCourseOffering>>((ref) async {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) return const [];
  final all = await ref.watch(fypmsOfferingsProvider.future);
  return all.where((o) => o.lecturerId == user.id).toList();
});

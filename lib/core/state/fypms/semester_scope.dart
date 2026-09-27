import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fypms/academic_semester.dart';
import 'reference_data_providers.dart';

/// Value of [fypmsSelectedSemesterProvider] meaning "every semester".
const kAllSemesters = '__all__';

/// The semester staff lists are scoped to (backlog S2). Null means "the
/// active semester" (the default); [kAllSemesters] shows every semester.
class SelectedSemesterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? semesterId) => state = semesterId;
}

final fypmsSelectedSemesterProvider =
    NotifierProvider<SelectedSemesterNotifier, String?>(SelectedSemesterNotifier.new);

/// The active semester, if one is set.
AcademicSemester? activeSemesterOf(List<AcademicSemester> semesters) =>
    semesters.where((s) => s.status == 'active').firstOrNull;

/// The semester id lists filter by, or null for no filter (all semesters,
/// or none configured / not loaded yet).
final fypmsEffectiveSemesterIdProvider = Provider<String?>((ref) {
  final selected = ref.watch(fypmsSelectedSemesterProvider);
  if (selected == kAllSemesters) return null;
  if (selected != null) return selected;
  final semesters = ref.watch(fypmsSemestersProvider).value ?? const <AcademicSemester>[];
  return activeSemesterOf(semesters)?.id;
});

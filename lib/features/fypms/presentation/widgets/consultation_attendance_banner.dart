import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/fypms_attendance.dart';
import '../../../../core/domain/models/fypms/fyp_progress_log.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';

/// Consultation attendance against the 80 % requirement, from the record's
/// semester dates and its signed F5 entries.
class ConsultationAttendanceBanner extends ConsumerWidget {
  const ConsultationAttendanceBanner({super.key, required this.record, required this.logs, this.today});

  final FypRecord record;
  final List<FypProgressLog> logs;

  /// Overrides "now" (tests).
  final DateTime? today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semester = ref
        .watch(fypmsSemestersProvider)
        .value
        ?.where((s) => s.id == record.academicSemesterId)
        .firstOrNull;
    if (semester == null) return const SizedBox.shrink();

    final a = consultationAttendance(
      logs,
      semesterStart: semester.startDate,
      semesterEnd: semester.endDate,
      today: today ?? DateTime.now(),
    );
    final ok = a.meetsRequirement;
    final color = ok ? DesignSystem.tertiary : DesignSystem.error;
    return Container(
      key: const Key('attendance-banner'),
      width: double.infinity,
      padding: const EdgeInsets.all(DesignSystem.spaceSm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: DesignSystem.radiusLg,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(ok ? Icons.event_available : Icons.event_busy, color: color, size: 20),
          const SizedBox(width: DesignSystem.spaceSm),
          Expanded(
            child: Text(
              [
                a.summary,
                if (!ok && a.expectedWeeks > 0) 'below the 80 % attendance requirement',
                if (a.pending > 0) '${a.pending} awaiting supervisor signature',
              ].join(' · '),
              style: DesignSystem.bodySm.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

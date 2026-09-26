import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How a public dataset's last load went (known-gaps register G-31). The
/// list notifiers keep their state as the plain list, so the status lives
/// alongside it, keyed by dataset: see [PublicDataset].
enum DataLoadStatus {
  /// Nothing confirmed from the server yet.
  loading,

  /// The server answered (possibly with no rows).
  live,

  /// The server could not be reached; bundled offline data is showing.
  offline,

  /// The server could not be reached and there is nothing to show.
  failed,
}

/// Keys for [publicLoadStatusProvider].
abstract final class PublicDataset {
  static const projects = 'projects';
  static const booths = 'booths';
  static const schedule = 'schedule';
  static const announcements = 'announcements';
  static const awards = 'awards';
}

class LoadStatusNotifier extends Notifier<DataLoadStatus> {
  LoadStatusNotifier(this.dataset);

  final String dataset;

  @override
  DataLoadStatus build() => DataLoadStatus.loading;

  void set(DataLoadStatus status) => state = status;
}

final publicLoadStatusProvider =
    NotifierProvider.family<LoadStatusNotifier, DataLoadStatus, String>(LoadStatusNotifier.new);

/// The status after a load attempt: [remoteFailed] with rows still showing
/// (bundled fallback) is offline, with nothing showing it failed.
DataLoadStatus loadOutcome({required bool remoteFailed, required bool hasRows}) {
  if (!remoteFailed) return DataLoadStatus.live;
  return hasRows ? DataLoadStatus.offline : DataLoadStatus.failed;
}

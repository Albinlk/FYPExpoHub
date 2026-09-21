/// Barrel file for FYPMS (FYP Management System) state providers.
///
/// The implementation lives in `fypms/*_providers.dart`, split by concern
/// (roles/feature-flags, academic reference data, FYP records, record-scoped
/// sub-resources, coordinator data, mutations, realtime) to keep each file
/// focused and reviewable. This file preserves the original single-import
/// surface (`import '.../state/fypms_state_providers.dart'`) used across
/// the app.
library;

export 'fypms/roles_providers.dart';
export 'fypms/reference_data_providers.dart';
export 'fypms/records_providers.dart';
export 'fypms/record_resources_providers.dart';
export 'fypms/coordinator_providers.dart';
export 'fypms/mutations_providers.dart';
export 'fypms/realtime_providers.dart';

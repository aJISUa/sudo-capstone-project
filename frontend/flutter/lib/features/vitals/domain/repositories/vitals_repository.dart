import 'package:oncare/features/vitals/domain/entities/vital.dart';

/// Persistence + lookup contract for the Quick Input modal and
/// MyHealth indicators. The Dio implementation (Stage 9.5+) hits
/// `/vitals/{kind}` endpoints served by `LocalApiInterceptor`
/// during dev; the FastAPI build will swap in for free.
abstract class VitalsRepository {
  /// Append a new reading. Returns the persisted [VitalRecord] so the
  /// caller can read back the assigned `id` and `recordedAt`.
  Future<VitalRecord> submit(VitalSubmission submission);

  /// Latest reading of [kind], or null if the table is empty.
  Future<VitalRecord?> latest(VitalKind kind);
}

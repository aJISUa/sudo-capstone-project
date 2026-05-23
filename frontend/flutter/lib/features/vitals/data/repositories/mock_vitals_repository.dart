import 'package:oncare/features/vitals/domain/entities/vital.dart';
import 'package:oncare/features/vitals/domain/repositories/vitals_repository.dart';

/// In-memory [VitalsRepository] for tests. Submitted values stick
/// around for the lifetime of the instance, so callers can verify
/// `latest()` after `submit()`.
class MockVitalsRepository implements VitalsRepository {
  MockVitalsRepository();

  final List<VitalRecord> _records = <VitalRecord>[];
  int _seq = 0;

  @override
  Future<VitalRecord> submit(VitalSubmission submission) async {
    _seq += 1;
    final record = VitalRecord(
      id: 'mock-vital-$_seq',
      kind: submission.kind,
      value: submission.toJson(),
      recordedAt: DateTime.now(),
    );
    _records.add(record);
    return record;
  }

  @override
  Future<VitalRecord?> latest(VitalKind kind) async {
    final matching = _records.where((r) => r.kind == kind).toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return matching.isEmpty ? null : matching.first;
  }
}

import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/features/vitals/domain/entities/vital.dart';

void main() {
  group('VitalKind', () {
    test('round-trips through .path', () {
      for (final kind in VitalKind.values) {
        expect(VitalKind.fromPath(kind.path), kind);
      }
    });

    test('path matches FastAPI route segments', () {
      expect(VitalKind.weight.path, 'weight');
      expect(VitalKind.bloodPressure.path, 'blood-pressure');
      expect(VitalKind.bloodSugar.path, 'blood-sugar');
    });
  });

  group('VitalSubmission', () {
    test('WeightSubmission encodes to {"kg": ...}', () {
      const s = WeightSubmission(kg: 72.5);
      expect(s.kind, VitalKind.weight);
      expect(s.toJson(), <String, Object?>{'kg': 72.5});
    });

    test('BloodPressureSubmission encodes systolic + diastolic', () {
      const s = BloodPressureSubmission(systolic: 120, diastolic: 80);
      expect(s.kind, VitalKind.bloodPressure);
      expect(s.toJson(), <String, Object?>{'systolic': 120, 'diastolic': 80});
    });

    test('BloodSugarSubmission encodes mg_per_dl', () {
      const s = BloodSugarSubmission(mgPerDl: 95);
      expect(s.kind, VitalKind.bloodSugar);
      expect(s.toJson(), <String, Object?>{'mg_per_dl': 95});
    });
  });

  group('VitalRecord.fromJson', () {
    test('parses a full record', () {
      final r = VitalRecord.fromJson(<String, Object?>{
        'id': 'v-1',
        'kind': 'weight',
        'value': <String, Object?>{'kg': 71.4},
        'recorded_at': '2026-05-20T08:00:00.000Z',
      });
      expect(r.id, 'v-1');
      expect(r.kind, VitalKind.weight);
      expect(r.value['kg'], 71.4);
      expect(r.recordedAt.year, 2026);
      expect(r.recordedAt.month, 5);
    });
  });
}

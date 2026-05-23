/// Vital sign domain primitives.
///
/// The React prototype's "Quick Input" modal (체중/혈압/혈당) submits
/// one of three measurement shapes. We model them as a sealed family
/// so the repository layer can serialize each one to the matching
/// FastAPI endpoint without runtime guessing.
library;

/// The three measurement kinds the app records. The `path` segment
/// matches the FastAPI route component (`/vitals/{path}`).
enum VitalKind {
  weight('weight'),
  bloodPressure('blood-pressure'),
  bloodSugar('blood-sugar');

  const VitalKind(this.path);
  final String path;

  static VitalKind fromPath(String s) =>
      VitalKind.values.firstWhere((k) => k.path == s);
}

/// What the UI hands to the repository when the user taps "저장하기".
/// Sealed so each variant carries exactly the fields the corresponding
/// endpoint expects.
sealed class VitalSubmission {
  const VitalSubmission();

  VitalKind get kind;

  /// snake_case map that becomes the POST body. `recorded_at` is added
  /// by the repository so the UI doesn't have to think about clocks.
  Map<String, Object?> toJson();
}

class WeightSubmission extends VitalSubmission {
  const WeightSubmission({required this.kg});
  final double kg;

  @override
  VitalKind get kind => VitalKind.weight;

  @override
  Map<String, Object?> toJson() => <String, Object?>{'kg': kg};
}

class BloodPressureSubmission extends VitalSubmission {
  const BloodPressureSubmission({
    required this.systolic,
    required this.diastolic,
  });
  final int systolic;
  final int diastolic;

  @override
  VitalKind get kind => VitalKind.bloodPressure;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'systolic': systolic,
    'diastolic': diastolic,
  };
}

class BloodSugarSubmission extends VitalSubmission {
  const BloodSugarSubmission({required this.mgPerDl});
  final int mgPerDl;

  @override
  VitalKind get kind => VitalKind.bloodSugar;

  @override
  Map<String, Object?> toJson() => <String, Object?>{'mg_per_dl': mgPerDl};
}

/// A persisted vital row. `value` keeps the snake_case map as the
/// server sent it — UI code reads `value['kg']`, `value['systolic']`,
/// `value['mg_per_dl']` etc.
class VitalRecord {
  const VitalRecord({
    required this.id,
    required this.kind,
    required this.value,
    required this.recordedAt,
  });

  final String id;
  final VitalKind kind;
  final Map<String, Object?> value;
  final DateTime recordedAt;

  factory VitalRecord.fromJson(Map<String, Object?> json) => VitalRecord(
    id: json['id']! as String,
    kind: VitalKind.fromPath(json['kind']! as String),
    value: (json['value']! as Map<Object?, Object?>).cast<String, Object?>(),
    recordedAt: DateTime.parse(json['recorded_at']! as String),
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'kind': kind.path,
    'value': value,
    'recorded_at': recordedAt.toIso8601String(),
  };
}

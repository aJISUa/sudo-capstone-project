class UserProfile {
  const UserProfile({required this.name, required this.email});
  final String name;
  final String email;

  factory UserProfile.fromJson(Map<String, Object?> json) => UserProfile(
    name: json['name']! as String,
    email: json['email']! as String,
  );
}

enum RiskLevel { low, medium, high }

RiskLevel _riskFromString(String s) => RiskLevel.values.firstWhere(
  (r) => r.name == s,
  orElse: () => RiskLevel.low,
);

class RiskAlert {
  const RiskAlert({
    required this.title,
    required this.body,
    required this.level,
  });
  final String title;
  final String body;
  final RiskLevel level;

  factory RiskAlert.fromJson(Map<String, Object?> json) => RiskAlert(
    title: json['title']! as String,
    body: json['body']! as String,
    level: _riskFromString(json['level']! as String),
  );
}

enum IndicatorKind { weight, bloodPressure, bloodSugar }

/// Hyphenated wire form: weight | blood-pressure | blood-sugar.
/// Same convention as `VitalKind` so the wire format stays consistent.
IndicatorKind _indicatorFromWire(String s) => switch (s) {
  'blood-pressure' => IndicatorKind.bloodPressure,
  'blood-sugar' => IndicatorKind.bloodSugar,
  _ => IndicatorKind.weight,
};

class IndicatorTrend {
  const IndicatorTrend({
    required this.kind,
    required this.label,
    required this.latestValue,
    required this.unit,
    required this.deltaText,
    required this.improving,
    required this.last7Days,
  });

  final IndicatorKind kind;
  final String label;
  final String latestValue;
  final String unit;
  final String deltaText;
  final bool improving;

  /// Normalised series (0..1) used to paint the small inline sparkline.
  final List<double> last7Days;

  factory IndicatorTrend.fromJson(Map<String, Object?> json) => IndicatorTrend(
    kind: _indicatorFromWire(json['kind']! as String),
    label: json['label']! as String,
    latestValue: json['latest_value']! as String,
    unit: json['unit']! as String,
    deltaText: json['delta_text']! as String,
    improving: json['improving']! as bool,
    last7Days: (json['last_7_days']! as List<Object?>)
        .map((v) => (v! as num).toDouble())
        .toList(),
  );
}

class SettingsItem {
  const SettingsItem({required this.label, required this.icon});
  final String label;
  final String icon; // emoji

  factory SettingsItem.fromJson(Map<String, Object?> json) => SettingsItem(
    label: json['label']! as String,
    icon: json['icon']! as String,
  );
}

class MyHealthState {
  const MyHealthState({
    required this.profile,
    required this.risk,
    required this.indicators,
    required this.activityPoints,
    required this.activityRank,
    required this.settings,
  });

  final UserProfile profile;
  final RiskAlert risk;
  final List<IndicatorTrend> indicators;
  final int activityPoints;
  final int activityRank;
  final List<SettingsItem> settings;

  factory MyHealthState.fromJson(Map<String, Object?> json) => MyHealthState(
    profile: UserProfile.fromJson(json['profile']! as Map<String, Object?>),
    risk: RiskAlert.fromJson(json['risk']! as Map<String, Object?>),
    indicators: (json['indicators']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map(IndicatorTrend.fromJson)
        .toList(),
    activityPoints: (json['activity_points']! as num).toInt(),
    activityRank: (json['activity_rank']! as num).toInt(),
    settings: (json['settings']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map(SettingsItem.fromJson)
        .toList(),
  );
}

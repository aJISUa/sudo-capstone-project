import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oncare/core/storage/prefs_store.dart';
import 'package:oncare/design_system/figma/figma_kit.dart';
import 'package:oncare/features/account/domain/entities/user_profile.dart';
import 'package:oncare/features/account/presentation/controllers/account_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _shell(BuildContext context, String title, List<Widget> children) {
  return SafeArea(
    top: false,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: 560,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE3EA),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: FigmaColors.ink,
                      ),
                    ),
                  ),
                  Material(
                    color: const Color(0xFFF4F6F8),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: FigmaColors.textSub,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                children: children,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _open(BuildContext context, String title, List<Widget> body) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: FigmaColors.sheetScrim,
    builder: (BuildContext ctx) => _shell(ctx, title, body),
  );
}

Widget _card(List<Widget> children) => Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: FigmaColors.statBg,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  ),
);

/// Figma-styled label + editable text field used by the profile and goal
/// sheets. White fill on the `statBg` card, brand-blue focus ring.
class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.suffix,
    this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffix;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: FigmaColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: FigmaColors.ink,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: FigmaColors.textFaint,
            ),
            suffixText: suffix,
            suffixStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: FigmaColors.textMuted,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: FigmaColors.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: FigmaColors.primary, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

/// The gradient profile disc with the member's initial.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[FigmaColors.primary, FigmaColors.primaryDeep],
        ),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Spinner shown inside a sheet while `profileProvider` is loading.
class _SheetLoader extends StatelessWidget {
  const _SheetLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator(color: FigmaColors.primary)),
    );
  }
}

/// The 취소 · 저장 footer shared by the profile and goal sheets. The primary
/// button shows a spinner and both buttons disable while [saving].
Widget _saveRow({
  required BuildContext context,
  required bool saving,
  required VoidCallback onSave,
}) {
  return Row(
    children: <Widget>[
      Expanded(
        child: OutlinedButton(
          onPressed: saving ? null : () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: FigmaColors.textSub,
            side: const BorderSide(color: FigmaColors.hairline),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            '취소',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: FilledButton(
          onPressed: saving ? null : onSave,
          style: FilledButton.styleFrom(
            backgroundColor: FigmaColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  '저장',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
        ),
      ),
    ],
  );
}

// ───────────────────────────────────────────────────────── 내 프로필 ──

/// Profile editor — pre-fills from `profileProvider` and persists via
/// `AccountRepository.updateProfile`.
Future<void> showProfileSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: FigmaColors.sheetScrim,
    builder: (BuildContext ctx) => const _ProfileSheet(),
  );
}

class _ProfileSheet extends ConsumerWidget {
  const _ProfileSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserProfile> profile = ref.watch(profileProvider);
    return profile.when(
      data: (UserProfile p) => _ProfileForm(initial: p),
      loading: () => _shell(context, '내 프로필', const <Widget>[_SheetLoader()]),
      error: (_, _) => const _ProfileForm(
        initial: UserProfile(id: '', name: '', email: ''),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.initial});
  final UserProfile initial;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initial.name,
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.initial.email,
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.initial.phone,
  );
  late final TextEditingController _birth = TextEditingController(
    text: widget.initial.birthDate,
  );
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _birth.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(accountRepositoryProvider).updateProfile(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        birthDate: _birth.text.trim(),
      );
      ref.invalidate(profileProvider);
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('프로필이 저장되었어요')),
      );
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('저장에 실패했어요. 잠시 후 다시 시도해 주세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.initial.name.trim();
    final String initial = name.isNotEmpty ? name.substring(0, 1) : '·';
    return _shell(context, '내 프로필', <Widget>[
      Center(child: _Avatar(initial: initial)),
      const SizedBox(height: 16),
      _card(<Widget>[
        _SheetField(label: '이름', controller: _name),
        const SizedBox(height: 12),
        _SheetField(
          label: '이메일',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _SheetField(
          label: '전화번호',
          controller: _phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _SheetField(
          label: '생년월일',
          controller: _birth,
          hintText: '1996-03-21',
        ),
      ]),
      const SizedBox(height: 16),
      _saveRow(context: context, saving: _saving, onSave: _save),
    ]);
  }
}

// ───────────────────────────────────────────────────────── 건강 목표 ──

/// Health goals editor — pre-fills from `profileProvider` and persists via
/// `AccountRepository.updateHealthGoals`.
Future<void> showGoalsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: FigmaColors.sheetScrim,
    builder: (BuildContext ctx) => const _GoalsSheet(),
  );
}

class _GoalsSheet extends ConsumerWidget {
  const _GoalsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserProfile> profile = ref.watch(profileProvider);
    return profile.when(
      data: (UserProfile p) => _GoalsForm(initial: p),
      loading: () => _shell(context, '건강 목표', const <Widget>[_SheetLoader()]),
      error: (_, _) => const _GoalsForm(
        initial: UserProfile(id: '', name: '', email: ''),
      ),
    );
  }
}

class _GoalsForm extends ConsumerStatefulWidget {
  const _GoalsForm({required this.initial});
  final UserProfile initial;

  @override
  ConsumerState<_GoalsForm> createState() => _GoalsFormState();
}

class _GoalsFormState extends ConsumerState<_GoalsForm> {
  late final TextEditingController _weight = TextEditingController(
    text: '${(widget.initial.goalWeightKg ?? 70).round()}',
  );
  late final TextEditingController _bp = TextEditingController(
    text: '${widget.initial.goalBpSystolic ?? 120}',
  );
  late final TextEditingController _sugar = TextEditingController(
    text: '${widget.initial.goalBloodSugar ?? 100}',
  );
  late final TextEditingController _kcal = TextEditingController(
    text: '${widget.initial.dailyCalories ?? 2000}',
  );
  late final TextEditingController _sodium = TextEditingController(
    text: '${widget.initial.dailySodiumMg ?? 2000}',
  );
  bool _saving = false;

  @override
  void dispose() {
    _weight.dispose();
    _bp.dispose();
    _sugar.dispose();
    _kcal.dispose();
    _sodium.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(accountRepositoryProvider).updateHealthGoals(
        goalWeightKg: int.tryParse(_weight.text.trim()),
        goalBpSystolic: int.tryParse(_bp.text.trim()),
        goalBloodSugar: int.tryParse(_sugar.text.trim()),
        dailyCalories: int.tryParse(_kcal.text.trim()),
        dailySodiumMg: int.tryParse(_sodium.text.trim()),
      );
      ref.invalidate(profileProvider);
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('건강 목표가 저장되었어요')),
      );
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('저장에 실패했어요. 잠시 후 다시 시도해 주세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<TextInputFormatter> digitsOnly = <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
    ];
    return _shell(context, '건강 목표', <Widget>[
      const Text(
        '앱 곳곳의 요약·피드백이 이 목표를 기준으로 계산돼요.',
        style: TextStyle(fontSize: 12, color: FigmaColors.textMuted),
      ),
      const SizedBox(height: 12),
      _card(<Widget>[
        _SheetField(
          label: '목표 체중',
          controller: _weight,
          suffix: 'kg',
          keyboardType: TextInputType.number,
          inputFormatters: digitsOnly,
        ),
        const SizedBox(height: 12),
        _SheetField(
          label: '목표 혈압 (수축기)',
          controller: _bp,
          suffix: 'mmHg',
          keyboardType: TextInputType.number,
          inputFormatters: digitsOnly,
        ),
        const SizedBox(height: 12),
        _SheetField(
          label: '목표 혈당',
          controller: _sugar,
          suffix: 'mg/dL',
          keyboardType: TextInputType.number,
          inputFormatters: digitsOnly,
        ),
      ]),
      const SizedBox(height: 12),
      _card(<Widget>[
        _SheetField(
          label: '일일 칼로리',
          controller: _kcal,
          suffix: 'kcal',
          keyboardType: TextInputType.number,
          inputFormatters: digitsOnly,
        ),
        const SizedBox(height: 12),
        _SheetField(
          label: '나트륨 제한',
          controller: _sodium,
          suffix: 'mg',
          keyboardType: TextInputType.number,
          inputFormatters: digitsOnly,
        ),
      ]),
      const SizedBox(height: 16),
      _saveRow(context: context, saving: _saving, onSave: _save),
    ]);
  }
}

// ───────────────────────────────────────────────────────── 알림 설정 ──

/// One notification toggle: Figma label, SharedPreferences key, and the
/// default used before the user has ever changed it.
class _NotifItem {
  const _NotifItem(this.label, this.prefKey, this.fallback);
  final String label;
  final String prefKey;
  final bool fallback;
}

const List<_NotifItem> _notifItems = <_NotifItem>[
  _NotifItem('식단 기록 알림', 'notif_diet_log', true),
  _NotifItem('운동 리마인더', 'notif_exercise_reminder', true),
  _NotifItem('트레이너 메시지', 'notif_trainer_message', true),
  _NotifItem('AI 코칭 조언', 'notif_ai_coaching', true),
  _NotifItem('주간 리포트', 'notif_weekly_report', false),
];

/// Notification preferences — toggles load from and persist to
/// SharedPreferences so they survive a reload.
Future<void> showNotifSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: FigmaColors.sheetScrim,
    builder: (BuildContext ctx) => const _NotifSheet(),
  );
}

class _NotifSheet extends ConsumerStatefulWidget {
  const _NotifSheet();

  @override
  ConsumerState<_NotifSheet> createState() => _NotifSheetState();
}

class _NotifSheetState extends ConsumerState<_NotifSheet> {
  late final SharedPreferences _prefs;
  final Map<String, bool> _on = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _prefs = ref.read(sharedPreferencesProvider);
    for (final _NotifItem item in _notifItems) {
      _on[item.prefKey] = _prefs.getBool(item.prefKey) ?? item.fallback;
    }
  }

  void _persist(String key, bool value) {
    setState(() => _on[key] = value);
    _prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return _shell(context, '알림 설정', <Widget>[
      _card(<Widget>[
        for (int i = 0; i < _notifItems.length; i++) ...<Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _notifItems[i].label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FigmaColors.ink,
                  ),
                ),
              ),
              Switch.adaptive(
                value: _on[_notifItems[i].prefKey] ?? _notifItems[i].fallback,
                activeThumbColor: FigmaColors.primary,
                onChanged: (bool v) => _persist(_notifItems[i].prefKey, v),
              ),
            ],
          ),
          if (i < _notifItems.length - 1)
            const Divider(height: 1, color: FigmaColors.hairline),
        ],
      ]),
    ]);
  }
}

// ───────────────────────────────────────────────────────── 고객 지원 ──

/// Customer support entries.
Future<void> showSupportSheet(BuildContext context) {
  return _open(context, '고객 지원', <Widget>[
    _supportRow(
      Icons.help_outline,
      '자주 묻는 질문',
      () => _comingSoon(context, '자주 묻는 질문'),
    ),
    _supportRow(
      Icons.chat_bubble_outline,
      '1:1 문의',
      () => _comingSoon(context, '1:1 문의'),
    ),
    _supportRow(
      Icons.description_outlined,
      '이용약관',
      () => _openLegal(context, _LegalDoc.terms),
    ),
    _supportRow(
      Icons.privacy_tip_outlined,
      '개인정보 처리방침',
      () => _openLegal(context, _LegalDoc.privacy),
    ),
    const SizedBox(height: 12),
    const Center(
      child: Text(
        'On-Care · 버전 1.0.0',
        style: TextStyle(fontSize: 12, color: FigmaColors.textFaint),
      ),
    ),
  ]);
}

void _comingSoon(BuildContext context, String label) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('$label은(는) 준비 중이에요')));
}

void _openLegal(BuildContext context, _LegalDoc doc) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: FigmaColors.sheetScrim,
    builder: (BuildContext ctx) => _LegalDocSheet(doc: doc),
  );
}

Widget _supportRow(IconData icon, String label, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: FigmaColors.statBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 18, color: FigmaColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FigmaColors.ink,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: FigmaColors.textFaint,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// The in-app legal documents surfaced from 고객 지원.
enum _LegalDoc {
  terms('이용약관', _termsBody),
  privacy('개인정보 처리방침', _privacyBody);

  const _LegalDoc(this.title, this.body);
  final String title;
  final String body;
}

class _LegalDocSheet extends StatelessWidget {
  const _LegalDocSheet({required this.doc});
  final _LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    return _shell(context, doc.title, <Widget>[
      _card(<Widget>[
        Text(
          doc.body,
          style: const TextStyle(
            fontSize: 13,
            height: 1.7,
            fontWeight: FontWeight.w500,
            color: FigmaColors.textBody,
          ),
        ),
      ]),
      const SizedBox(height: 12),
      const Center(
        child: Text(
          '시행일 2026. 01. 01.',
          style: TextStyle(fontSize: 11, color: FigmaColors.textFaint),
        ),
      ),
    ]);
  }
}

const String _termsBody =
    '제1조 (목적)\n'
    '이 약관은 On-Care(이하 "회사")가 제공하는 건강 관리 서비스(이하 "서비스")의 이용과 관련하여 '
    '회사와 회원 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.\n\n'
    '제2조 (약관의 효력 및 변경)\n'
    '① 이 약관은 서비스를 이용하는 모든 회원에게 효력이 발생합니다.\n'
    '② 회사는 관련 법령을 위반하지 않는 범위에서 이 약관을 변경할 수 있으며, 변경 시 적용일자와 '
    '변경 사유를 명시하여 서비스 내에 공지합니다.\n\n'
    '제3조 (서비스의 제공)\n'
    '회사는 식단 기록, 운동 기록, 건강 지표 관리, AI 코칭 등 회원의 건강 관리를 돕는 기능을 '
    '제공합니다. 서비스의 구체적인 내용은 회사의 정책에 따라 변경될 수 있습니다.\n\n'
    '제4조 (회원의 의무)\n'
    '회원은 본인의 건강 정보를 정확하게 입력하여야 하며, 서비스가 제공하는 정보는 의학적 진단이나 '
    '치료를 대체하지 않습니다. 건강상 문제가 있는 경우 반드시 전문 의료기관의 진료를 받으시기 바랍니다.\n\n'
    '제5조 (책임의 제한)\n'
    '회사는 회원이 서비스를 통해 얻은 정보에 기반하여 내린 판단과 그 결과에 대하여 법령이 허용하는 '
    '범위 내에서 책임을 부담하지 않습니다.\n\n'
    '부칙\n'
    '이 약관은 2026년 1월 1일부터 시행합니다.';

const String _privacyBody =
    'On-Care(이하 "회사")는 「개인정보 보호법」 등 관련 법령을 준수하며, 회원의 개인정보를 소중히 '
    '보호합니다.\n\n'
    '1. 수집하는 개인정보 항목\n'
    '회사는 회원가입 및 서비스 제공을 위하여 이름, 이메일, 전화번호, 생년월일과 함께 식단·운동·건강 '
    '지표 등 건강 관련 정보를 수집합니다.\n\n'
    '2. 개인정보의 수집 및 이용 목적\n'
    '수집한 개인정보는 회원 식별, 건강 관리 기능 제공, 맞춤형 AI 코칭, 서비스 개선 및 고객 문의 '
    '응대의 목적으로만 이용됩니다.\n\n'
    '3. 개인정보의 보유 및 이용 기간\n'
    '회원의 개인정보는 원칙적으로 회원 탈퇴 시 지체 없이 파기합니다. 다만 관련 법령에 따라 보존할 '
    '필요가 있는 경우 해당 기간 동안 안전하게 보관합니다.\n\n'
    '4. 개인정보의 제3자 제공\n'
    '회사는 회원의 동의 없이 개인정보를 외부에 제공하지 않습니다. 다만 법령에 특별한 규정이 있는 '
    '경우는 예외로 합니다.\n\n'
    '5. 이용자의 권리\n'
    '회원은 언제든지 자신의 개인정보를 조회·수정하거나 처리 정지 및 삭제를 요청할 수 있습니다.\n\n'
    '6. 개인정보 보호책임자\n'
    '개인정보와 관련한 문의는 고객 지원(support@oncare.com)으로 연락하실 수 있습니다.\n\n'
    '시행일: 2026년 1월 1일';

import 'package:flutter/material.dart';

import 'package:oncare/design_system/figma/figma_kit.dart';

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

Widget _field(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Row(
    children: <Widget>[
      SizedBox(
        width: 84,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: FigmaColors.textMuted,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: FigmaColors.ink,
          ),
        ),
      ),
    ],
  ),
);

// ───────────────────────────────────────────────────────── 내 프로필 ──

/// Profile detail — mirrors the profile card + body basics shown in the app.
Future<void> showProfileSheet(BuildContext context) {
  return _open(context, '내 프로필', <Widget>[
    Center(
      child: Container(
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
        child: const Text(
          '김',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    ),
    const SizedBox(height: 16),
    _card(<Widget>[
      _field('이름', '김민수'),
      const Divider(height: 1, color: FigmaColors.hairline),
      _field('이메일', 'minsu@oncare.com'),
      const Divider(height: 1, color: FigmaColors.hairline),
      _field('생년월일', '1996. 03. 21.'),
    ]),
    const SizedBox(height: 12),
    _card(<Widget>[
      _field('키', '172 cm'),
      const Divider(height: 1, color: FigmaColors.hairline),
      _field('체중', '68 kg'),
      const Divider(height: 1, color: FigmaColors.hairline),
      _field('관리 목표', '혈압 관리 · 체중 감량'),
    ]),
    const SizedBox(height: 16),
    _saveButton(context, '프로필이 저장되었어요'),
  ]);
}

// ───────────────────────────────────────────────────────── 건강 목표 ──

/// Health goals — the daily targets that drive the home/diet summaries.
Future<void> showGoalsSheet(BuildContext context) {
  return _open(context, '건강 목표', <Widget>[
    const Text(
      '앱 곳곳의 요약·피드백이 이 목표를 기준으로 계산돼요.',
      style: TextStyle(fontSize: 12, color: FigmaColors.textMuted),
    ),
    const SizedBox(height: 12),
    _card(<Widget>[
      _goalRow('일일 칼로리', '1,800', 'kcal'),
      const Divider(height: 1, color: FigmaColors.hairline),
      _goalRow('나트륨', '2,000', 'mg 이하'),
      const Divider(height: 1, color: FigmaColors.hairline),
      _goalRow('당류', '50', 'g 이하'),
    ]),
    const SizedBox(height: 12),
    _card(<Widget>[
      _goalRow('운동 소모', '500', 'kcal/일'),
      const Divider(height: 1, color: FigmaColors.hairline),
      _goalRow('걸음 수', '8,000', '보'),
      const Divider(height: 1, color: FigmaColors.hairline),
      _goalRow('주간 운동', '5', '회'),
    ]),
    const SizedBox(height: 16),
    _saveButton(context, '건강 목표가 저장되었어요'),
  ]);
}

Widget _goalRow(String label, String value, String unit) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 10),
  child: Row(
    children: <Widget>[
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
      Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: FigmaColors.primary,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        unit,
        style: const TextStyle(fontSize: 11, color: FigmaColors.textMuted),
      ),
    ],
  ),
);

// ───────────────────────────────────────────────────────── 알림 설정 ──

/// Notification preferences.
Future<void> showNotifSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: FigmaColors.sheetScrim,
    builder: (BuildContext ctx) => const _NotifSheet(),
  );
}

class _NotifSheet extends StatefulWidget {
  const _NotifSheet();

  @override
  State<_NotifSheet> createState() => _NotifSheetState();
}

class _NotifSheetState extends State<_NotifSheet> {
  final Map<String, bool> _on = <String, bool>{
    '식단 기록 알림': true,
    '운동 리마인더': true,
    '트레이너 메시지': true,
    'AI 코칭 조언': true,
    '주간 리포트': false,
  };

  @override
  Widget build(BuildContext context) {
    return _shell(context, '알림 설정', <Widget>[
      _card(<Widget>[
        for (final MapEntry<String, bool> e in _on.entries) ...<Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  e.key,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FigmaColors.ink,
                  ),
                ),
              ),
              Switch.adaptive(
                value: e.value,
                activeThumbColor: FigmaColors.primary,
                onChanged: (bool v) => setState(() => _on[e.key] = v),
              ),
            ],
          ),
          if (e.key != _on.keys.last)
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
    _supportRow(context, Icons.help_outline, '자주 묻는 질문'),
    _supportRow(context, Icons.chat_bubble_outline, '1:1 문의'),
    _supportRow(context, Icons.description_outlined, '이용약관'),
    _supportRow(context, Icons.privacy_tip_outlined, '개인정보 처리방침'),
    const SizedBox(height: 12),
    const Center(
      child: Text(
        'On-Care · 버전 1.0.0',
        style: TextStyle(fontSize: 12, color: FigmaColors.textFaint),
      ),
    ),
  ]);
}

Widget _supportRow(BuildContext context, IconData icon, String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: FigmaColors.statBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$label은(는) 준비 중이에요')));
        },
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

Widget _saveButton(BuildContext context, String message) => Row(
  children: <Widget>[
    Expanded(
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('항목을 눌러 값을 수정할 수 있어요')));
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: FigmaColors.primary,
          side: BorderSide(color: FigmaColors.primaryA(0.4)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.edit_outlined, size: 16),
        label: const Text(
          '수정',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: FilledButton(
        onPressed: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
        style: FilledButton.styleFrom(
          backgroundColor: FigmaColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          '저장',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    ),
  ],
);

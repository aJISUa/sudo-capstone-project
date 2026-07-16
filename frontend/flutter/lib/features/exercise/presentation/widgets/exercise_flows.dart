import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/design_system/figma/figma_kit.dart';
import 'package:oncare/features/exercise/domain/entities/exercise_week.dart';
import 'package:oncare/features/exercise/domain/entities/gym.dart';
import 'package:oncare/features/exercise/presentation/controllers/exercise_controller.dart';

const List<String> _weekdayLabels = <String>['월', '화', '수', '목', '금', '토', '일'];

/// The "운동 종류" chip order shared by the add/edit sheet.
const List<String> _exerciseTypeLabels = <String>[
  '걷기',
  '달리기',
  '스트레칭',
  '근력운동',
  '자전거',
  '기타',
];

/// Chip index → backend [ExerciseType].
ExerciseType _typeFromIndex(int i) => switch (i) {
  0 => ExerciseType.walking,
  1 => ExerciseType.cardio,
  2 => ExerciseType.stretching,
  3 => ExerciseType.strength,
  4 => ExerciseType.cardio,
  _ => ExerciseType.other,
};

/// [ExerciseType] → chip index (for pre-filling the edit sheet).
int _indexFromType(ExerciseType t) => switch (t) {
  ExerciseType.walking => 0,
  ExerciseType.cardio => 1,
  ExerciseType.stretching => 2,
  ExerciseType.strength => 3,
  ExerciseType.yoga => 2,
  ExerciseType.other => 5,
};

/// Rough kcal/min per type, used to estimate burn when the user only logs a
/// duration (matches the prototype's estimate ranges).
int _estimateCalories(ExerciseType type, int minutes) {
  final double perMin = switch (type) {
    ExerciseType.cardio => 9,
    ExerciseType.strength => 6,
    ExerciseType.walking => 4,
    ExerciseType.stretching => 3,
    ExerciseType.yoga => 3,
    ExerciseType.other => 5,
  };
  return (perMin * minutes).round();
}

Widget _shell(BuildContext context, Widget child) => SafeArea(
  top: false,
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
      maxWidth: 480,
    ),
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: child,
    ),
  ),
);

Widget _handle() => Container(
  margin: const EdgeInsets.only(top: 12, bottom: 4),
  width: 36,
  height: 4,
  decoration: BoxDecoration(
    color: const Color(0xFFDDE3EA),
    borderRadius: BorderRadius.circular(999),
  ),
);

// ─────────────────────────────────────────────────────── 운동 추가 ──

/// A compact "운동 추가" sheet: pick a type + duration/intensity, then save.
/// Pass [session] to open in edit mode (pre-filled → PUT); omit it to add.
Future<void> showExerciseAddSheet(
  BuildContext context, {
  ExerciseSession? session,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: FigmaColors.sheetScrim,
    builder: (BuildContext ctx) => _ExerciseAddSheet(session: session),
  );
}

class _ExerciseAddSheet extends ConsumerStatefulWidget {
  const _ExerciseAddSheet({this.session});

  final ExerciseSession? session;

  bool get isEdit => session != null;

  @override
  ConsumerState<_ExerciseAddSheet> createState() => _ExerciseAddSheetState();
}

class _ExerciseAddSheetState extends ConsumerState<_ExerciseAddSheet> {
  static const List<String> _types = _exerciseTypeLabels;
  static const List<String> _levels = <String>['가벼움', '보통', '높음'];
  late int _type = widget.session != null
      ? _indexFromType(widget.session!.type)
      : 1;
  int _level = 0;
  late double _minutes = widget.session?.minutes.toDouble() ?? 30;
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final int minutes = _minutes.round();
    if (minutes <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('운동 시간을 입력해주세요')),
      );
      return;
    }
    final ExerciseType type = _typeFromIndex(_type);
    final int calories = _estimateCalories(type, minutes);
    setState(() => _saving = true);
    try {
      // 서버(mock 모드는 drift)에 저장 → 주간 데이터 무효화로 통계·차트·목록 반영.
      final ExerciseSession? editing = widget.session;
      if (editing != null && editing.id != null) {
        await ref
            .read(exerciseRepositoryProvider)
            .updateSession(
              id: editing.id!,
              type: type,
              minutes: minutes,
              calories: calories,
              dayLabel: editing.dayLabel,
            );
      } else {
        await ref
            .read(exerciseRepositoryProvider)
            .addSession(
              type: type,
              minutes: minutes,
              calories: calories,
              dayLabel: _weekdayLabels[DateTime.now().weekday - 1],
            );
      }
      ref.invalidate(exerciseWeekProvider);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(widget.isEdit ? '운동 기록이 수정됐어요' : '운동이 기록됐어요'),
        ),
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
    return _shell(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(child: _handle()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.isEdit ? '운동 기록 수정' : '운동 추가',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: FigmaColors.ink,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _saving ? null : _save,
                  child: const Text(
                    '저장',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: FigmaColors.primary,
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
              children: <Widget>[
                const _Label('운동 종류'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (int i = 0; i < _types.length; i++)
                      _chip(
                        _types[i],
                        _type == i,
                        () => setState(() => _type = i),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    const _Label('운동 시간'),
                    const Spacer(),
                    Text(
                      '${_minutes.round()}분',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: FigmaColors.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _minutes,
                  min: 5,
                  max: 120,
                  divisions: 23,
                  activeColor: FigmaColors.primary,
                  onChanged: (double v) => setState(() => _minutes = v),
                ),
                const SizedBox(height: 12),
                const _Label('운동 강도'),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    for (int i = 0; i < _levels.length; i++) ...<Widget>[
                      Expanded(
                        child: _chip(
                          _levels[i],
                          _level == i,
                          () => setState(() => _level = i),
                          center: true,
                        ),
                      ),
                      if (i < _levels.length - 1) const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: FigmaColors.softBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.local_fire_department,
                        color: FigmaColors.heartOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          '예상 소모 칼로리',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: FigmaColors.textSub,
                          ),
                        ),
                      ),
                      Text(
                        '${(_minutes * 6).round()} kcal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: FigmaColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    String label,
    bool on,
    VoidCallback onTap, {
    bool center = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: center ? Alignment.center : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: on ? FigmaColors.primaryA(0.10) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: on ? FigmaColors.primary : FigmaColors.hairline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: on ? FigmaColors.primary : FigmaColors.textSub,
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: FigmaColors.ink,
    ),
  );
}

// ─────────────────────────────────────────────────────── 헬스장 찾기 ──

/// "헬스장 찾기" — a live search field, a map placeholder, and the nearby
/// gym list from [nearbyGymsProvider], filtered by the query.
Future<void> showGymLocatorSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: FigmaColors.sheetScrim,
    builder: (BuildContext ctx) => const _GymLocatorSheet(),
  );
}

class _GymLocatorSheet extends ConsumerStatefulWidget {
  const _GymLocatorSheet();

  @override
  ConsumerState<_GymLocatorSheet> createState() => _GymLocatorSheetState();
}

class _GymLocatorSheetState extends ConsumerState<_GymLocatorSheet> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Case-insensitive match on gym name or address; empty query returns all.
  List<Gym> _filter(List<Gym> gyms) {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return gyms;
    return gyms
        .where(
          (Gym g) =>
              g.name.toLowerCase().contains(q) ||
              g.address.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Gym>> async = ref.watch(nearbyGymsProvider);
    return _shell(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(child: _handle()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: <Widget>[
                Material(
                  color: FigmaColors.softBlue,
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
                        color: FigmaColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '헬스장 찾기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: FigmaColors.ink,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: FigmaColors.statBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.search,
                        size: 16,
                        color: FigmaColors.textFaint,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _search,
                          onChanged: (String v) => setState(() => _query = v),
                          textInputAction: TextInputAction.search,
                          style: const TextStyle(
                            fontSize: 13,
                            color: FigmaColors.ink,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: '헬스장, 지역으로 검색',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: FigmaColors.textFaint,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.close,
                              size: 15,
                              color: FigmaColors.textFaint,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const _MapPlaceholder(),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    const Text(
                      '주변 헬스장 · O2O 연동',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: FigmaColors.ink,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AiPill('✦ AI 분석', background: FigmaColors.primaryA(0.10)),
                  ],
                ),
                const SizedBox(height: 12),
                ...async.when(
                  data: (List<Gym> gyms) {
                    final List<Gym> results = _filter(gyms);
                    if (results.isEmpty) {
                      return <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              "'$_query'에 맞는 헬스장이 없어요",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: FigmaColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ];
                    }
                    return <Widget>[
                      for (int i = 0; i < results.length; i++) ...<Widget>[
                        _GymResult(
                          gym: results[i],
                          top: _query.trim().isEmpty && i == 0,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ];
                  },
                  loading: () => const <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      ),
                    ),
                  ],
                  error: (Object e, StackTrace _) => <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: <Widget>[
                          const Text(
                            '헬스장을 불러오지 못했어요.',
                            style: TextStyle(
                              fontSize: 13,
                              color: FigmaColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () =>
                                ref.invalidate(nearbyGymsProvider),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: FigmaColors.primary,
                              side: BorderSide(color: FigmaColors.primaryA(0.4)),
                            ),
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A nearby-gym result card driven by a real [Gym]. The two actions wire to
/// local flows (there is no O2O endpoint): 트레이너 채팅 opens the 1:1 상담
/// sheet, 건강 요약 전달 confirms then shows a success SnackBar.
class _GymResult extends StatelessWidget {
  const _GymResult({required this.gym, this.top = false});

  final Gym gym;
  final bool top;

  /// A short, real-data reason line for the AI-styled highlight box.
  String get _reason {
    if (gym.trainerName != null) {
      final String role = gym.trainerRole != null ? ' · ${gym.trainerRole}' : '';
      return '전담 트레이너 ${gym.trainerName}$role 상주';
    }
    if (gym.weekdayHours != null) {
      final String weekend = gym.weekendHours != null
          ? ' · 주말 ${gym.weekendHours}'
          : '';
      return '평일 ${gym.weekdayHours}$weekend 운영';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: top ? FigmaColors.primaryA(0.25) : FigmaColors.hairline,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (top) ...<Widget>[
            const AiPill(
              '✦ AI 추천 1순위',
              background: FigmaColors.primary,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      gym.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: FigmaColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      gym.address,
                      style: const TextStyle(
                        fontSize: 11,
                        color: FigmaColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.star,
                        size: 13,
                        color: Color(0xFFF5B400),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        gym.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: FigmaColors.ink,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${gym.distanceKm.toStringAsFixed(1)}km',
                    style: const TextStyle(
                      fontSize: 11,
                      color: FigmaColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (gym.tags.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: FigmaColors.softBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      for (final String t in gym.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: FigmaColors.primaryA(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: FigmaColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_reason.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      _reason,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: FigmaColors.ink,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: () => showGymChatSheet(context, gym: gym),
                  style: FilledButton.styleFrom(
                    backgroundColor: FigmaColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '트레이너 채팅',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _sendHealthSummary(context, gym.name),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FigmaColors.primary,
                    side: BorderSide(color: FigmaColors.primaryA(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '건강 요약 전달',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Confirms and "sends" the user's health summary to the gym/trainer. There is
/// no O2O backend yet, so this is a local confirm dialog + success SnackBar.
Future<void> _sendHealthSummary(BuildContext context, String gymName) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        '건강 요약 전달',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: FigmaColors.ink,
        ),
      ),
      content: Text(
        '최근 운동 기록과 건강 프로필 요약을\n$gymName 트레이너에게 전달할까요?',
        style: const TextStyle(
          fontSize: 13,
          height: 1.5,
          color: FigmaColors.textSub,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text(
            '취소',
            style: TextStyle(color: FigmaColors.textMuted),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(backgroundColor: FigmaColors.primary),
          child: const Text('전달하기'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  messenger.showSnackBar(
    SnackBar(content: Text('$gymName에 건강 요약을 전달했어요')),
  );
}

Widget _closeBtn(BuildContext ctx) => Material(
  color: const Color(0xFFF4F6F8),
  shape: const CircleBorder(),
  clipBehavior: Clip.antiAlias,
  child: InkWell(
    onTap: () => Navigator.of(ctx).pop(),
    child: const SizedBox(
      width: 32,
      height: 32,
      child: Icon(Icons.close, size: 16, color: FigmaColors.textSub),
    ),
  ),
);

Widget _infoRow(IconData icon, String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: FigmaColors.softBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: FigmaColors.primary),
      ),
      const SizedBox(width: 12),
      SizedBox(
        width: 78,
        child: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: FigmaColors.textMuted,
            ),
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: FigmaColors.ink,
              height: 1.35,
            ),
          ),
        ),
      ),
    ],
  ),
);

// ─────────────────────────────────────────────────────── 지도 그래픽 ──

/// A lightweight stylised map (roads, blocks, pins) so the locator reads as a
/// map area without embedding a live Kakao Map.
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 140,
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: CustomPaint(painter: _MapPainter())),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '카카오맵 영역',
                  style: TextStyle(fontSize: 9, color: FigmaColors.textMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEDEEE9),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.8, w, h * 0.2),
      Paint()..color = const Color(0xFFCFE4EF),
    );
    final Paint green = Paint()..color = const Color(0xFFCFE0C4);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.05, h * 0.08, w * 0.17, h * 0.22),
      green,
    );
    canvas.drawRect(Rect.fromLTWH(w * 0.63, h * 0.5, w * 0.2, h * 0.22), green);
    final Paint beige = Paint()..color = const Color(0xFFE3D9C7);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.31, h * 0.1, w * 0.22, h * 0.26),
      beige,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.05, h * 0.44, w * 0.2, h * 0.28),
      beige,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.61, h * 0.08, w * 0.33, h * 0.28),
      beige,
    );
    final Paint road = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, h * 0.4), Offset(w, h * 0.4), road);
    canvas.drawLine(Offset(0, h * 0.74), Offset(w, h * 0.74), road);
    canvas.drawLine(Offset(w * 0.28, 0), Offset(w * 0.28, h), road);
    canvas.drawLine(Offset(w * 0.58, 0), Offset(w * 0.58, h), road);
    canvas.drawLine(Offset(w * 0.85, 0), Offset(w * 0.85, h), road);
    _pin(canvas, Offset(w * 0.28, h * 0.4), selected: true);
    _pin(canvas, Offset(w * 0.58, h * 0.26), selected: false);
    _pin(canvas, Offset(w * 0.72, h * 0.6), selected: false);
  }

  void _pin(Canvas c, Offset p, {required bool selected}) {
    const double r = 7;
    if (selected) {
      c.drawCircle(
        p,
        r * 2,
        Paint()..color = FigmaColors.primary.withValues(alpha: 0.18),
      );
    }
    final Path path = Path()
      ..moveTo(p.dx, p.dy + r * 1.9)
      ..cubicTo(
        p.dx - r * 1.2,
        p.dy + r * 0.2,
        p.dx - r,
        p.dy - r,
        p.dx,
        p.dy - r,
      )
      ..cubicTo(
        p.dx + r,
        p.dy - r,
        p.dx + r * 1.2,
        p.dy + r * 0.2,
        p.dx,
        p.dy + r * 1.9,
      )
      ..close();
    c.drawPath(path, Paint()..color = FigmaColors.primary);
    c.drawCircle(
      Offset(p.dx, p.dy - r * 0.15),
      r * 0.4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────── 헬스장 정보 ──

/// Gym detail sheet opened from the "헬스장 정보" button, driven by [gym].
Future<void> showGymInfoSheet(BuildContext context, Gym gym) {
  final String hours = gym.weekdayHours != null
      ? '평일 ${gym.weekdayHours}'
            '${gym.weekendHours != null ? '\n주말 ${gym.weekendHours}' : ''}'
      : '';
  final String trainer = gym.trainerName != null
      ? '${gym.trainerName}${gym.trainerRole != null ? ' · ${gym.trainerRole}' : ''}'
      : '';
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: FigmaColors.sheetScrim,
    builder: (BuildContext ctx) => _shell(
      ctx,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(child: _handle()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    '헬스장 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: FigmaColors.ink,
                    ),
                  ),
                ),
                _closeBtn(ctx),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: <Widget>[
                const _MapPlaceholder(),
                const SizedBox(height: 14),
                Text(
                  gym.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: FigmaColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    const Icon(Icons.star, size: 15, color: Color(0xFFF5B400)),
                    const SizedBox(width: 3),
                    Text(
                      gym.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: FigmaColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _infoRow(
                  Icons.place_outlined,
                  '주소',
                  '${gym.address} · ${gym.distanceKm.toStringAsFixed(1)}km',
                ),
                if (hours.isNotEmpty)
                  _infoRow(Icons.schedule, '운영시간', hours),
                if (gym.phone != null)
                  _infoRow(Icons.call_outlined, '전화', gym.phone!),
                if (gym.tags.isNotEmpty)
                  _infoRow(
                    Icons.fitness_center,
                    '전문 분야',
                    gym.tags.join(' · '),
                  ),
                if (trainer.isNotEmpty)
                  _infoRow(Icons.person_outline, '전담 트레이너', trainer),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────── 1:1 상담 ──

/// 1:1 consultation chat with the gym's trainer, personalised from [gym].
Future<void> showGymChatSheet(BuildContext context, {Gym? gym}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: FigmaColors.sheetScrim,
    builder: (BuildContext ctx) =>
        _GymChatSheet(trainerName: gym?.trainerName, gymName: gym?.name),
  );
}

class _GymMsg {
  const _GymMsg(this.text, {required this.mine});
  final String text;
  final bool mine;
}

class _GymChatSheet extends StatefulWidget {
  const _GymChatSheet({this.trainerName, this.gymName});

  final String? trainerName;
  final String? gymName;

  @override
  State<_GymChatSheet> createState() => _GymChatSheetState();
}

class _GymChatSheetState extends State<_GymChatSheet> {
  final TextEditingController _c = TextEditingController();
  late final String _trainer = widget.trainerName ?? '김트레이너';
  late final String _gym = widget.gymName ?? '강남 피트니스 센터';
  late final List<_GymMsg> _msgs = <_GymMsg>[
    _GymMsg('안녕하세요, $_trainer입니다. 😊\n무엇을 도와드릴까요?', mine: false),
  ];
  static const List<String> _chips = <String>['PT 상담', '이용권 문의', '방문 예약'];

  bool get _started => _msgs.any((_GymMsg m) => m.mine);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final String t = (preset ?? _c.text).trim();
    if (t.isEmpty) return;
    setState(() {
      _msgs.add(_GymMsg(t, mine: true));
      _msgs.add(
        const _GymMsg(
          '네, 확인했어요! 담당 트레이너가 곧 답변드릴게요. 편한 방문 시간도 알려주세요. 🙌',
          mine: false,
        ),
      );
      _c.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _shell(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(child: _handle()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 20,
                    color: FigmaColors.textMuted,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _trainer,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: FigmaColors.ink,
                        ),
                      ),
                      Text(
                        '$_gym · 1:1 상담',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: FigmaColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _closeBtn(context),
              ],
            ),
          ),
          Flexible(
            child: Container(
              color: const Color(0xFFF5F7FA),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                children: <Widget>[
                  for (final _GymMsg m in _msgs) ...<Widget>[
                    _bubble(m),
                    const SizedBox(height: 10),
                  ],
                  if (!_started)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        for (final String q in _chips)
                          GestureDetector(
                            onTap: () => _send(q),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: FigmaColors.primaryA(0.3),
                                  width: 1.4,
                                ),
                              ),
                              child: Text(
                                q,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: FigmaColors.primary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: FigmaColors.softBlue,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: FigmaColors.primaryA(0.22)),
                    ),
                    child: TextField(
                      controller: _c,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: '메시지를 입력하세요',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: FigmaColors.textFaint,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _send(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: FigmaColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(_GymMsg m) {
    return Align(
      alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: m.mine ? FigmaColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: m.mine ? null : Border.all(color: FigmaColors.hairline),
        ),
        child: Text(
          m.text,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: m.mine ? Colors.white : FigmaColors.ink,
          ),
        ),
      ),
    );
  }
}

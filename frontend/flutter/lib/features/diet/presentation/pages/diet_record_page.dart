import 'package:flutter/material.dart';

import 'package:oncare/design_system/figma/figma_kit.dart';
import 'package:oncare/features/diet/presentation/widgets/diet_flows.dart';
import 'package:oncare/features/notification/presentation/widgets/notification_panel.dart';
import 'package:oncare/shared/widgets/modals/right_slide_panel.dart';
import 'package:oncare/shared/widgets/modals/schedule_calendar_sheet.dart';

/// 식단 tab, rebuilt to match the On-Care Figma redesign. The weekly date
/// strip is centred on today (per the product request), the nutrition summary /
/// AI feedback / meal log follow the mockup, and the "식단 추가" and meal-edit
/// flows open as bottom sheets.
class DietRecordPage extends StatefulWidget {
  const DietRecordPage({super.key});

  @override
  State<DietRecordPage> createState() => _DietRecordPageState();
}

const List<String> _weekdayLabels = <String>['월', '화', '수', '목', '금', '토', '일'];

class _DietRecordPageState extends State<DietRecordPage> {
  int _weekShift = 0; // whole-week steps away from today
  late DateTime _selected;

  DateTime get _today {
    final DateTime n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _selected = _today;
  }

  int _weekOfMonth(DateTime d) {
    final DateTime first = DateTime(d.year, d.month);
    final int offset = first.weekday - 1; // days from Monday
    return ((d.day + offset - 1) / 7).floor() + 1;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = _today;
    // Window is always centred on today (+ whole-week shifts): 3 days before,
    // today in the middle, 3 days after.
    final DateTime center = today.add(Duration(days: _weekShift * 7));
    final List<DateTime> days = List<DateTime>.generate(
      7,
      (int i) => center.add(Duration(days: i - 3)),
    );
    final bool atToday = _weekShift == 0 && _selected == today;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 108),
              children: <Widget>[
                FigmaTabHeader(
                  title: '식단',
                  onBell: () => showRightSlidePanel<void>(
                    context,
                    content: const NotificationPanelBody(),
                  ),
                  onCalendar: () => showScheduleCalendarSheet(context),
                ),
                _DateStrip(
                  days: days,
                  today: today,
                  selected: _selected,
                  weekLabel: '${center.month}월 ${_weekOfMonth(center)}주차',
                  showTodayButton: !atToday,
                  onSelect: (DateTime d) => setState(() => _selected = d),
                  onPrev: () => setState(() => _weekShift -= 1),
                  onNext: _weekShift >= 0
                      ? null
                      : () => setState(() => _weekShift += 1),
                  onToday: () => setState(() {
                    _weekShift = 0;
                    _selected = today;
                  }),
                ),
                const SizedBox(height: 8),
                const _NutritionSummary(),
                const SizedBox(height: 20),
                const _AiFeedback(),
                const SizedBox(height: 20),
                _MealLog(
                  onAdd: () => showDietAddSheet(context),
                  onEditMeal: (DietMeal m) => showMealEditSheet(context, m),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── date strip ──

class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.days,
    required this.today,
    required this.selected,
    required this.weekLabel,
    required this.showTodayButton,
    required this.onSelect,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  final List<DateTime> days;
  final DateTime today;
  final DateTime selected;
  final String weekLabel;
  final bool showTodayButton;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrev;
  final VoidCallback? onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  weekLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: FigmaColors.textSub,
                  ),
                ),
                if (showTodayButton)
                  GestureDetector(
                    onTap: onToday,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: FigmaColors.primaryA(0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: FigmaColors.primaryA(0.25)),
                      ),
                      child: const Text(
                        '오늘로',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: FigmaColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _Arrow(icon: Icons.chevron_left, onTap: onPrev),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    for (final DateTime d in days)
                      _DayCell(
                        day: d,
                        isToday: d == today,
                        isSelected: d == selected,
                        onTap: () => onSelect(d),
                      ),
                  ],
                ),
              ),
              _Arrow(icon: Icons.chevron_right, onTap: onNext),
            ],
          ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.35 : 1,
      child: Material(
        color: FigmaColors.softBlue,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(icon, size: 16, color: FigmaColors.primary),
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = isSelected || isToday
        ? FigmaColors.primary
        : FigmaColors.textFaint;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            _weekdayLabels[day.weekday - 1],
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? FigmaColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: FigmaColors.primaryA(0.40),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? Colors.white
                    : isToday
                    ? FigmaColors.primary
                    : FigmaColors.textSub,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────── nutrition summary ──

class _NutritionSummary extends StatelessWidget {
  const _NutritionSummary();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '오늘의 영양 요약',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: FigmaColors.ink,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryTile(
                  label: '칼로리',
                  value: '1420',
                  unit: 'kcal',
                  color: FigmaColors.primary,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _SummaryTile(
                  label: '나트륨',
                  value: '2100',
                  unit: 'mg',
                  color: FigmaColors.orange,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _SummaryTile(
                  label: '당류',
                  value: '45',
                  unit: 'g',
                  color: FigmaColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: FigmaColors.textSub,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            unit,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── AI feedback ──

class _AiFeedback extends StatelessWidget {
  const _AiFeedback();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: FigmaColors.softBlue,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FigmaColors.primaryA(0.15)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                OniAvatar(size: 40),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'AI 피드백',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: FigmaColors.primary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '오늘 나트륨이 2100mg으로 목표(2000mg)를 초과했어요.\n내일은 국물류를 줄이면 균형을 맞출 수 있어요.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: FigmaColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: <Widget>[
                Text('📤', style: TextStyle(fontSize: 10)),
                SizedBox(width: 6),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: FigmaColors.textMuted,
                      ),
                      children: <InlineSpan>[
                        TextSpan(text: '오늘의 식단 분석이 '),
                        TextSpan(
                          text: '김트레이너님',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8A929E),
                          ),
                        ),
                        TextSpan(text: '에게 자동 전송됐어요'),
                      ],
                    ),
                  ),
                ),
                Icon(Icons.check, size: 13, color: FigmaColors.statusGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── meal log ──

class _MealLog extends StatelessWidget {
  const _MealLog({required this.onAdd, required this.onEditMeal});

  final VoidCallback onAdd;
  final ValueChanged<DietMeal> onEditMeal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                '오늘의 식단',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: FigmaColors.ink,
                ),
              ),
              const Spacer(),
              _AddButton(onTap: onAdd),
            ],
          ),
          const SizedBox(height: 12),
          for (final DietMeal m in kDietMeals) ...<Widget>[
            _MealCard(meal: m, onTap: () => onEditMeal(m)),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FigmaColors.primary,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.add, size: 13, color: Colors.white),
              SizedBox(width: 4),
              Text(
                '식단 추가',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onTap});
  final DietMeal meal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: FigmaColors.primaryA(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        meal.badge,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: FigmaColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      meal.time,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: FigmaColors.textFaint,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${meal.total} kcal',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: FigmaColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: FigmaColors.textFaint,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: FigmaColors.hairline),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: meal.thumbBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            meal.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const Text(
                            '사진 분석',
                            style: TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w600,
                              color: FigmaColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          for (final DietFood f in meal.items)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      f.name,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF3A3A4A),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${f.kcal} kcal',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: FigmaColors.textSub,
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
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    for (final DietTag t in meal.tags)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: t.over
                              ? const Color(0x1AFF5841)
                              : FigmaColors.primaryA(0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          t.label,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: t.over
                                ? const Color(0xFFFF5841)
                                : FigmaColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

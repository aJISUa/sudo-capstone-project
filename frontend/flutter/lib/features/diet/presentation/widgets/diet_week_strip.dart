import 'package:flutter/material.dart';

import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/radius.dart';
import 'package:oncare/design_system/tokens/spacing.dart';

/// Date header + horizontal week picker shown at the top of the Diet
/// tab. Sunday-to-Saturday strip centred on the [selectedDay], with
/// chevrons to scrub the visible week. Purely presentational — the
/// underlying day's data still comes from the diet repository.
class DietWeekStrip extends StatelessWidget {
  const DietWeekStrip({
    required this.selectedDay,
    required this.onSelect,
    required this.onShiftWeek,
    super.key,
  });

  /// The day currently highlighted in the strip and reflected in the
  /// header.
  final DateTime selectedDay;

  /// Called when the user taps a day cell.
  final ValueChanged<DateTime> onSelect;

  /// `-1` = previous week, `+1` = next week.
  final ValueChanged<int> onShiftWeek;

  static const List<String> _weekdayShort = <String>[
    '일',
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
  ];

  String _formatHeader(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    // weekday: 1=Mon .. 7=Sun → re-map to Sunday-first index 0..6
    final dow = _weekdayShort[d.weekday % 7];
    return '$mm. $dd. ($dow)';
  }

  DateTime _sundayOf(DateTime d) {
    final dayDate = DateTime(d.year, d.month, d.day);
    // weekday: Mon=1..Sun=7; offset back to Sunday.
    final offset = dayDate.weekday % 7;
    return dayDate.subtract(Duration(days: offset));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sunday = _sundayOf(selectedDay);
    final today = DateTime.now();
    final week = <DateTime>[
      for (int i = 0; i < 7; i++) sunday.add(Duration(days: i)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Date header.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _formatHeader(selectedDay),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 22,
                color: AppColors.foreground,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Week strip.
        Row(
          children: <Widget>[
            _ChevronButton(
              icon: Icons.chevron_left,
              onTap: () => onShiftWeek(-1),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  for (final d in week)
                    _DayCell(
                      date: d,
                      label: _weekdayShort[d.weekday % 7],
                      selected: _isSameDay(d, selectedDay),
                      isToday: _isSameDay(d, today),
                      onTap: () => onSelect(d),
                    ),
                ],
              ),
            ),
            _ChevronButton(
              icon: Icons.chevron_right,
              onTap: () => onShiftWeek(1),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChevronButton extends StatelessWidget {
  const _ChevronButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Icon(icon, size: 22, color: AppColors.mutedForeground),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.label,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final String label;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cellBg = selected ? AppColors.primary : Colors.transparent;
    final dayColor = selected
        ? Colors.white
        : (isToday ? AppColors.primary : AppColors.foreground);
    final labelColor = selected
        ? Colors.white.withValues(alpha: 0.85)
        : AppColors.mutedForeground;

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(AppRadius.lg),
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: cellBg,
          borderRadius: const BorderRadius.all(AppRadius.lg),
        ),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: labelColor),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: dayColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:oncare/design_system/figma/figma_kit.dart';

/// A single logged food item.
class DietFood {
  const DietFood(this.name, this.kcal);
  final String name;
  final int kcal;
}

/// A nutrient chip on a meal card (`over` = above the daily target → red).
class DietTag {
  const DietTag(this.label, {this.over = false});
  final String label;
  final bool over;
}

/// One meal in the daily log.
class DietMeal {
  const DietMeal({
    required this.badge,
    required this.time,
    required this.total,
    required this.emoji,
    required this.thumbBg,
    required this.items,
    required this.tags,
    required this.sodium,
    required this.sugar,
  });

  final String badge;
  final String time;
  final int total;
  final String emoji;
  final Color thumbBg;
  final List<DietFood> items;
  final List<DietTag> tags;
  final int sodium;
  final int sugar;
}

const List<DietMeal> kDietMeals = <DietMeal>[
  DietMeal(
    badge: '아침',
    time: '08:20',
    total: 315,
    emoji: '🥣',
    thumbBg: Color(0xFFFFF3E0),
    items: <DietFood>[
      DietFood('오트밀', 220),
      DietFood('바나나 1개', 90),
      DietFood('아메리카노', 5),
    ],
    tags: <DietTag>[DietTag('나트륨 380mg'), DietTag('당류 18g')],
    sodium: 380,
    sugar: 18,
  ),
  DietMeal(
    badge: '점심',
    time: '12:40',
    total: 530,
    emoji: '🥗',
    thumbBg: Color(0xFFE8F5E9),
    items: <DietFood>[
      DietFood('닭가슴살 샐러드', 380),
      DietFood('현미밥 반공기', 150),
    ],
    tags: <DietTag>[DietTag('나트륨 1120mg', over: true), DietTag('당류 14g')],
    sodium: 1120,
    sugar: 14,
  ),
  DietMeal(
    badge: '저녁',
    time: '19:00',
    total: 575,
    emoji: '🐟',
    thumbBg: Color(0xFFE3F2FD),
    items: <DietFood>[
      DietFood('연어 스테이크', 420),
      DietFood('구운 야채', 155),
    ],
    tags: <DietTag>[DietTag('나트륨 600mg'), DietTag('당류 13g')],
    sodium: 600,
    sugar: 13,
  ),
];

Widget _sheetShell(BuildContext context, Widget child) {
  return SafeArea(
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
}

Widget _sheetHandle() => Container(
  margin: const EdgeInsets.only(top: 12, bottom: 4),
  width: 36,
  height: 4,
  decoration: BoxDecoration(
    color: const Color(0xFFDDE3EA),
    borderRadius: BorderRadius.circular(999),
  ),
);

// ─────────────────────────────────────────────────── 식단 추가하기 ──

/// "식단 추가하기" — pick a photo source, then show the AI analysis result.
Future<void> showDietAddSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: FigmaColors.sheetScrim,
    builder: (BuildContext ctx) => _sheetShell(
      ctx,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(child: _sheetHandle()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        '식단 추가하기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: FigmaColors.ink,
                        ),
                      ),
                    ),
                    _CircleClose(onTap: () => Navigator.of(ctx).pop()),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  '사진으로 음식을 분석해요',
                  style: TextStyle(fontSize: 12, color: FigmaColors.textMuted),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              children: <Widget>[
                _SourceOption(
                  icon: Icons.image_outlined,
                  iconBg: FigmaColors.primaryA(0.12),
                  iconColor: FigmaColors.primary,
                  title: '사진 선택하기',
                  subtitle: '갤러리에서 음식 사진 선택',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    showDietResultSheet(context);
                  },
                ),
                const SizedBox(height: 12),
                _SourceOption(
                  icon: Icons.photo_camera_outlined,
                  iconBg: FigmaColors.greenA(0.12),
                  iconColor: FigmaColors.greenText,
                  title: '사진 찍기',
                  subtitle: '카메라로 음식 촬영',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    showDietResultSheet(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FigmaColors.primaryA(0.15)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: FigmaColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: FigmaColors.textMuted,
                      ),
                    ),
                  ],
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
    );
  }
}

// ─────────────────────────────────────────────────── 분석 완료 ──

/// AI analysis result sheet shown after picking a photo.
Future<void> showDietResultSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: FigmaColors.sheetScrim,
    builder: (BuildContext ctx) => _sheetShell(
      ctx,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(child: _sheetHandle()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: <Widget>[
                const OniAvatar(),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '분석 완료!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: FigmaColors.ink,
                        ),
                      ),
                      Text(
                        'AI 영양 분석 결과',
                        style: TextStyle(
                          fontSize: 12,
                          color: FigmaColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _CircleClose(onTap: () => Navigator.of(ctx).pop()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: FigmaColors.softBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '인식된 음식',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: FigmaColors.primary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '닭가슴살 샐러드 · 현미밥 반공기',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: FigmaColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '영양 분석 결과 (수정 가능)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: FigmaColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const _ResultRow(label: '칼로리', value: '486', unit: 'kcal'),
                const SizedBox(height: 8),
                const _ResultRow(label: '나트륨', value: '820', unit: 'mg'),
                const SizedBox(height: 8),
                const _ResultRow(label: '당류', value: '12', unit: 'g'),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: FigmaColors.primary,
                          side: BorderSide(color: FigmaColors.primaryA(0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text(
                          '수정하기',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('식단이 저장되었어요')),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: FigmaColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.save_outlined, size: 16),
                        label: const Text(
                          '저장하기',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value, required this.unit});
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: FigmaColors.statBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: FigmaColors.ink,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: FigmaColors.primary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            unit,
            style: const TextStyle(fontSize: 12, color: FigmaColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────── 식사 수정 ──

/// Meal-edit sheet: meal type, time, editable food list + nutrient values.
Future<void> showMealEditSheet(BuildContext context, DietMeal meal) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: FigmaColors.sheetScrim,
    builder: (BuildContext ctx) => _MealEditSheet(meal: meal),
  );
}

class _MealEditSheet extends StatefulWidget {
  const _MealEditSheet({required this.meal});
  final DietMeal meal;

  @override
  State<_MealEditSheet> createState() => _MealEditSheetState();
}

class _MealEditSheetState extends State<_MealEditSheet> {
  static const List<String> _types = <String>['아침', '점심', '저녁', '간식'];
  late String _type = widget.meal.badge;
  late List<DietFood> _foods = List<DietFood>.of(widget.meal.items);

  int get _total => _foods.fold(0, (int a, DietFood f) => a + f.kcal);

  @override
  Widget build(BuildContext context) {
    return _sheetShell(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(child: _sheetHandle()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: <Widget>[
                _CircleClose(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    '${widget.meal.badge} 식단',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: FigmaColors.ink,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('식단이 저장되었어요')),
                    );
                  },
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
                _card(<Widget>[
                  const _FieldLabel('식사 정보'),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      for (final String t in _types) ...<Widget>[
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _type = t),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _type == t
                                    ? FigmaColors.primaryA(0.10)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _type == t
                                      ? FigmaColors.primary
                                      : FigmaColors.hairline,
                                ),
                              ),
                              child: Text(
                                t,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _type == t
                                      ? FigmaColors.primary
                                      : FigmaColors.textSub,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (t != _types.last) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const _FieldLabel('먹은 시간'),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: FigmaColors.statBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: FigmaColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.meal.time,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: FigmaColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 12),
                _card(<Widget>[
                  Row(
                    children: <Widget>[
                      const Expanded(child: _FieldLabel('먹은 음식')),
                      GestureDetector(
                        onTap: () => setState(
                          () => _foods = <DietFood>[
                            ..._foods,
                            const DietFood('새 음식', 0),
                          ],
                        ),
                        child: const Text(
                          '+ 음식 추가',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: FigmaColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '음식명과 칼로리를 수정할 수 있어요',
                    style: TextStyle(fontSize: 11, color: FigmaColors.textMuted),
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < _foods.length; i++) ...<Widget>[
                    _FoodRow(
                      index: i + 1,
                      food: _foods[i],
                      onDelete: () =>
                          setState(() => _foods = <DietFood>[..._foods]..removeAt(i)),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const Divider(height: 16, color: FigmaColors.hairline),
                  Row(
                    children: <Widget>[
                      const Text(
                        '총 칼로리',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: FigmaColors.textSub,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$_total kcal',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: FigmaColors.primary,
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 12),
                _card(<Widget>[
                  const _FieldLabel('영양 정보'),
                  const SizedBox(height: 4),
                  const Text(
                    '분석된 값을 직접 수정할 수 있어요',
                    style: TextStyle(fontSize: 11, color: FigmaColors.textMuted),
                  ),
                  const SizedBox(height: 10),
                  _NutrientRow(
                    label: '나트륨',
                    hint: '하루 권장 2,000mg 이하',
                    value: '${widget.meal.sodium}',
                    unit: 'mg',
                  ),
                  const SizedBox(height: 10),
                  _NutrientRow(
                    label: '당류',
                    hint: '하루 권장 50g 이하',
                    value: '${widget.meal.sugar}',
                    unit: 'g',
                  ),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('식단이 삭제되었어요')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF3B30),
                  side: const BorderSide(color: Color(0x33FF3B30)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text(
                  '식단 삭제',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: FigmaColors.statBg,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
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

class _FoodRow extends StatelessWidget {
  const _FoodRow({
    required this.index,
    required this.food,
    required this.onDelete,
  });
  final int index;
  final DietFood food;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FigmaColors.hairline),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: FigmaColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              food.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: FigmaColors.ink,
              ),
            ),
          ),
          Text(
            '${food.kcal}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: FigmaColors.ink,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'kcal',
            style: TextStyle(fontSize: 11, color: FigmaColors.textMuted),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.cancel,
              size: 18,
              color: Color(0xFFFFB4A8),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.unit,
  });
  final String label;
  final String hint;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FigmaColors.hairline),
      ),
      child: Row(
        children: <Widget>[
          Container(width: 3, height: 34, color: FigmaColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: FigmaColors.ink,
                  ),
                ),
                Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 10,
                    color: FigmaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: FigmaColors.ink,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            unit,
            style: const TextStyle(fontSize: 12, color: FigmaColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _CircleClose extends StatelessWidget {
  const _CircleClose({required this.onTap, this.icon = Icons.close});
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F6F8),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 16, color: FigmaColors.textSub),
        ),
      ),
    );
  }
}

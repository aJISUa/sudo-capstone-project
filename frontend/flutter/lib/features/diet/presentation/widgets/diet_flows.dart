import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:oncare/design_system/figma/figma_kit.dart';
import 'package:oncare/features/diet/domain/entities/diet_analysis.dart';
import 'package:oncare/features/diet/domain/entities/diet_day.dart';
import 'package:oncare/features/diet/presentation/controllers/diet_controller.dart';

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

/// One meal in the daily log. [id] is the backend entry id (null for a
/// not-yet-persisted draft) and is required to edit or delete the entry.
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
    this.id,
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
  final String? id;
}

/// Korean meal badge → backend `meal_type` string used by the diet API.
const Map<String, String> _mealTypeByBadge = <String, String>{
  '아침': 'breakfast',
  '점심': 'lunch',
  '저녁': 'dinner',
  '간식': 'snack',
};

/// Best-guess meal type for a new entry, based on the current time of day.
String _currentMealType() {
  final int h = DateTime.now().hour;
  if (h < 11) return 'breakfast';
  if (h < 15) return 'lunch';
  if (h < 21) return 'dinner';
  return 'snack';
}

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

/// Pick a food photo from [source], then hand it to the AI analysis sheet.
/// Silently returns if the user cancels the picker.
Future<void> _pickAndAnalyze(
  BuildContext sheetContext,
  BuildContext pageContext,
  ImageSource source,
) async {
  final XFile? file = await ImagePicker().pickImage(
    source: source,
    imageQuality: 85,
  );
  if (file == null) return;
  final Uint8List bytes = await file.readAsBytes();
  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
  if (!pageContext.mounted) return;
  await showDietResultSheet(pageContext, bytes, _currentMealType());
}

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
                  onTap: () =>
                      _pickAndAnalyze(ctx, context, ImageSource.gallery),
                ),
                const SizedBox(height: 12),
                _SourceOption(
                  icon: Icons.photo_camera_outlined,
                  iconBg: FigmaColors.greenA(0.12),
                  iconColor: FigmaColors.greenText,
                  title: '사진 찍기',
                  subtitle: '카메라로 음식 촬영',
                  onTap: () => _pickAndAnalyze(ctx, context, ImageSource.camera),
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
/// Runs the real `POST /diet/analyze` on the picked [imageBytes] and shows the
/// recognised foods + nutrition. The backend persists the entry as part of
/// analysis, so a successful result refreshes [dietTodayProvider].
Future<void> showDietResultSheet(
  BuildContext context,
  Uint8List imageBytes,
  String mealType,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: FigmaColors.sheetScrim,
    builder: (BuildContext ctx) =>
        _ResultSheet(imageBytes: imageBytes, mealType: mealType),
  );
}

class _ResultSheet extends ConsumerStatefulWidget {
  const _ResultSheet({required this.imageBytes, required this.mealType});
  final Uint8List imageBytes;
  final String mealType;

  @override
  ConsumerState<_ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends ConsumerState<_ResultSheet> {
  DietAnalysisResult? _result;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final DietAnalysisResult result = await ref
          .read(dietRepositoryProvider)
          .analyze(
            imageBytes: widget.imageBytes,
            filename: 'meal.jpg',
            mealType: widget.mealType,
          );
      if (!mounted) return;
      // analyze() already persisted the entry → refresh the day's summary/list.
      ref.invalidate(dietTodayProvider);
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

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
                const OniAvatar(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _loading
                            ? '분석 중…'
                            : _failed
                            ? '분석 실패'
                            : '분석 완료!',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: FigmaColors.ink,
                        ),
                      ),
                      const Text(
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
                _CircleClose(onTap: () => Navigator.of(context).pop()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: _body(),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(height: 14),
            Text(
              '사진 속 음식을 분석하고 있어요',
              style: TextStyle(fontSize: 13, color: FigmaColors.textMuted),
            ),
          ],
        ),
      );
    }
    if (_failed || _result == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: <Widget>[
            const Text(
              '분석에 실패했어요. 잠시 후 다시 시도해 주세요.',
              style: TextStyle(fontSize: 13, color: FigmaColors.textMuted),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _run,
                style: FilledButton.styleFrom(
                  backgroundColor: FigmaColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  '다시 시도',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final DietAnalysisResult r = _result!;
    final String recognized = r.foods.map((RecognizedFood f) => f.name).join(' · ');
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: FigmaColors.softBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '인식된 음식',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: FigmaColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                recognized.isEmpty ? '인식된 음식이 없어요' : recognized,
                style: const TextStyle(
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
            '영양 분석 결과',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: FigmaColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _ResultRow(label: '칼로리', value: '${r.totalCalories}', unit: 'kcal'),
        const SizedBox(height: 8),
        _ResultRow(label: '나트륨', value: '${r.totalSodiumMg}', unit: 'mg'),
        const SizedBox(height: 8),
        _ResultRow(label: '당류', value: '${r.totalSugarG}', unit: 'g'),
        if (r.coachComment.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: FigmaColors.statBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              r.coachComment,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: FigmaColors.textBody,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
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
            icon: const Icon(Icons.check, size: 16),
            label: const Text(
              '완료',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
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

class _MealEditSheet extends ConsumerStatefulWidget {
  const _MealEditSheet({required this.meal});
  final DietMeal meal;

  @override
  ConsumerState<_MealEditSheet> createState() => _MealEditSheetState();
}

class _MealEditSheetState extends ConsumerState<_MealEditSheet> {
  static const List<String> _types = <String>['아침', '점심', '저녁', '간식'];
  late String _type = widget.meal.badge;
  late List<DietFood> _foods = List<DietFood>.of(widget.meal.items);
  bool _busy = false;

  int get _total => _foods.fold(0, (int a, DietFood f) => a + f.kcal);

  Future<void> _save() async {
    final String? id = widget.meal.id;
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (id == null) {
      navigator.pop();
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(dietRepositoryProvider)
          .updateEntry(
            id: id,
            mealType: _mealTypeByBadge[_type],
            foods: <FoodItem>[
              for (final DietFood f in _foods)
                FoodItem(name: f.name, calories: f.kcal),
            ],
            totalCalories: _total,
          );
      ref.invalidate(dietTodayProvider);
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('식단이 저장되었어요')),
      );
    } catch (_) {
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('저장에 실패했어요. 잠시 후 다시 시도해 주세요')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final String? id = widget.meal.id;
    if (id == null) {
      Navigator.of(context).pop();
      return;
    }
    final bool ok =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext ctx) => AlertDialog(
            title: const Text('식단 기록 삭제'),
            content: const Text('이 식단 기록을 삭제할까요?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF3B30),
                ),
                child: const Text('삭제'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !mounted) return;

    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(dietRepositoryProvider).deleteEntry(id);
      ref.invalidate(dietTodayProvider);
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('식단이 삭제되었어요')),
      );
    } catch (_) {
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('삭제에 실패했어요. 잠시 후 다시 시도해 주세요')),
      );
    }
  }

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
                  onPressed: _busy ? null : _save,
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
                onPressed: _busy ? null : _confirmDelete,
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

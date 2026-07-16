import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:oncare/app/router/routes.dart';
import 'package:oncare/design_system/figma/figma_kit.dart';
import 'package:oncare/shared/widgets/coaching_sheet.dart';

/// The Home tab, rebuilt to match the On-Care Figma redesign.
///
/// Sections (top → bottom): header, greeting, AI coaching banner, 식단/운동
/// summary cards, 영양 현황 (weekly trend + AI analysis), 이번 주 AI 추천 식단
/// carousel, 오늘의 일정. Per the product decision the 건강 지표 (심박수·수면)
/// cards and the sleep AI-coaching banner are intentionally omitted.
class DashboardContent extends StatelessWidget {
  const DashboardContent({
    super.key,
    this.onNotificationTap,
    this.onCalendarTap,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onCalendarTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 108),
          children: <Widget>[
            _HomeHeader(
              onNotificationTap: onNotificationTap,
              onCalendarTap: onCalendarTap,
              onProfileTap: () => context.go(AppRoutes.myHealth),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                '민수님, 오늘도 가볍게 시작해요 👋',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: FigmaColors.textMuted,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: _CoachingBanner(onTap: () => showCoachingSheet(context)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: _DietSummaryCard(
                        onOpen: () => context.go(AppRoutes.diet),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ExerciseSummaryCard(
                        onOpen: () => context.go(AppRoutes.exercise),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: _NutritionSection(),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: _RecommendedMeals(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: _ScheduleCard(),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── header ──

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    this.onNotificationTap,
    this.onCalendarTap,
    this.onProfileTap,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onCalendarTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Row(
        children: <Widget>[
          const HeartLogo(),
          const SizedBox(width: 8),
          const Text(
            'On-Care',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: FigmaColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          _RoundIconButton(
            onTap: onNotificationTap,
            showDot: true,
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 18,
              color: FigmaColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          _RoundIconButton(
            onTap: onCalendarTap,
            child: const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: FigmaColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          _ProfileAvatar(onTap: onProfileTap),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.child,
    this.onTap,
    this.showDot = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Material(
            color: FigmaColors.softBlue,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Center(child: child),
            ),
          ),
          if (showDot)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: FigmaColors.redDot,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFFE8F6FC), Color(0xFFB8E4F5)],
                ),
                border: Border.all(color: FigmaColors.primary, width: 2.2),
              ),
              child: const Icon(
                Icons.person,
                size: 22,
                color: FigmaColors.primary,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: FigmaColors.onlineGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── coaching banner ──

class _CoachingBanner extends StatelessWidget {
  const _CoachingBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[FigmaColors.bannerStart, FigmaColors.bannerEnd],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FigmaColors.primaryA(0.18)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: FigmaColors.primaryA(0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: <Widget>[
                    const OniAvatar(size: 46),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AiPill('✦ AI 코칭'),
                          SizedBox(height: 3),
                          Text(
                            '오늘의 맞춤 조언',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: FigmaColors.ink,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '저녁은 나트륨을 줄이고\n20분 정도 걸어보세요',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                              color: FigmaColors.textBody,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: FigmaColors.primaryA(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: FigmaColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: FigmaColors.primaryA(0.10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: const Row(
                  children: <Widget>[
                    OniAvatar(size: 14, shadow: false),
                    SizedBox(width: 8),
                    Text(
                      'AI가 오늘 3개의 맞춤 조언을 준비했어요',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: FigmaColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────── summary cards ──

/// Shared white card chrome for the two Home summary cards, including the
/// gradient top stripe.
class _StripeCard extends StatelessWidget {
  const _StripeCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FigmaColors.primaryA(0.08)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: FigmaColors.primaryA(0.10),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[FigmaColors.primary, FigmaColors.primaryStripe],
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: FigmaColors.iconTint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: FigmaColors.primary),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: FigmaColors.ink,
          ),
        ),
      ],
    );
  }
}

/// A soft "· item" recommendation box used at the bottom of both summary cards.
class _RecBox extends StatelessWidget {
  const _RecBox({required this.badge, required this.items});
  final String badge;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: FigmaColors.softBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AiPill(badge, background: FigmaColors.primaryA(0.10)),
          const SizedBox(height: 5),
          for (final String it in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '· $it',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: FigmaColors.ink,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FigmaColors.iconTint,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: FigmaColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DietSummaryCard extends StatelessWidget {
  const _DietSummaryCard({required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return _StripeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _CardTitle(icon: Icons.restaurant_rounded, label: '식단'),
          const SizedBox(height: 8),
          _MiniAlert(
            bg: FigmaColors.orangeA(0.09),
            icon: '⚠️',
            text: '나트륨 초과 감지됨',
            color: FigmaColors.orangeText,
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    CustomPaint(
                      size: const Size(44, 44),
                      painter: _RingPainter(
                        pct: 0.79,
                        track: const Color(0xFFE8F5FB),
                        arc: FigmaColors.primary,
                        stroke: 4,
                      ),
                    ),
                    const Text(
                      '79%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: FigmaColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '1,420',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: FigmaColors.ink,
                      letterSpacing: -0.5,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '/ 1,800 kcal',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: FigmaColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _MacroBar(label: '탄수화물', pct: 0.68, color: FigmaColors.primary),
          const SizedBox(height: 6),
          const _MacroBar(label: '단백질', pct: 0.52, color: FigmaColors.green),
          const SizedBox(height: 6),
          const _MacroBar(label: '지방', pct: 0.45, color: FigmaColors.orange),
          const SizedBox(height: 12),
          const _RecBox(
            badge: '✦ AI 추천 저녁 식단',
            items: <String>['닭가슴살 샐러드', '현미밥 반 공기'],
          ),
          const SizedBox(height: 10),
          _CardButton(label: '식단 기록 →', onTap: onOpen),
        ],
      ),
    );
  }
}

class _ExerciseSummaryCard extends StatelessWidget {
  const _ExerciseSummaryCard({required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return _StripeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _CardTitle(icon: Icons.fitness_center_rounded, label: '운동'),
          const SizedBox(height: 8),
          _MiniAlert(
            bg: FigmaColors.greenA(0.09),
            icon: '✅',
            text: 'AI 추천 루틴 1/3 완료',
            color: FigmaColors.greenText,
          ),
          const SizedBox(height: 12),
          const Text(
            '320',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: FigmaColors.ink,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'kcal 소모 · 목표 500',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: FigmaColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          const _Fill(
            pct: 0.64,
            height: 6,
            gradient: LinearGradient(
              colors: <Color>[FigmaColors.primary, FigmaColors.primaryStripe],
            ),
          ),
          const SizedBox(height: 12),
          const _ChecklistRow(name: '빠르게 걷기', minutes: 30, done: true),
          const SizedBox(height: 4),
          const _ChecklistRow(name: '하체 스트레칭', minutes: 10, done: false),
          const SizedBox(height: 12),
          const _RecBox(
            badge: '✦ AI 추천 남은 루틴',
            items: <String>['하체 스트레칭 10분', '저강도 근력 15분'],
          ),
          const SizedBox(height: 10),
          _CardButton(label: '운동 기록 →', onTap: onOpen),
        ],
      ),
    );
  }
}

class _MiniAlert extends StatelessWidget {
  const _MiniAlert({
    required this.bg,
    required this.icon,
    required this.text,
    required this.color,
  });
  final Color bg;
  final String icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Text(icon, style: const TextStyle(fontSize: 9)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.pct,
    required this.color,
  });
  final String label;
  final double pct;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 44,
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: FigmaColors.textMuted,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _Fill(pct: pct, color: color),
        ),
      ],
    );
  }
}

/// An intrinsic-safe horizontal progress fill. Uses a flex split rather than
/// [FractionallySizedBox] so it survives [IntrinsicHeight]'s intrinsic-sizing
/// pass (FractionallySizedBox throws during that pass).
class _Fill extends StatelessWidget {
  const _Fill({required this.pct, this.color, this.gradient, this.height = 4});

  final double pct;
  final Color? color;
  final Gradient? gradient;
  final double height;

  @override
  Widget build(BuildContext context) {
    final int filled = (pct.clamp(0.0, 1.0) * 1000).round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: height,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: filled,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, gradient: gradient),
              ),
            ),
            Expanded(
              flex: 1000 - filled,
              child: const ColoredBox(color: FigmaColors.track),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.name,
    required this.minutes,
    required this.done,
  });
  final String name;
  final int minutes;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: done ? FigmaColors.primary : FigmaColors.track,
            borderRadius: BorderRadius.circular(4),
          ),
          child: done
              ? const Icon(Icons.check, size: 9, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: done ? FigmaColors.textMuted : FigmaColors.ink,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        Text(
          '$minutes분',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: FigmaColors.textFaint,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.pct,
    required this.track,
    required this.arc,
    required this.stroke,
  });
  final double pct;
  final Color track;
  final Color arc;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (math.min(size.width, size.height) - stroke) / 2;
    final Paint trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, trackPaint);
    final Paint arcPaint = Paint()
      ..color = arc
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * pct.clamp(0.0, 1.0),
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.pct != pct || old.arc != arc || old.track != track;
}

/// The overall "오늘 종합" summary donut shown to the left of the nutrition
/// delta tiles — today's total intake as a share of the daily target.
class _SummaryDonut extends StatelessWidget {
  const _SummaryDonut();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: FigmaColors.primaryA(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FigmaColors.primaryA(0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                CustomPaint(
                  size: const Size(40, 40),
                  painter: _RingPainter(
                    pct: 0.79,
                    track: const Color(0xFFE8F5FB),
                    arc: FigmaColors.primary,
                    stroke: 4,
                  ),
                ),
                const Text(
                  '79%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: FigmaColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '오늘 종합',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: FigmaColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '목표 대비',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: FigmaColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────── nutrition section ──

class _NutData {
  const _NutData({
    required this.cur,
    required this.prev,
    required this.unit,
    required this.goal,
    required this.color,
    required this.warn,
  });
  final List<double> cur;
  final List<double> prev;
  final String unit;
  final double goal;
  final Color color;
  final bool warn;
}

const Map<String, _NutData> _nutrition = <String, _NutData>{
  '칼로리': _NutData(
    cur: <double>[1650, 2100, 1480, 1720, 1390, 1860, 1420],
    prev: <double>[1820, 1950, 1700, 1800, 1650, 2050, 1610],
    unit: 'kcal',
    goal: 1800,
    color: FigmaColors.primary,
    warn: false,
  ),
  '나트륨': _NutData(
    cur: <double>[2050, 2280, 2120, 2400, 2200, 2550, 2100],
    prev: <double>[1900, 2000, 1950, 2100, 2050, 2200, 2180],
    unit: 'mg',
    goal: 2000,
    color: FigmaColors.orange,
    warn: true,
  ),
  '당류': _NutData(
    cur: <double>[28, 42, 22, 31, 18, 38, 45],
    prev: <double>[35, 38, 30, 40, 28, 44, 32],
    unit: 'g',
    goal: 50,
    color: FigmaColors.sugarPurple,
    warn: false,
  ),
};

const List<String> _weekDays = <String>['월', '화', '수', '목', '금', '토', '일'];

class _NutritionSection extends StatefulWidget {
  const _NutritionSection();

  @override
  State<_NutritionSection> createState() => _NutritionSectionState();
}

class _NutritionSectionState extends State<_NutritionSection> {
  String _tab = '칼로리';

  @override
  Widget build(BuildContext context) {
    final _NutData cfg = _nutrition[_tab]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text(
                        '영양 현황',
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
                  const SizedBox(height: 2),
                  const Text(
                    '주간 누적 추이 · 지난주 대비',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: FigmaColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Row(
              children: <Widget>[
                Text(
                  '자세히',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: FigmaColors.primary,
                  ),
                ),
                Icon(Icons.chevron_right, size: 14, color: FigmaColors.primary),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        const IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: _SummaryDonut()),
              SizedBox(width: 6),
              Expanded(
                child: _DeltaTile(
                  label: '칼로리',
                  delta: '-8%',
                  up: false,
                  good: true,
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _DeltaTile(
                  label: '나트륨',
                  delta: '+9%',
                  up: true,
                  good: false,
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _DeltaTile(
                  label: '당류',
                  delta: '-5%',
                  up: false,
                  good: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cfg.warn
                  ? FigmaColors.orangeA(0.20)
                  : FigmaColors.primaryA(0.08),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: FigmaColors.primaryA(0.06),
                blurRadius: 14,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  for (final String t in _nutrition.keys) ...<Widget>[
                    _NutTab(
                      label: t,
                      active: _tab == t,
                      warn: _nutrition[t]!.warn,
                      activeColor: _nutrition[t]!.color,
                      onTap: () => setState(() => _tab = t),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (cfg.warn) ...<Widget>[
                _SodiumInsight(),
                const SizedBox(height: 16),
              ],
              _ChartLegend(color: cfg.color),
              const SizedBox(height: 8),
              SizedBox(
                height: 62,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _NutritionChartPainter(cfg),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  for (int i = 0; i < _weekDays.length; i++)
                    Text(
                      _weekDays[i],
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: i == 6 ? cfg.color : FigmaColors.textFaint,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _StatTile(
                      label: '이번주 평균',
                      value: _avg(cfg.cur),
                      unit: cfg.unit,
                      highlight: cfg.warn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatTile(
                      label: '지난주 평균',
                      value: _avg(cfg.prev),
                      unit: cfg.unit,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatTile(
                      label: '목표',
                      value: cfg.goal,
                      unit: cfg.unit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _avg(List<double> xs) =>
      (xs.reduce((double a, double b) => a + b) / xs.length).roundToDouble();
}

class _NutTab extends StatelessWidget {
  const _NutTab({
    required this.label,
    required this.active,
    required this.warn,
    required this.activeColor,
    required this.onTap,
  });
  final String label;
  final bool active;
  final bool warn;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? activeColor : FigmaColors.track,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : FigmaColors.textMuted,
              ),
            ),
            if (warn && !active) ...<Widget>[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: FigmaColors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            if (warn && active) ...<Widget>[
              const SizedBox(width: 4),
              const Text('⚠️', style: TextStyle(fontSize: 9)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SodiumInsight extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[FigmaColors.bannerStart, FigmaColors.bannerEnd],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FigmaColors.primaryA(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AiPill('✦ AI', background: FigmaColors.primaryA(0.15)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: FigmaColors.ink,
                  height: 1.5,
                ),
                children: <InlineSpan>[
                  TextSpan(text: '나트륨 섭취가 '),
                  TextSpan(
                    text: '2주 연속 증가',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: FigmaColors.orange,
                    ),
                  ),
                  TextSpan(text: ' 추세예요. 소금 사용량을 줄이고, '),
                  TextSpan(
                    text: '고염분 식단 알림',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: FigmaColors.primary,
                    ),
                  ),
                  TextSpan(text: '을 켜볼까요?'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(width: 16, height: 2, color: color),
        const SizedBox(width: 4),
        const Text(
          '이번 주',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: FigmaColors.textMuted,
          ),
        ),
        const SizedBox(width: 12),
        const SizedBox(
          width: 16,
          child: Divider(color: Color(0xFFD0D8E4), thickness: 1, height: 2),
        ),
        const SizedBox(width: 4),
        const Text(
          '지난 주',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: FigmaColors.textMuted,
          ),
        ),
        const Spacer(),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        const Text(
          '오늘',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: FigmaColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _NutritionChartPainter extends CustomPainter {
  _NutritionChartPainter(this.cfg);
  final _NutData cfg;

  @override
  void paint(Canvas canvas, Size size) {
    final double maxVal =
        <double>[...cfg.cur, ...cfg.prev].reduce(math.max) * 1.12;
    final double w = size.width;
    final double h = size.height;
    Offset at(int i, double v) =>
        Offset((i / (cfg.cur.length - 1)) * w, h - (v / maxVal) * h);

    // Goal line.
    final double gy = h - (cfg.goal / maxVal) * h;
    _dashLine(
      canvas,
      Offset(0, gy),
      Offset(w, gy),
      cfg.warn ? FigmaColors.orangeA(0.35) : const Color(0xFFE0E8EF),
      1,
    );

    // Previous week (dashed grey).
    _dashPolyline(
      canvas,
      <Offset>[for (int i = 0; i < cfg.prev.length; i++) at(i, cfg.prev[i])],
      const Color(0xFFD0D8E4),
      1.5,
    );

    // Current week area + line.
    final List<Offset> curPts = <Offset>[
      for (int i = 0; i < cfg.cur.length; i++) at(i, cfg.cur[i]),
    ];
    final Path area = Path()..moveTo(0, h);
    for (final Offset p in curPts) {
      area.lineTo(p.dx, p.dy);
    }
    area
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(area, Paint()..color = cfg.color.withValues(alpha: 0.08));

    final Path line = Path()..moveTo(curPts.first.dx, curPts.first.dy);
    for (final Offset p in curPts.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = cfg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Today marker.
    final Offset last = curPts.last;
    canvas.drawCircle(last, 4, Paint()..color = Colors.white);
    canvas.drawCircle(
      last,
      4,
      Paint()
        ..color = cfg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(last, 1.5, Paint()..color = cfg.color);
  }

  void _dashLine(Canvas c, Offset a, Offset b, Color color, double width) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = width;
    const double dash = 3, gap = 3;
    final double total = (b - a).distance;
    final Offset dir = (b - a) / total;
    double d = 0;
    while (d < total) {
      final Offset s = a + dir * d;
      final Offset e = a + dir * math.min(d + dash, total);
      c.drawLine(s, e, p);
      d += dash + gap;
    }
  }

  void _dashPolyline(Canvas c, List<Offset> pts, Color color, double width) {
    for (int i = 0; i < pts.length - 1; i++) {
      _dashLine(c, pts[i], pts[i + 1], color, width);
    }
  }

  @override
  bool shouldRepaint(covariant _NutritionChartPainter old) => old.cfg != cfg;
}

class _DeltaTile extends StatelessWidget {
  const _DeltaTile({
    required this.label,
    required this.delta,
    required this.up,
    required this.good,
  });
  final String label;
  final String delta;
  final bool up;
  final bool good;

  @override
  Widget build(BuildContext context) {
    final Color tone = good ? FigmaColors.greenText : FigmaColors.orangeText;
    final Color chip = good ? FigmaColors.green : FigmaColors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: chip.withValues(alpha: good ? 0.08 : 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chip.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: chip.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 13,
              color: tone,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: FigmaColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            delta,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: tone,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '지난주 대비',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: FigmaColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
    this.highlight = false,
  });
  final String label;
  final double value;
  final String unit;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: highlight ? FigmaColors.orangeA(0.07) : FigmaColors.statBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
              color: FigmaColors.textMuted,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            NumberFormat('#,###').format(value),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: highlight ? FigmaColors.orangeText : FigmaColors.ink,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: FigmaColors.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────── recommended meals ──

class _RecMeal {
  const _RecMeal(
    this.emoji,
    this.name,
    this.reason,
    this.bg,
    this.tag,
    this.tagColor,
  );
  final String emoji;
  final String name;
  final String reason;
  final Color bg;
  final String tag;
  final Color tagColor;
}

const List<_RecMeal> _recMeals = <_RecMeal>[
  _RecMeal(
    '🥗',
    '닭가슴살 샐러드',
    '나트륨 조절에 좋아요',
    Color(0xFFE8F5E9),
    '저나트륨',
    FigmaColors.greenText,
  ),
  _RecMeal(
    '🍱',
    '현미 도시락',
    '혈당 안정에 도움돼요',
    Color(0xFFFFF8E1),
    '저GI',
    FigmaColors.orangeText,
  ),
  _RecMeal(
    '🐟',
    '연어 구이 + 나물',
    '오메가3 + 식이섬유',
    Color(0xFFE3F2FD),
    '고단백',
    FigmaColors.primary,
  ),
  _RecMeal(
    '🥦',
    '두부 채소 볶음',
    '칼로리 낮고 포만감↑',
    Color(0xFFF3E5F5),
    '저칼로리',
    FigmaColors.sugarPurple,
  ),
];

class _RecommendedMeals extends StatelessWidget {
  const _RecommendedMeals();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            children: <Widget>[
              const Text(
                '이번 주 AI 추천 식단',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: FigmaColors.ink,
                ),
              ),
              const SizedBox(width: 6),
              AiPill('✦ AI 분석', background: FigmaColors.primaryA(0.10)),
              const Spacer(),
              const Text(
                '전체 보기',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: FigmaColors.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 158,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _recMeals.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, int i) => _RecMealCard(meal: _recMeals[i]),
          ),
        ),
      ],
    );
  }
}

class _RecMealCard extends StatelessWidget {
  const _RecMealCard({required this.meal});
  final _RecMeal meal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0D000000)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 72,
            width: double.infinity,
            color: meal.bg,
            alignment: Alignment.center,
            child: Text(meal.emoji, style: const TextStyle(fontSize: 32)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: FigmaColors.ink,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  meal.reason,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: FigmaColors.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: meal.tagColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    meal.tag,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: meal.tagColor,
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
}

// ───────────────────────────────────────────────────────── schedule ──

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String todayLabel =
        '${now.month}월 ${now.day}일 ${_weekDays[now.weekday - 1]}요일';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '오늘의 일정',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: FigmaColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    todayLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: FigmaColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '전체 보기',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: FigmaColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FigmaColors.softBlue,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FigmaColors.primaryA(0.12)),
          ),
          child: Row(
            children: <Widget>[
              const Text(
                '19:30',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: FigmaColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 34,
                color: FigmaColors.primaryA(0.35),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '저녁 산책',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: FigmaColors.ink,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '집 주변 · 20분',
                      style: TextStyle(
                        fontSize: 12,
                        color: FigmaColors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: FigmaColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

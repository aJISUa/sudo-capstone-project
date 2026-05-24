import 'package:flutter/material.dart';

import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/radius.dart';
import 'package:oncare/design_system/tokens/spacing.dart';

/// Surface-coloured container with rounded corners and optional tap
/// behaviour. Used for dashboard cards, list items, etc.
///
/// Set [outlined] to swap the filled tonal surface for the
/// white-background + soft-gray-border treatment the design system
/// uses for primary content panels (오늘의 건강 요약, 온이의 피드백,
/// 운동 기록 / 내 헬스장 / 건강 지표 추이 / 설정 …). The default
/// (`outlined: false`) keeps the legacy tonal fill so smaller stat
/// tiles and tinted secondary surfaces are unaffected.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.onTap,
    this.outlined = false,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill =
        color ?? (outlined ? AppColors.card : scheme.surfaceContainerHigh);
    final shape = outlined
        ? const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.lg),
            side: BorderSide(color: AppColors.border),
          )
        : const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.lg),
          );
    return Material(
      color: fill,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

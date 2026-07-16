import 'package:flutter/material.dart';

import 'package:oncare_trainer/design_system/tokens/colors.dart';
import 'package:oncare_trainer/design_system/tokens/radius.dart';
import 'package:oncare_trainer/design_system/tokens/spacing.dart';

/// Temporary landing screen for the scaffold. Confirms the app boots
/// with the design tokens + theme wired up. Replaced by the auth gate
/// and the four-tab trainer shell in later issues.
class ScaffoldHomePage extends StatelessWidget {
  const ScaffoldHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.all(AppRadius.card),
                ),
                alignment: Alignment.center,
                child: const Text('🏋️', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '온케어 트레이너',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '트레이너 앱 스캐폴딩 준비 완료',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

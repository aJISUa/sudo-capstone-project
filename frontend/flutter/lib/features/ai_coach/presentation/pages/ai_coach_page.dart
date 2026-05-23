import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/errors/app_error.dart';
import 'package:oncare/design_system/atoms/app_badge.dart';
import 'package:oncare/design_system/atoms/app_card.dart';
import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/ai_coach/domain/entities/ai_coach_state.dart';
import 'package:oncare/features/ai_coach/presentation/controllers/ai_coach_controller.dart';
import 'package:oncare/gen/l10n/app_localizations.dart';
import 'package:oncare/shared/widgets/error_view.dart';

({String label, AppBadgeTone tone}) _tagDisplay(AiSuggestionTag t) =>
    switch (t) {
      AiSuggestionTag.diet => (label: '식단', tone: AppBadgeTone.warning),
      AiSuggestionTag.exercise => (label: '운동', tone: AppBadgeTone.success),
      AiSuggestionTag.sleep => (label: '수면', tone: AppBadgeTone.info),
      AiSuggestionTag.hydration => (label: '수분', tone: AppBadgeTone.info),
    };

class AICoachPage extends ConsumerWidget {
  const AICoachPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(aiCoachStateProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.pageAiCoachTitle)),
      body: async.when(
        data: (s) => _Body(state: s),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ErrorView(
          error: e is AppError ? e : UnknownError(message: e.toString()),
          onRetry: () => ref.invalidate(aiCoachStateProvider),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});
  final AiCoachState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        AppCard(
          color: AppColors.primary.withValues(alpha: 0.12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.smart_toy_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(state.greeting, style: theme.textTheme.bodyLarge),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final s in state.suggestions) ...<Widget>[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppBadge(
                      label: _tagDisplay(s.tag).label,
                      tone: _tagDisplay(s.tag).tone,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(s.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(s.body, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

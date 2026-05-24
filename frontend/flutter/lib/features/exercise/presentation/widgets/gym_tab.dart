import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/errors/app_error.dart';
import 'package:oncare/design_system/atoms/app_card.dart';
import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/radius.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/exercise/domain/entities/gym.dart';
import 'package:oncare/features/exercise/presentation/controllers/exercise_controller.dart';
import 'package:oncare/features/exercise/presentation/widgets/gym_finder_sheet.dart';
import 'package:oncare/shared/widgets/error_view.dart';

/// 헬스장 tab body — matches the prototype's `GymCard` flow:
/// a full-width 헬스장 찾기 CTA on top, then either the user's
/// registered gym (with trainer info + 헬스장 정보 / 1:1 상담) or an
/// empty state.
class GymTab extends ConsumerWidget {
  const GymTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myGymProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      children: <Widget>[
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: () => showGymFinderSheet(context),
            icon: const Icon(Icons.place_outlined, size: 18),
            label: const Text('헬스장 찾기'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(AppRadius.lg),
              ),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        async.when(
          data: (gym) => gym == null ? const _EmptyGym() : _MyGymCard(gym: gym),
          loading: () => const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (Object e, _) => ErrorView(
            error: e is AppError ? e : UnknownError(message: e.toString()),
            onRetry: () => ref.invalidate(myGymProvider),
          ),
        ),
      ],
    );
  }
}

class _EmptyGym extends StatelessWidget {
  const _EmptyGym();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      outlined: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.fitness_center,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '등록된 헬스장이 없어요',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '주변 헬스장을 찾아보세요',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyGymCard extends StatefulWidget {
  const _MyGymCard({required this.gym});
  final Gym gym;

  @override
  State<_MyGymCard> createState() => _MyGymCardState();
}

class _MyGymCardState extends State<_MyGymCard> {
  bool _chatOpen = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gym = widget.gym;
    return AppCard(
      outlined: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.all(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '내 헬스장',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            gym.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: <Widget>[
              const Icon(
                Icons.place_outlined,
                size: 14,
                color: AppColors.mutedForeground,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${gym.address} · ${gym.distanceKm.toStringAsFixed(1)}km',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          if (gym.trainerName != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.muted,
                  child: Icon(
                    Icons.person,
                    size: 18,
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        gym.trainerName!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (gym.trainerRole != null)
                        Text(
                          gym.trainerRole!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (gym.tags.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: <Widget>[for (final t in gym.tags) _TagChip(label: t)],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _PillButton(
                  label: '헬스장 정보',
                  tone: _PillTone.secondary,
                  onTap: () => _showGymInfo(context, gym),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _PillButton(
                  label: '1:1 상담',
                  icon: Icons.chat_bubble_outline,
                  tone: _PillTone.primary,
                  onTap: () => setState(() => _chatOpen = !_chatOpen),
                ),
              ),
            ],
          ),
          if (_chatOpen) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _ChatPanel(
              trainerInitial: gym.trainerName?.characters.first ?? '김',
            ),
          ],
        ],
      ),
    );
  }
}

class _ChatPanel extends StatefulWidget {
  const _ChatPanel({required this.trainerInitial});
  final String trainerInitial;

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.all(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Color(0xFF22C55E),
              ),
              const SizedBox(width: 6),
              Text(
                '건강 데이터 요약본 전송 완료',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '전송된 정보:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          Text(
            '• 최근 운동 기록 (이번 주 5회)\n• 선호 운동 유형: 유산소, 근력\n• 고혈압 위험군 프로필',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.all(AppRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    widget.trainerInitial,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '자료 잘 받았습니다. 고혈압 관리를 위한 맞춤 운동 프로그램 준비했어요!',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '메시지 입력...',
                    filled: true,
                    fillColor: AppColors.background,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: () {
                  if (_controller.text.trim().isEmpty) return;
                  _controller.clear();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('메시지를 보냈어요')));
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(AppRadius.md),
                  ),
                ),
                child: const Text('전송'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.all(AppRadius.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.accentForeground),
      ),
    );
  }
}

enum _PillTone { primary, secondary }

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.tone,
    required this.onTap,
    this.icon,
  });
  final String label;
  final _PillTone tone;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bg = tone == _PillTone.primary ? AppColors.primary : AppColors.accent;
    final fg = tone == _PillTone.primary
        ? Colors.white
        : AppColors.accentForeground;
    return Material(
      color: bg,
      borderRadius: const BorderRadius.all(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showGymInfo(BuildContext context, Gym gym) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext ctx) => _GymInfoDialog(gym: gym),
  );
}

class _GymInfoDialog extends StatelessWidget {
  const _GymInfoDialog({required this.gym});
  final Gym gym;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    gym.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '닫기',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(gym.address, style: theme.textTheme.bodySmall),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                const Icon(Icons.star, color: Color(0xFFF4A946), size: 14),
                const SizedBox(width: 4),
                Text(
                  '평점: ${gym.rating.toStringAsFixed(1)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            if (gym.weekdayHours != null ||
                gym.weekendHours != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                '운영 시간',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              if (gym.weekdayHours != null)
                Text(
                  '평일: ${gym.weekdayHours}',
                  style: theme.textTheme.bodySmall,
                ),
              if (gym.weekendHours != null)
                Text(
                  '주말: ${gym.weekendHours}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
            if (gym.phone != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                '연락처',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              Text(gym.phone!, style: theme.textTheme.bodySmall),
            ],
            if (gym.trainerName != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                '전담 트레이너',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              Text(gym.trainerName!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(AppRadius.lg),
                  ),
                ),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/radius.dart';
import 'package:oncare/design_system/tokens/spacing.dart';

// ---------------------------------------------------------------------------
// Shared scaffold
// ---------------------------------------------------------------------------

/// Wraps each settings modal in a consistent Dialog → header (title + X) →
/// scrollable body → primary footer button layout, matching the prototype.
class _SettingsDialog extends StatelessWidget {
  const _SettingsDialog({
    required this.title,
    required this.body,
    required this.footerLabel,
    this.onFooter,
  });

  final String title;
  final Widget body;
  final String footerLabel;
  final VoidCallback? onFooter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(AppRadius.card),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _RoundCloseButton(
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              body,
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadius.lg),
                    ),
                  ),
                  onPressed: onFooter ?? () => Navigator.of(context).pop(),
                  child: Text(footerLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundCloseButton extends StatelessWidget {
  const _RoundCloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.muted,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(Icons.close, size: 18, color: AppColors.mutedForeground),
        ),
      ),
    );
  }
}

/// Field-label + TextField pair used by the my-profile and
/// health-goal forms.
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputBackground,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(AppRadius.md),
              borderSide: BorderSide.none,
            ),
            suffixIcon: suffixIcon == null
                ? null
                : Icon(suffixIcon, color: AppColors.mutedForeground, size: 18),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 내 프로필 modal
// ---------------------------------------------------------------------------

Future<void> showMyProfileModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _MyProfileDialog(),
  );
}

class _MyProfileDialog extends StatefulWidget {
  const _MyProfileDialog();
  @override
  State<_MyProfileDialog> createState() => _MyProfileDialogState();
}

class _MyProfileDialogState extends State<_MyProfileDialog> {
  late final TextEditingController _name = TextEditingController(text: '김민수');
  late final TextEditingController _email = TextEditingController(
    text: 'minsu@oncare.com',
  );
  late final TextEditingController _phone = TextEditingController(
    text: '010-1234-5678',
  );
  late final TextEditingController _birth = TextEditingController(
    text: '1990. 01. 15.',
  );

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _birth.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('내 프로필이 저장되었어요')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsDialog(
      title: '내 프로필',
      footerLabel: '저장하기',
      onFooter: _save,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _LabeledField(label: '이름', controller: _name),
          const SizedBox(height: AppSpacing.md),
          _LabeledField(
            label: '이메일',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledField(
            label: '전화번호',
            controller: _phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledField(
            label: '생년월일',
            controller: _birth,
            suffixIcon: Icons.calendar_today_outlined,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 건강 목표 modal
// ---------------------------------------------------------------------------

Future<void> showHealthGoalModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _HealthGoalDialog(),
  );
}

class _HealthGoalDialog extends StatefulWidget {
  const _HealthGoalDialog();
  @override
  State<_HealthGoalDialog> createState() => _HealthGoalDialogState();
}

class _HealthGoalDialogState extends State<_HealthGoalDialog> {
  late final TextEditingController _weight = TextEditingController(text: '70');
  late final TextEditingController _bp = TextEditingController(text: '120');
  late final TextEditingController _sugar = TextEditingController(text: '100');
  late final TextEditingController _kcal = TextEditingController(text: '2000');
  late final TextEditingController _sodium = TextEditingController(
    text: '2000',
  );

  @override
  void dispose() {
    _weight.dispose();
    _bp.dispose();
    _sugar.dispose();
    _kcal.dispose();
    _sodium.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('건강 목표가 저장되었어요')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final digitsOnly = <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
    ];
    return _SettingsDialog(
      title: '건강 목표',
      footerLabel: '저장하기',
      onFooter: _save,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _LabeledField(
            label: '목표 체중 (kg)',
            controller: _weight,
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledField(
            label: '목표 혈압 (수축기 mmHg)',
            controller: _bp,
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledField(
            label: '목표 혈당 (mg/dL)',
            controller: _sugar,
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledField(
            label: '일일 칼로리 목표 (kcal)',
            controller: _kcal,
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledField(
            label: '일일 나트륨 제한 (mg)',
            controller: _sodium,
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 알림 설정 modal
// ---------------------------------------------------------------------------

Future<void> showNotificationSettingsModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _NotificationSettingsDialog(),
  );
}

class _NotificationSettingsDialog extends StatefulWidget {
  const _NotificationSettingsDialog();
  @override
  State<_NotificationSettingsDialog> createState() =>
      _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState
    extends State<_NotificationSettingsDialog> {
  bool _diet = true;
  bool _exercise = true;
  bool _vitals = true;
  bool _goal = true;
  bool _marketing = false;

  @override
  Widget build(BuildContext context) {
    return _SettingsDialog(
      title: '알림 설정',
      footerLabel: '닫기',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ToggleRow(
            label: '식단 기록 알림',
            value: _diet,
            onChanged: (v) => setState(() => _diet = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ToggleRow(
            label: '운동 기록 알림',
            value: _exercise,
            onChanged: (v) => setState(() => _exercise = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ToggleRow(
            label: '건강 데이터 입력 알림',
            value: _vitals,
            onChanged: (v) => setState(() => _vitals = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ToggleRow(
            label: '목표 달성 알림',
            value: _goal,
            onChanged: (v) => setState(() => _goal = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ToggleRow(
            label: '마케팅 알림',
            value: _marketing,
            onChanged: (v) => setState(() => _marketing = v),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.all(AppRadius.md),
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 고객 지원 modal
// ---------------------------------------------------------------------------

Future<void> showCustomerSupportModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _CustomerSupportDialog(),
  );
}

class _CustomerSupportDialog extends StatelessWidget {
  const _CustomerSupportDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SettingsDialog(
      title: '고객 지원',
      footerLabel: '닫기',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _SupportInfoCard(
            title: '고객센터 운영시간',
            lines: <String>['평일 09:00 - 18:00', '(주말 및 공휴일 제외)'],
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SupportInfoCard(
            title: '전화 상담',
            lines: <String>['1588-1234'],
            icon: Icons.call_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SupportInfoCard(
            title: '이메일 문의',
            lines: <String>['support@oncare.com'],
            icon: Icons.mail_outline,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SupportInfoCard(
            title: '카카오톡 상담',
            lines: <String>['@온케어'],
            icon: Icons.chat_bubble_outline,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '자주 묻는 질문',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _FaqRow(text: '식단 분석은 어떻게 하나요?'),
          const SizedBox(height: AppSpacing.xs),
          const _FaqRow(text: '건강 데이터를 수정하려면?'),
          const SizedBox(height: AppSpacing.xs),
          const _FaqRow(text: '포인트는 어떻게 쌓이나요?'),
        ],
      ),
    );
  }
}

class _SupportInfoCard extends StatelessWidget {
  const _SupportInfoCard({
    required this.title,
    required this.lines,
    this.icon,
  });

  final String title;
  final List<String> lines;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.all(AppRadius.md),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 2),
                for (final line in lines)
                  Text(
                    line,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: lines.length == 1
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (icon != null) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            Icon(icon, color: AppColors.mutedForeground, size: 20),
          ],
        ],
      ),
    );
  }
}

class _FaqRow extends StatelessWidget {
  const _FaqRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.all(AppRadius.md),
      ),
      child: Text('• $text', style: theme.textTheme.bodyMedium),
    );
  }
}

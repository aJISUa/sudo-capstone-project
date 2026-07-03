import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:oncare/app/router/routes.dart';
import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/radius.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/auth/presentation/controllers/session_controller.dart';

const LinearGradient _brandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: <Color>[AppColors.primary, AppColors.secondary],
);

/// 로그인 화면 — 이메일/비밀번호 로그인 + 우측 상단 "데모로 시작" 바로가기.
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _enterDemo() {
    ref.read(sessionControllerProvider.notifier).enterDemo();
    context.go(AppRoutes.dashboard);
  }

  Future<void> _login() async {
    if (_loading) return;
    final messenger = ScaffoldMessenger.of(context);
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('이메일과 비밀번호를 입력해 주세요')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(sessionControllerProvider.notifier).login(
        email: email,
        password: password,
      );
      if (!mounted) return;
      context.go(AppRoutes.dashboard);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('로그인에 실패했어요. 이메일·비밀번호를 확인해 주세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // 우측 상단 데모 바로가기
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: TextButton.icon(
                  onPressed: _enterDemo,
                  style: TextButton.styleFrom(foregroundColor: AppColors.mutedForeground),
                  icon: const Text('데모로 시작', style: TextStyle(fontSize: 13)),
                  label: const Icon(Icons.arrow_forward, size: 16),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // 브랜드 — 온케어 로고
                      Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: const BorderRadius.all(AppRadius.card),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Image.asset(
                            'assets/images/oncare-logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        '온케어',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '고혈압·당뇨 관리를 위한 AI 헬스케어',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      _Field(
                        controller: _email,
                        hint: '이메일',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _Field(
                        controller: _password,
                        hint: '비밀번호',
                        icon: Icons.lock_outline,
                        obscure: _obscure,
                        onSubmitted: (_) => _login(),
                        trailing: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                            color: AppColors.mutedForeground,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // 로그인 버튼(그라데이션)
                      _GradientButton(
                        loading: _loading,
                        label: '로그인',
                        onTap: _login,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: TextButton(
                          onPressed: _enterDemo,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: const Text('로그인 없이 데모 둘러보기'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.trailing,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: onSubmitted != null ? TextInputAction.done : TextInputAction.next,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.mutedForeground, size: 20),
        suffixIcon: trailing,
        filled: true,
        fillColor: AppColors.inputBackground,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onTap,
    required this.loading,
  });

  final String label;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: const BorderRadius.all(AppRadius.lg),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: loading ? null : _brandGradient,
            color: loading ? AppColors.muted : null,
            borderRadius: const BorderRadius.all(AppRadius.lg),
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

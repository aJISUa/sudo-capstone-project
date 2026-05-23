import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/design_system/atoms/app_button.dart';
import 'package:oncare/design_system/atoms/app_card.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/auth/domain/entities/auth_state.dart';
import 'package:oncare/features/auth/presentation/controllers/auth_controller.dart';
import 'package:oncare/gen/l10n/app_localizations.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.pageSignInTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: async.when(
            data: (state) => state.isSignedIn
                ? _SignedIn(state: state, onSignOut: controller.signOut)
                : _SignInForm(onSignIn: controller.signIn),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object e, StackTrace _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('로그인에 실패했습니다', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(e.toString()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInForm extends StatelessWidget {
  const _SignInForm({required this.onSignIn});
  final Future<void> Function(AuthProvider) onSignIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Oncare에 오신 것을 환영합니다',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '소셜 로그인은 실제 SDK 키 통합 전까지 mock 응답으로 동작합니다.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Continue with Apple',
          icon: Icons.apple,
          fullWidth: true,
          onPressed: () => onSignIn(AuthProvider.apple),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata,
          fullWidth: true,
          variant: AppButtonVariant.secondary,
          onPressed: () => onSignIn(AuthProvider.google),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Continue with Kakao',
          icon: Icons.chat_bubble_outline,
          fullWidth: true,
          variant: AppButtonVariant.secondary,
          onPressed: () => onSignIn(AuthProvider.kakao),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Continue with Naver',
          icon: Icons.eco_outlined,
          fullWidth: true,
          variant: AppButtonVariant.secondary,
          onPressed: () => onSignIn(AuthProvider.naver),
        ),
      ],
    );
  }
}

class _SignedIn extends StatelessWidget {
  const _SignedIn({required this.state, required this.onSignOut});
  final AuthState state;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final user = state.user!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('로그인됨', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('${user.name} (${user.provider.name})'),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Sign out',
            variant: AppButtonVariant.ghost,
            onPressed: onSignOut,
          ),
        ],
      ),
    );
  }
}

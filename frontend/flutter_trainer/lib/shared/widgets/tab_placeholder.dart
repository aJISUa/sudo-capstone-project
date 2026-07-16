import 'package:flutter/material.dart';

import 'package:oncare_trainer/design_system/tokens/colors.dart';
import 'package:oncare_trainer/design_system/tokens/spacing.dart';

/// Temporary content for a tab whose real screen ships in a later issue.
/// Keeps the app shell fully navigable while each tab is built out.
class TabPlaceholder extends StatelessWidget {
  /// Creates a placeholder for the tab named [title].
  const TabPlaceholder({super.key, required this.title, required this.emoji});

  /// Tab title shown in the header.
  final String title;

  /// Emoji shown above the "coming soon" note.
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.md),
            Text(
              '$title 화면은 곧 준비됩니다',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

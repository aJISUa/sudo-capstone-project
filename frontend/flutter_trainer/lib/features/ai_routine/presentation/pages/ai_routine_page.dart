import 'package:flutter/material.dart';

import 'package:oncare_trainer/shared/widgets/tab_placeholder.dart';

/// AI 루틴 tab. Real routine-generation screen ships in its own issue; a
/// placeholder keeps the shell navigable for now.
class AiRoutinePage extends StatelessWidget {
  /// Creates the AI routine tab.
  const AiRoutinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(title: 'AI 루틴', emoji: '✦');
  }
}

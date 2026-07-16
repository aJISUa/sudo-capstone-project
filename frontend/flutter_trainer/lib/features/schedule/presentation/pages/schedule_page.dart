import 'package:flutter/material.dart';

import 'package:oncare_trainer/shared/widgets/tab_placeholder.dart';

/// 스케줄 tab. Real PT timeline ships in its own issue; a placeholder
/// keeps the shell navigable for now.
class SchedulePage extends StatelessWidget {
  /// Creates the schedule tab.
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(title: '스케줄', emoji: '📅');
  }
}

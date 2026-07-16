import 'package:flutter/material.dart';

import 'package:oncare_trainer/shared/widgets/tab_placeholder.dart';

/// MY tab. Real trainer profile screen ships in its own issue; a
/// placeholder keeps the shell navigable for now.
class MyPage extends StatelessWidget {
  /// Creates the MY tab.
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(title: 'MY', emoji: '🧑‍🏫');
  }
}

import 'package:flutter/material.dart';

import 'package:oncare_trainer/shared/widgets/tab_placeholder.dart';

/// 고객 관리 tab. Real client list ships in its own issue; a placeholder
/// keeps the shell navigable for now.
class ClientsPage extends StatelessWidget {
  /// Creates the clients tab.
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(title: '고객 관리', emoji: '👥');
  }
}

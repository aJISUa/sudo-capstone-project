import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:oncare/app/router/routes.dart';
import 'package:oncare/core/config/app_config.dart';
import 'package:oncare/gen/l10n/app_localizations.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.pageDashboardTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l.pageNotificationTitle,
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notification),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(l.placeholderDashboard, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.smart_toy_outlined),
              label: Text(l.actionOpenAiCoach),
              onPressed: () => context.push(AppRoutes.aiCoach),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.place_outlined),
              label: Text(l.actionFindPlace),
              onPressed: () => context.push(AppRoutes.place),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.login),
              label: Text(l.actionSignInPlaceholder),
              onPressed: () => context.push(AppRoutes.signIn),
            ),
            if (!config.isProd) ...<Widget>[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.palette_outlined),
                label: const Text('UI Catalog (dev)'),
                onPressed: () => context.push(AppRoutes.uiCatalog),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:oncare_trainer/design_system/tokens/colors.dart';
import 'package:oncare_trainer/design_system/tokens/radius.dart';
import 'package:oncare_trainer/design_system/tokens/spacing.dart';
import 'package:oncare_trainer/features/clients/data/repositories/client_repository.dart';
import 'package:oncare_trainer/app/router/routes.dart';
import 'package:oncare_trainer/features/clients/domain/entities/trainer_client.dart';
import 'package:oncare_trainer/features/clients/presentation/widgets/chat_view.dart';
import 'package:oncare_trainer/features/clients/presentation/widgets/client_avatar.dart';
import 'package:oncare_trainer/features/clients/presentation/widgets/diet_view.dart';

/// Client detail screen — header + 채팅/식단/운동기록 sub-tabs. This issue
/// completes the 채팅 tab; 식단 and 운동기록 ship in their own issues.
class ClientDetailPage extends ConsumerStatefulWidget {
  /// Creates the detail screen for the client with [clientId].
  const ClientDetailPage({super.key, required this.clientId});

  /// Id of the client being viewed (from the route path).
  final String clientId;

  @override
  ConsumerState<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends ConsumerState<ClientDetailPage> {
  int _tab = 0; // 0 채팅 · 1 식단 · 2 운동기록

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientsProvider).valueOrNull ?? const [];
    final match = clients.where((c) => c.id == widget.clientId);
    final client = match.isNotEmpty ? match.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _Header(client: client),
            _SubTabs(
              current: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            Expanded(child: _body(client)),
          ],
        ),
      ),
    );
  }

  Widget _body(TrainerClient? client) {
    switch (_tab) {
      case 0:
        return ChatView(
          clientId: widget.clientId,
          clientAvatar: client?.avatar ?? '',
          clientName: client?.name ?? '고객',
        );
      case 1:
        return client == null
            ? const Center(child: CircularProgressIndicator())
            : DietView(client: client);
      default:
        return const _ComingSoon(label: '운동기록');
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.client});

  final TrainerClient? client;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.borderStrong)),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: AppColors.accent,
            // Fall back to the 고객 tab when there's nothing to pop (e.g.
            // a web deep-link / refresh landed straight on the detail).
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRoutes.clients),
          ),
          ClientAvatar(label: client?.avatar ?? '', size: 36),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  client?.name ?? '고객',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
                if (client != null)
                  Text(
                    client!.goal,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.subtleForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (client?.active ?? false)
                  ? AppColors.success
                  : AppColors.disabledForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubTabs extends StatelessWidget {
  const _SubTabs({required this.current, required this.onChanged});

  final int current;
  final ValueChanged<int> onChanged;

  static const List<String> _labels = <String>['채팅', '식단', '운동기록'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.card,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          for (var i = 0; i < _labels.length; i++) ...<Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: Container(
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: current == i
                        ? AppColors.accent
                        : AppColors.inputBackground,
                    borderRadius: const BorderRadius.all(AppRadius.md),
                  ),
                  child: Text(
                    _labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: current == i
                          ? AppColors.accentForeground
                          : AppColors.subtleForeground,
                    ),
                  ),
                ),
              ),
            ),
            if (i < _labels.length - 1) const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label 화면은 곧 준비됩니다',
        style: const TextStyle(color: AppColors.mutedForeground),
      ),
    );
  }
}

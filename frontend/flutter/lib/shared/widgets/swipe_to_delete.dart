import 'package:flutter/material.dart';

import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/radius.dart';
import 'package:oncare/design_system/tokens/spacing.dart';

/// Wraps [child] with swipe-to-delete (end→start) behind a confirm dialog.
///
/// [onDelete] performs the actual removal (repo call + provider
/// invalidation). `confirmDismiss` always returns false: the deletion is
/// reflected by re-rendering the list from its now-invalidated source, so
/// the Dismissible never leaves the tree half-removed.
class SwipeToDelete extends StatelessWidget {
  const SwipeToDelete({
    super.key,
    required this.dismissKey,
    required this.onDelete,
    required this.child,
    this.title = '삭제',
    this.message = '이 기록을 삭제할까요?',
  });

  final Key dismissKey;
  final Future<void> Function() onDelete;
  final Widget child;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: dismissKey,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.destructive,
          borderRadius: BorderRadius.all(AppRadius.card),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.destructive,
                ),
                child: const Text('삭제'),
              ),
            ],
          ),
        );
        if (ok != true) return false;
        await onDelete();
        return false; // the list re-renders from its invalidated source
      },
      child: child,
    );
  }
}

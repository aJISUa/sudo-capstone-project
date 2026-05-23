import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/features/notification/presentation/controllers/notification_controller.dart';

void main() {
  test('seed state has unread items', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(notificationControllerProvider);
    expect(state.items, isNotEmpty);
    expect(state.unreadCount, greaterThan(0));
  });

  test('markRead toggles a single item', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(notificationControllerProvider.notifier);
    final firstId = container
        .read(notificationControllerProvider)
        .items
        .first
        .id;

    notifier.markRead(firstId);

    final updated = container
        .read(notificationControllerProvider)
        .items
        .firstWhere((i) => i.id == firstId);
    expect(updated.read, isTrue);
  });

  test('markAllRead drops unread count to zero', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(notificationControllerProvider.notifier).markAllRead();
    expect(container.read(notificationControllerProvider).unreadCount, 0);
  });

  test('simulatePush prepends an unread item', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final before = container.read(notificationControllerProvider);
    container.read(notificationControllerProvider.notifier).simulatePush();
    final after = container.read(notificationControllerProvider);
    expect(after.items.length, before.items.length + 1);
    expect(after.items.first.read, isFalse);
    expect(after.items.first.id.startsWith('sim-'), isTrue);
  });
}

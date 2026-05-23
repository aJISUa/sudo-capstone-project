import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/features/notification/domain/entities/alert_item.dart';

class NotificationController extends StateNotifier<NotificationState> {
  NotificationController() : super(_seed());

  static NotificationState _seed() {
    return const NotificationState(
      items: <AlertItem>[
        AlertItem(
          id: 'a1',
          title: '식단 입력 알림',
          body: '오늘 점심 입력이 비어있어요.',
          timeAgo: '10분 전',
          category: AlertCategory.reminder,
        ),
        AlertItem(
          id: 'a2',
          title: '운동 목표 달성',
          body: '주간 운동 240분 달성!',
          timeAgo: '1시간 전',
          category: AlertCategory.achievement,
        ),
        AlertItem(
          id: 'a3',
          title: '체중 측정 권장',
          body: '오늘 체중을 기록해 보세요.',
          timeAgo: '3시간 전',
          category: AlertCategory.healthCheck,
          read: true,
        ),
        AlertItem(
          id: 'a4',
          title: '서비스 점검 안내',
          body: '내일 02:00~03:00 점검 예정입니다.',
          timeAgo: '어제',
          category: AlertCategory.system,
          read: true,
        ),
      ],
    );
  }

  void markRead(String id) {
    state = NotificationState(
      items: state.items
          .map((AlertItem i) => i.id == id ? i.copyWith(read: true) : i)
          .toList(),
    );
  }

  void markAllRead() {
    state = NotificationState(
      items: state.items.map((AlertItem i) => i.copyWith(read: true)).toList(),
    );
  }

  /// Q9: in-app panel + simulated push. Inserts a new unread item
  /// at the top, as if a real FCM notification had landed.
  void simulatePush() {
    final id = 'sim-${DateTime.now().millisecondsSinceEpoch}';
    final injected = AlertItem(
      id: id,
      title: '시뮬레이션 알림',
      body: '지금 막 가상 푸시가 도착했어요.',
      timeAgo: '방금',
      category: AlertCategory.reminder,
    );
    state = NotificationState(items: <AlertItem>[injected, ...state.items]);
  }
}

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>(
      (ref) => NotificationController(),
      name: 'notifications',
    );

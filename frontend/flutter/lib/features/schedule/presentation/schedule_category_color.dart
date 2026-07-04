import 'package:flutter/material.dart';

import 'package:oncare/features/schedule/domain/entities/schedule_event.dart';

/// Single source of truth: schedule category → calendar color. Every event
/// of the same category renders in the same color, regardless of whatever
/// `color_hex` the row happens to carry.
Color scheduleCategoryColor(ScheduleCategory c) => switch (c) {
  ScheduleCategory.hospital => const Color(0xFFDBEAFE), // blue
  ScheduleCategory.exercise => const Color(0xFFDCFCE7), // green
  ScheduleCategory.meal => const Color(0xFFFFEDD5), // orange
  ScheduleCategory.medication => const Color(0xFFEDE9FE), // purple
  ScheduleCategory.other => const Color(0xFFE0F2F7), // accent
};

String scheduleCategoryLabel(ScheduleCategory c) => switch (c) {
  ScheduleCategory.hospital => '병원',
  ScheduleCategory.exercise => '운동',
  ScheduleCategory.meal => '식사',
  ScheduleCategory.medication => '약',
  ScheduleCategory.other => '기타',
};

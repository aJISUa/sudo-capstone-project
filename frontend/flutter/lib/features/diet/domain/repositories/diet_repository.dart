import 'dart:typed_data';

import 'package:oncare/features/diet/domain/entities/diet_analysis.dart';
import 'package:oncare/features/diet/domain/entities/diet_day.dart';

abstract class DietRepository {
  Future<DietDay> fetchToday();

  /// Upload a food photo for AI analysis (POST /diet/analyze). The server
  /// recognizes the foods, maps nutrition from the public DB, persists a
  /// diet entry, and returns the analysis.
  Future<DietAnalysisResult> analyze({
    required Uint8List imageBytes,
    required String filename,
    required String mealType,
  });

  /// DELETE /diet/entries/{id} — remove a diet entry.
  Future<void> deleteEntry(String id);

  /// PUT /diet/entries/{id} — edit an entry's meal type / time. Foods and
  /// nutrition come from analysis and are not edited here.
  Future<DietEntry> updateEntry({
    required String id,
    String? mealType,
    String? timeLabel,
  });
}

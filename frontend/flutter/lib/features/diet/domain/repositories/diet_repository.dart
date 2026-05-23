import 'package:oncare/features/diet/domain/entities/diet_day.dart';

abstract class DietRepository {
  Future<DietDay> fetchToday();
}

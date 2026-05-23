enum MealType { breakfast, lunch, dinner, snack }

class FoodItem {
  const FoodItem({required this.name, required this.calories});
  final String name;
  final int calories;
}

class DietEntry {
  const DietEntry({
    required this.mealType,
    required this.timeLabel,
    required this.foods,
    required this.totalCalories,
  });

  final MealType mealType;
  final String timeLabel;
  final List<FoodItem> foods;
  final int totalCalories;
}

class DietMacros {
  const DietMacros({
    required this.carbsPct,
    required this.proteinPct,
    required this.fatPct,
  });

  final int carbsPct;
  final int proteinPct;
  final int fatPct;
}

class DietDay {
  const DietDay({
    required this.entries,
    required this.totalCalories,
    required this.macros,
  });

  final List<DietEntry> entries;
  final int totalCalories;
  final DietMacros macros;
}

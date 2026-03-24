class FoodAnalysisResult {
  String name;
  double estimatedWeightGrams;
  double totalCalories;
  
  // Macronutrients in percentage (0-100) or grams, here we use percentage of total calories for pie chart
  double carbsPercentage;
  double proteinPercentage;
  double fatPercentage;

  FoodAnalysisResult({
    required this.name,
    required this.estimatedWeightGrams,
    required this.totalCalories,
    required this.carbsPercentage,
    required this.proteinPercentage,
    required this.fatPercentage,
  });

  /// Recalculate calories when user manually changes the weight
  void updateWeight(double newWeight) {
    if (estimatedWeightGrams > 0) {
      double ratio = newWeight / estimatedWeightGrams;
      totalCalories = totalCalories * ratio;
      estimatedWeightGrams = newWeight;
    }
  }
}

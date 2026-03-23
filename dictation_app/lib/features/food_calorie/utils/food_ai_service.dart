import 'dart:math';
import 'package:image_picker/image_picker.dart';
import '../models/food_analysis_result.dart';

class FoodAIService {
  /// Simulates uploading an image to a Vision LLM and receiving food analysis
  Future<FoodAnalysisResult> analyzeFoodImage(XFile image, bool isZh) async {
    // Simulate network and AI processing delay
    await Future.delayed(const Duration(seconds: 3));

    // Mock different food responses randomly
    final mockResults = [
      FoodAnalysisResult(
        name: isZh ? '香煎鸡胸肉配西兰花' : 'Grilled Chicken Breast with Broccoli',
        estimatedWeightGrams: 250,
        totalCalories: 320,
        carbsPercentage: 15,
        proteinPercentage: 65,
        fatPercentage: 20,
      ),
      FoodAnalysisResult(
        name: isZh ? '经典牛肉汉堡' : 'Classic Beef Burger',
        estimatedWeightGrams: 300,
        totalCalories: 580,
        carbsPercentage: 45,
        proteinPercentage: 25,
        fatPercentage: 30,
      ),
      FoodAnalysisResult(
        name: isZh ? '牛油果轻食沙拉' : 'Avocado Light Salad',
        estimatedWeightGrams: 200,
        totalCalories: 280,
        carbsPercentage: 20,
        proteinPercentage: 10,
        fatPercentage: 70,
      ),
      FoodAnalysisResult(
        name: isZh ? '红烧肉配米饭' : 'Braised Pork with Rice',
        estimatedWeightGrams: 400,
        totalCalories: 850,
        carbsPercentage: 50,
        proteinPercentage: 15,
        fatPercentage: 35,
      ),
    ];

    return mockResults[Random().nextInt(mockResults.length)];
  }
}

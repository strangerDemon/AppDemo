class GradingService {
  
  /// Compares the expected words with the OCR-recognized handwritten words.
  /// Returns a map with the original word as key and boolean (true if correct) as value.
  Map<String, bool> gradeDictation({
    required List<String> expectedWords,
    required List<String> handwrittenWords,
  }) {
    Map<String, bool> results = {};
    
    // Simple grading: Check if the handwritten words contain the expected word.
    // In a real PRO feature, we'd do fuzzy matching or sequence checking.
    for (String expected in expectedWords) {
      bool isCorrect = handwrittenWords.contains(expected.toLowerCase());
      results[expected] = isCorrect;
    }
    
    return results;
  }

  /// Calculate accuracy percentage
  double calculateAccuracy(Map<String, bool> results) {
    if (results.isEmpty) return 0.0;
    
    int correctCount = results.values.where((isCorrect) => isCorrect).length;
    return (correctCount / results.length) * 100;
  }
}

class AIModelConfig {
  static const String apiKey = ''; // In a real app, this should be in .env
  static const String baseUrl = 'https://api.openai.com/v1';
  
  // Model version mappings
  static const String defaultModel = 'gpt-4o-mini';
  static const String visionModel = 'gpt-4o';
  static const String textModel = 'gpt-4o-mini';
  
  // Common system prompts
  static const String jsonFormatPrompt = 'You must respond ONLY with a valid JSON object.';
  static const String concisePrompt = 'Be concise and direct.';
}

class AIManager {
  static String getApiKey() {
    return AIModelConfig.apiKey;
  }
  
  static String getBaseUrl() {
    return AIModelConfig.baseUrl;
  }

  // Model selection strategy
  static String getModelForTask(AITaskType taskType) {
    switch (taskType) {
      case AITaskType.vision:
        return AIModelConfig.visionModel;
      case AITaskType.textProcessing:
        return AIModelConfig.textModel;
      case AITaskType.dataExtraction:
        return AIModelConfig.textModel;
      default:
        return AIModelConfig.defaultModel;
    }
  }
}

enum AITaskType {
  vision,          // Food calorie, math grading
  textProcessing,  // Noise analysis, suggestions
  dataExtraction,  // General parsing
}
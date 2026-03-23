import 'dart:math';

class NoiseAIService {
  /// Simulates sending audio features to an LLM to get noise analysis and suggestions
  Future<Map<String, String>> analyzeNoise(double currentDb, bool isZh) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock logic based on decibel levels
    if (currentDb < 40) {
      return {
        'source': isZh ? '轻微白噪音 / 呼吸声' : 'Light white noise / Breathing',
        'suggestion': isZh 
            ? '当前环境非常安静，非常适合深度学习或睡眠。' 
            : 'The environment is very quiet, perfect for deep work or sleep.',
      };
    } else if (currentDb < 60) {
      return {
        'source': isZh ? '日常交谈 / 键盘敲击' : 'Normal conversation / Typing',
        'suggestion': isZh 
            ? '环境适中，如果需要高度专注，可以考虑播放一些白噪音来掩盖背景声。' 
            : 'Moderate environment. Consider playing white noise to mask background sounds for high focus.',
      };
    } else if (currentDb < 80) {
      // Randomize between a few noisy scenarios
      final scenarios = [
        {'zh': '街道车流声 / 嘈杂人声', 'en': 'Street traffic / Loud crowd'},
        {'zh': '电视/音响播放声', 'en': 'TV / Speaker playing'},
      ];
      final scenario = scenarios[Random().nextInt(scenarios.length)];
      return {
        'source': isZh ? scenario['zh']! : scenario['en']!,
        'suggestion': isZh 
            ? '环境较为嘈杂，容易分散注意力。建议关上窗户或佩戴降噪耳机。' 
            : 'Noisy environment. It may cause distraction. Recommend closing windows or wearing ANC headphones.',
      };
    } else {
      return {
        'source': isZh ? '施工电钻 / 交通鸣笛 / 机器轰鸣' : 'Construction drill / Horn / Heavy machinery',
        'suggestion': isZh 
            ? '警告：当前噪音可能损害听力！请立即离开该区域或佩戴专业的工业级隔音耳罩。' 
            : 'WARNING: Current noise level may damage hearing! Leave the area immediately or wear professional earmuffs.',
      };
    }
  }
}

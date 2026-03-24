import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/ai/ai_manager.dart';

class NoiseAIService {
  static Future<Map<String, String>> analyzeNoise({
    required double averageDb,
    required double peakDb,
    required bool isZh,
  }) async {
    final prompt = isZh
        ? '''你是一个声学与环境专家。当前环境噪音数据：平均 ${averageDb.toStringAsFixed(1)} dB，峰值 ${peakDb.toStringAsFixed(1)} dB。
请以 JSON 格式返回分析，包含两个字段：
1. "source": 猜测最可能的噪音来源（如"安静的图书馆"、"普通办公室"、"繁忙的街道"、"施工现场"等，10个字以内）。
2. "suggestion": 给用户的降噪或健康建议（如"环境很好，继续保持"、"建议佩戴降噪耳机"、"环境嘈杂，请尽快离开以保护听力"等，30个字以内）。
只返回 JSON，不要任何其他废话。'''
        : '''You are an acoustics and environment expert. Current noise data: Average ${averageDb.toStringAsFixed(1)} dB, Peak ${peakDb.toStringAsFixed(1)} dB。
Please respond with a JSON object containing two fields:
1. "source": The most likely source of this noise (e.g., "Quiet Library", "Busy Street", max 5 words).
2. "suggestion": Advice for the user (e.g., "Wear earplugs", "Safe environment", max 15 words).
Return ONLY valid JSON.''';

    try {
      final response = await http.post(
        Uri.parse('${AIManager.getBaseUrl()}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AIManager.getApiKey()}',
        },
        body: jsonEncode({
          'model': AIManager.getModelForTask(AITaskType.textProcessing),
          'messages': [
            {'role': 'system', 'content': AIModelConfig.jsonFormatPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          final result = jsonDecode(jsonMatch.group(0)!);
          return {
            'source': result['source']?.toString() ?? (isZh ? '未知' : 'Unknown'),
            'suggestion': result['suggestion']?.toString() ?? (isZh ? '无建议' : 'No suggestion'),
          };
        }
      }
      return {
        'source': isZh ? '分析失败' : 'Analysis Failed',
        'suggestion': isZh ? '请检查网络连接' : 'Check network connection',
      };
    } catch (e) {
      return {
        'source': isZh ? '错误' : 'Error',
        'suggestion': e.toString(),
      };
    }
  }
}

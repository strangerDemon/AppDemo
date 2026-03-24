import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/ai/ai_manager.dart';

class FoodAIService {

  Future<Map<String, dynamic>> analyzeFoodImage(XFile image, bool isZh) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    
    final prompt = isZh
        ? '请分析这张图片中的食物。返回一个 JSON 对象，包含：foodName (食物名称，中文), calories (总卡路里，数字), protein (蛋白质克数，数字), carbs (碳水克数，数字), fat (脂肪克数，数字), suggestions (健康建议，中文，简短)。只返回 JSON。'
        : 'Analyze the food in this image. Return a JSON object with: foodName (in English), calories (total kcal, number), protein (grams, number), carbs (grams, number), fat (grams, number), suggestions (short healthy tip in English). Return ONLY valid JSON.';

    try {
      final response = await http.post(
        Uri.parse('${AIManager.getBaseUrl()}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AIManager.getApiKey()}',
        },
        body: jsonEncode({
          'model': AIManager.getModelForTask(AITaskType.vision),
          'messages': [
            {'role': 'system', 'content': AIModelConfig.jsonFormatPrompt},
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
                }
              ]
            }
          ],
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        
        // Extract JSON from markdown code block if present
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!);
        }
        return jsonDecode(content);
      }
      throw Exception('Failed to analyze image: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error analyzing image: $e');
    }
  }
}

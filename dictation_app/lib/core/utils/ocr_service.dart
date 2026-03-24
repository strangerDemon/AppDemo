import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/dictation_word.dart';

class OCRService {
  final ImagePicker _picker = ImagePicker();
  // Using chinese script since it supports both English and Chinese
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);

  Future<XFile?> captureImage({bool fromCamera = true}) async {
    return await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );
  }

  /// Captures an image from camera or gallery and extracts text
  Future<List<DictationWord>> extractWordsFromImage(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    List<DictationWord> words = [];
    
    // Pattern to match English word followed by optional Chinese meaning
    // Example: "apple 苹果" or "apple"
    final RegExp englishWordPattern = RegExp(r'[a-zA-Z]+');
    final RegExp chinesePattern = RegExp(r'[\u4e00-\u9fa5]+');

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String text = line.text;
        
        // Find English word
        final engMatch = englishWordPattern.firstMatch(text);
        if (engMatch != null) {
          String word = engMatch.group(0)!;
          if (word.length > 1) { // Ignore single letters
            // Try to find Chinese meaning in the same line
            String meaning = '';
            final chiMatches = chinesePattern.allMatches(text);
            if (chiMatches.isNotEmpty) {
              meaning = chiMatches.map((m) => m.group(0)).join('');
            }
            
            words.add(DictationWord(word: word.toLowerCase(), meaning: meaning));
          }
        }
      }
    }

    // Remove duplicates based on the English word
    var uniqueWords = <String, DictationWord>{};
    for (var w in words) {
      if (!uniqueWords.containsKey(w.word)) {
        uniqueWords[w.word] = w;
      } else if (uniqueWords[w.word]!.meaning.isEmpty && w.meaning.isNotEmpty) {
        // Update meaning if we found one later
        uniqueWords[w.word] = w;
      }
    }

    return uniqueWords.values.toList();
  }

  void dispose() {
    _textRecognizer.close();
  }
}

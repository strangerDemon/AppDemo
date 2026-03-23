import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();

  TTSService() {
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Dictate a list of words based on settings
  Future<void> dictateWords({
    required List<String> words,
    required int repeatCount,
    required int intervalSeconds,
    Function(int)? onWordChanged,
    Function()? onCompleted,
  }) async {
    for (int i = 0; i < words.length; i++) {
      if (onWordChanged != null) {
        onWordChanged(i);
      }

      for (int j = 0; j < repeatCount; j++) {
        await speak(words[i]);
        // Wait a bit between repeats of the same word
        if (j < repeatCount - 1) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      // Wait the specified interval before the next word
      if (i < words.length - 1) {
        await Future.delayed(Duration(seconds: intervalSeconds));
      }
    }

    if (onCompleted != null) {
      onCompleted();
    }
  }
}

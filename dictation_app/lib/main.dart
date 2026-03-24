import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/home/presentation/home_screen.dart';
import 'core/models/dictation_word.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DictationSettingsProvider()),
      ],
      child: const DictateApp(),
    ),
  );
}

class DictationSettingsProvider extends ChangeNotifier {
  List<DictationWord> recognizedWords = [];
  int wordsCount = 0; // 0 means All
  int voiceFrequency = 5;
  int repeatCount = 2;
  bool includeSentences = false;
  bool isChinese = true; // Language toggle

  void toggleLanguage() {
    isChinese = !isChinese;
    notifyListeners();
  }

  void updateRecognizedWords(List<DictationWord> words) {
    recognizedWords = words;
    notifyListeners();
  }

  void removeWord(DictationWord word) {
    recognizedWords.remove(word);
    notifyListeners();
  }

  void updateFrequency(int value) {
    if (value > 0) {
      voiceFrequency = value;
      notifyListeners();
    }
  }

  void updateRepeatCount(int value) {
    if (value > 0) {
      repeatCount = value;
      notifyListeners();
    }
  }

  void updateWordsCount(int value) {
    wordsCount = value;
    notifyListeners();
  }

  void toggleSentences(bool value) {
    includeSentences = value;
    notifyListeners();
  }
}

class DictateApp extends StatelessWidget {
  const DictateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isZh = context.watch<DictationSettingsProvider>().isChinese;
    
    return MaterialApp(
      title: 'DictateAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      ),
      locale: isZh ? const Locale('zh', 'CN') : const Locale('en', 'US'),
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}

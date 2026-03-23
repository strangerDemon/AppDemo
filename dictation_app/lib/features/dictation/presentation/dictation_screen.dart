import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/dictation_word.dart';
import '../../../core/utils/tts_service.dart';
import '../../../main.dart';
import '../../grading/presentation/grading_screen.dart';

class DictationScreen extends StatefulWidget {
  final List<DictationWord> words;

  const DictationScreen({super.key, required this.words});

  @override
  State<DictationScreen> createState() => _DictationScreenState();
}

class _DictationScreenState extends State<DictationScreen> {
  final TTSService _ttsService = TTSService();
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isFinished = false;
  
  late int _repeatCount;
  late int _intervalSeconds;
  
  int _currentRepeat = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final settings = context.read<DictationSettingsProvider>();
    _repeatCount = settings.repeatCount;
    _intervalSeconds = settings.voiceFrequency;
    
    // Start slightly after screen load
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _startDictation();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ttsService.stop();
    super.dispose();
  }

  void _startDictation() {
    if (widget.words.isEmpty) return;
    setState(() {
      _isPlaying = true;
    });
    _playCurrentWord();
  }

  void _pauseDictation() {
    setState(() {
      _isPlaying = false;
    });
    _timer?.cancel();
    _ttsService.stop();
  }

  void _resumeDictation() {
    setState(() {
      _isPlaying = true;
    });
    _playCurrentWord();
  }

  Future<void> _playCurrentWord() async {
    if (!_isPlaying) return;

    DictationWord currentWord = widget.words[_currentIndex];
    
    // Speak word
    await _ttsService.speak(currentWord.word);
    _currentRepeat++;

    // Determine next step
    if (_currentRepeat < _repeatCount) {
      // Repeat same word after 2 seconds
      _timer = Timer(const Duration(seconds: 2), () {
        if (_isPlaying) _playCurrentWord();
      });
    } else {
      // Move to next word after interval
      _currentRepeat = 0;
      if (_currentIndex < widget.words.length - 1) {
        _timer = Timer(Duration(seconds: _intervalSeconds), () {
          if (_isPlaying) {
            setState(() {
              _currentIndex++;
            });
            _playCurrentWord();
          }
        });
      } else {
        // Finished
        setState(() {
          _isPlaying = false;
          _isFinished = true;
        });
      }
    }
  }

  void _skipToNext() {
    if (_currentIndex < widget.words.length - 1) {
      _timer?.cancel();
      _ttsService.stop();
      setState(() {
        _currentIndex++;
        _currentRepeat = 0;
      });
      if (_isPlaying) _playCurrentWord();
    }
  }

  void _skipToPrevious() {
    if (_currentIndex > 0) {
      _timer?.cancel();
      _ttsService.stop();
      setState(() {
        _currentIndex--;
        _currentRepeat = 0;
      });
      if (_isPlaying) _playCurrentWord();
    }
  }

  void _finishAndGrade() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GradingScreen(expectedWords: widget.words),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isZh = context.watch<DictationSettingsProvider>().isChinese;

    if (widget.words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(isZh ? '听写' : 'Dictation')),
        body: Center(child: Text(isZh ? '没有需要听写的单词。' : 'No words to dictate.')),
      );
    }

    final progress = (_currentIndex + 1) / widget.words.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            _pauseDictation();
            Navigator.pop(context);
          },
        ),
        title: Text(
          isZh ? '听写进行中' : 'Dictation in Progress',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
              Text(
                isZh ? '第 ${_currentIndex + 1} 个，共 ${widget.words.length} 个' : 'Word ${_currentIndex + 1} of ${widget.words.length}',
                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
              ),
              
              const Spacer(),
              
              // Word Display (Hide actual word, show meaning if available)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.volume_up, size: 48, color: Color(0xFF2563EB)),
                    const SizedBox(height: 24),
                    Text(
                      _isFinished ? (isZh ? '全部完成！' : 'All Done!') : (isZh ? '听语音，写单词' : 'Listen & Write'),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (widget.words[_currentIndex].meaning.isNotEmpty && !_isFinished)
                      Text(
                        isZh ? '提示: ${widget.words[_currentIndex].meaning}' : 'Hint: ${widget.words[_currentIndex].meaning}',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              if (_isFinished)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _finishAndGrade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(isZh ? '去批改我的默写' : 'Grade My Words', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      iconSize: 40,
                      color: Colors.grey.shade600,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: _currentIndex > 0 ? _skipToPrevious : null,
                    ),
                    GestureDetector(
                      onTap: _isPlaying ? _pauseDictation : _resumeDictation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 40,
                      color: Colors.grey.shade600,
                      icon: const Icon(Icons.skip_next),
                      onPressed: _currentIndex < widget.words.length - 1 ? _skipToNext : null,
                    ),
                  ],
                ),
                
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

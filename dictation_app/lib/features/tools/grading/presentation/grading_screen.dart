import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/dictation_word.dart';
import '../../../../core/services/ocr_service.dart';
import '../../../../core/utils/grading_service.dart';
import '../../../../main.dart';
import 'dart:math';

class GradingScreen extends StatefulWidget {
  final List<DictationWord> expectedWords;

  const GradingScreen({super.key, required this.expectedWords});

  @override
  State<GradingScreen> createState() => _GradingScreenState();
}

class _GradingScreenState extends State<GradingScreen> {
  final OCRService _ocrService = OCRService();
  final GradingService _gradingService = GradingService();

  bool _isGrading = false;
  Map<String, bool>? _results;
  double _accuracy = 0.0;

  Future<void> _startGrading() async {
    setState(() {
      _isGrading = true;
    });

    try {
      // Step 1: Capture photo of handwritten words
      final image = await _ocrService.captureImage(fromCamera: true);
      if (image == null) {
        if (mounted) setState(() => _isGrading = false);
        return;
      }
      final writtenWordsData = await _ocrService.extractWordsFromImage(image);
      
      if (!mounted) return;

      if (writtenWordsData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No handwritten words found. Please try again.')),
        );
        setState(() {
          _isGrading = false;
        });
        return;
      }

      // Extract just the string words for comparison
      List<String> expectedStrings = widget.expectedWords.map((w) => w.word).toList();
      List<String> writtenStrings = writtenWordsData.map((w) => w.word).toList();

      // Step 2: Grade
      final results = _gradingService.gradeDictation(
        expectedWords: expectedStrings,
        handwrittenWords: writtenStrings,
      );

      // Step 3: Calculate Accuracy
      final accuracy = _gradingService.calculateAccuracy(results);

      setState(() {
        _results = results;
        _accuracy = accuracy;
        _isGrading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error grading: $e')),
      );
      setState(() {
        _isGrading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isZh = context.watch<DictationSettingsProvider>().isChinese;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            // Pop until home
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        title: Text(
          isZh ? '听写结果' : 'Dictation Results',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: _results == null ? _buildPreGradeView(isZh) : _buildResultsView(isZh),
    );
  }

  Widget _buildPreGradeView(bool isZh) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: const Icon(Icons.fact_check, size: 80, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 32),
            Text(
              isZh ? '准备好批改了吗？' : 'Ready to grade?',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              isZh ? '拍下你手写默写的本子，AI 会自动为你批改对错。' : 'Snap a photo of your handwritten words, and AI will automatically check them for you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isGrading ? null : _startGrading,
                icon: _isGrading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.camera_alt),
                label: Text(
                  _isGrading ? (isZh ? '正在批改...' : 'Grading...') : (isZh ? '拍照批改' : 'Take Photo to Grade'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView(bool isZh) {
    return Column(
      children: [
        // Score Header
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Text(
                isZh ? '准确率' : 'Accuracy',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${_accuracy.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _accuracy >= 80 ? Colors.green : (_accuracy >= 60 ? Colors.orange : Colors.red),
                ),
              ),
            ],
          ),
        ),
        
        // List of Words
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.expectedWords.length,
            itemBuilder: (context, index) {
              final wordData = widget.expectedWords[index];
              final isCorrect = _results![wordData.word] ?? false;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wordData.word,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: isCorrect ? TextDecoration.none : TextDecoration.lineThrough,
                              color: isCorrect ? Colors.black87 : Colors.red,
                            ),
                          ),
                          if (wordData.meaning.isNotEmpty)
                            Text(
                              wordData.meaning,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Done Button
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(isZh ? '返回首页' : 'Back to Home', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}

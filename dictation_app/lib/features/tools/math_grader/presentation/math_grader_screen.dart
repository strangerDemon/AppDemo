import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/math_problem.dart';
import '../utils/math_eval_service.dart';
import 'widgets/math_painter.dart';

class MathGraderScreen extends StatefulWidget {
  final File imageFile;
  final bool isZh;

  const MathGraderScreen({super.key, required this.imageFile, required this.isZh});

  @override
  State<MathGraderScreen> createState() => _MathGraderScreenState();
}

class _MathGraderScreenState extends State<MathGraderScreen> {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final MathEvalService _evalService = MathEvalService();
  
  bool _isProcessing = true;
  List<MathProblem> _problems = [];
  Size _imageSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _processImage() async {
    try {
      // Get image dimensions for scaling bounding boxes
      final decodedImage = await decodeImageFromList(await widget.imageFile.readAsBytes());
      _imageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());

      // Run OCR
      final inputImage = InputImage.fromFilePath(widget.imageFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      List<MathProblem> parsedProblems = [];

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final rect = line.boundingBox;
          final text = line.text;
          
          // Basic filter to see if line looks like math
          if (text.contains(RegExp(r'[0-9+\-*/=]'))) {
            final problem = MathProblem(
              rawText: text,
              boundingBox: rect,
            );
            _evalService.evaluateProblem(problem);
            
            // Only add if we successfully parsed it as an equation/arithmetic
            if (problem.isParsed) {
              parsedProblems.add(problem);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _problems = parsedProblems;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSolutionDialog(MathProblem problem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isZh ? '解析与正确答案' : 'Solution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.isZh ? '识别到的题目：' : 'Recognized:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(problem.rawText, style: const TextStyle(fontSize: 18, color: Colors.red)),
            const SizedBox(height: 16),
            Text(widget.isZh ? '解题过程：' : 'Steps:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Text(problem.solutionSteps, style: const TextStyle(fontSize: 16, fontFamily: 'monospace')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.isZh ? '关闭' : 'Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(widget.isZh ? '已加入错题本' : 'Added to Mistakes Book')),
              );
            },
            icon: const Icon(Icons.bookmark_add),
            label: Text(widget.isZh ? '加入错题本' : 'Save Mistake'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.isZh ? '口算批改结果' : 'Math Grader Result'),
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(widget.isZh ? 'AI 正在批改...' : 'AI is grading...', style: const TextStyle(color: Colors.white)),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                // Calculate scale factors to match screen size with image size
                double scaleX = constraints.maxWidth / _imageSize.width;
                double scaleY = constraints.maxHeight / _imageSize.height;
                double scale = scaleX < scaleY ? scaleX : scaleY; // Contain fit

                return Center(
                  child: GestureDetector(
                    onTapUp: (details) {
                      // Find if user clicked on a problem
                      for (var p in _problems) {
                        // Scale rect to screen coordinates
                        final screenRect = Rect.fromLTRB(
                          p.boundingBox.left * scale,
                          p.boundingBox.top * scale,
                          p.boundingBox.right * scale,
                          p.boundingBox.bottom * scale,
                        );
                        if (screenRect.contains(details.localPosition)) {
                          if (!p.isCorrect) {
                            _showSolutionDialog(p);
                          }
                          break;
                        }
                      }
                    },
                    child: CustomPaint(
                      foregroundPainter: MathPainter(
                        problems: _problems,
                        scale: scale,
                      ),
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

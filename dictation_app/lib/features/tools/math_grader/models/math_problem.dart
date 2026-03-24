import 'package:flutter/material.dart';

class MathProblem {
  final String rawText;
  final Rect boundingBox;
  
  // Parsed components
  String expression = '';
  String userProvidedAnswer = '';
  
  // Grading results
  bool isParsed = false;
  bool isCorrect = false;
  String expectedAnswer = '';
  String solutionSteps = '';

  MathProblem({
    required this.rawText,
    required this.boundingBox,
  });
}

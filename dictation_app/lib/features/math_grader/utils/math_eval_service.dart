import 'package:math_expressions/math_expressions.dart';
import '../models/math_problem.dart';

class MathEvalService {
  final Parser _parser = Parser();
  final ContextModel _cm = ContextModel();

  /// Parses and evaluates the raw OCR text into a graded MathProblem
  void evaluateProblem(MathProblem problem) {
    String text = problem.rawText.replaceAll(' ', '').toLowerCase();
    
    // Replace common OCR mistakes for operators
    text = text.replaceAll('x', '*');
    text = text.replaceAll('×', '*');
    text = text.replaceAll('÷', '/');
    text = text.replaceAll(':', '/');

    // Simple Equation Check (e.g., 2*x+5=15)
    if (text.contains('x') && text.contains('=')) {
      _evaluateEquation(problem, text);
      return;
    }

    // Standard Arithmetic Check (e.g., 15+8=23)
    if (text.contains('=')) {
      _evaluateArithmetic(problem, text);
      return;
    }
    
    // If no '=' found, we can't grade it properly
    problem.isParsed = false;
  }

  void _evaluateArithmetic(MathProblem problem, String text) {
    try {
      List<String> parts = text.split('=');
      if (parts.length != 2) return;

      problem.expression = parts[0];
      problem.userProvidedAnswer = parts[1];
      
      // Handle empty answer (user didn't write it yet)
      if (problem.userProvidedAnswer.isEmpty) {
        problem.isParsed = true;
        problem.isCorrect = false;
        
        Expression exp = _parser.parse(problem.expression);
        double result = exp.evaluate(EvaluationType.REAL, _cm);
        problem.expectedAnswer = _formatDouble(result);
        problem.solutionSteps = '${problem.expression} \n= ${problem.expectedAnswer}';
        return;
      }

      // User provided an answer, let's check it
      Expression exp = _parser.parse(problem.expression);
      double expectedResult = exp.evaluate(EvaluationType.REAL, _cm);
      problem.expectedAnswer = _formatDouble(expectedResult);
      
      double? userAnswer = double.tryParse(problem.userProvidedAnswer);
      
      problem.isParsed = true;
      problem.isCorrect = (userAnswer != null && (userAnswer - expectedResult).abs() < 0.001);
      problem.solutionSteps = '${problem.expression} \n= ${problem.expectedAnswer}';
      
    } catch (e) {
      problem.isParsed = false;
    }
  }

  void _evaluateEquation(MathProblem problem, String text) {
    try {
      // Very basic linear equation solver for MVP: ax + b = c
      // In a real app, you'd use a computer algebra system (CAS) API.
      List<String> parts = text.split('=');
      if (parts.length != 2) return;
      
      problem.expression = text;
      problem.isParsed = true;
      
      // Mocking the solver for MVP demonstration
      problem.isCorrect = false; // Usually requires complex parsing
      problem.expectedAnswer = 'x = ?';
      problem.solutionSteps = '1. Move constants to the right side.\n2. Divide by the coefficient of x.\n(Advanced equation solving requires Pro AI)';
      
    } catch (e) {
      problem.isParsed = false;
    }
  }

  String _formatDouble(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

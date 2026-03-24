import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import '../models/food_analysis_result.dart';

class FoodResultScreen extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic> initialResult; // Changed from FoodAnalysisResult to Map
  final bool isZh;

  const FoodResultScreen({
    super.key,
    required this.imageFile,
    required this.initialResult,
    required this.isZh,
  });

  @override
  State<FoodResultScreen> createState() => _FoodResultScreenState();
}

class _FoodResultScreenState extends State<FoodResultScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  late FoodAnalysisResult _currentResult;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Map AI JSON result to FoodAnalysisResult model
    final Map<String, dynamic> data = widget.initialResult;
    
    // Calculate percentages
    final double carbs = (data['carbs'] as num?)?.toDouble() ?? 0;
    final double protein = (data['protein'] as num?)?.toDouble() ?? 0;
    final double fat = (data['fat'] as num?)?.toDouble() ?? 0;
    final double totalMacros = carbs + protein + fat;
    
    _currentResult = FoodAnalysisResult(
      name: data['foodName']?.toString() ?? 'Unknown Food',
      estimatedWeightGrams: 0.0, // AI prompt didn't ask for weight
      totalCalories: (data['calories'] as num?)?.toDouble() ?? 0.0,
      carbsPercentage: totalMacros > 0 ? ((carbs / totalMacros) * 100) : 0.0,
      proteinPercentage: totalMacros > 0 ? ((protein / totalMacros) * 100) : 0.0,
      fatPercentage: totalMacros > 0 ? ((fat / totalMacros) * 100) : 0.0,
    );
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: _currentResult.name);
    final weightController = TextEditingController(text: _currentResult.estimatedWeightGrams.toInt().toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isZh ? '修正识别结果' : 'Edit Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: widget.isZh ? '食物名称' : 'Food Name'),
            ),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: widget.isZh ? '估算重量 (g)' : 'Weight (g)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(widget.isZh ? '取消' : 'Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentResult.name = nameController.text;
                _currentResult.updateWeight(double.tryParse(weightController.text) ?? _currentResult.estimatedWeightGrams);
              });
              Navigator.pop(context);
            },
            child: Text(widget.isZh ? '确定' : 'Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndShare() async {
    setState(() => _isSaving = true);
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/food_analysis.png').create();
        await imagePath.writeAsBytes(image);
        
        await Share.shareXFiles([XFile(imagePath.path)], text: widget.isZh ? '我的今日健康饮食打卡' : 'My healthy meal today');
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveToGallery() async {
    setState(() => _isSaving = true);
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/food_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(path);
        await file.writeAsBytes(image);
        
        await Gal.putImage(path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.isZh ? '已保存到相册' : 'Saved to gallery')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark theme for premium feel
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _showEditDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: _screenshotController,
              child: _buildShareCard(),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildShareCard() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          // Food Image with Gradient Overlay
          Stack(
            children: [
              Image.file(
                widget.imageFile,
                width: double.infinity,
                height: 400,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentResult.name,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${DateTime.now().year}.${DateTime.now().month}.${DateTime.now().day}',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Data Panel
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDataColumn(widget.isZh ? '热量' : 'Calories', '${_currentResult.totalCalories.toInt()} kcal', Colors.orange),
                    _buildDataColumn(widget.isZh ? '重量' : 'Weight', '${_currentResult.estimatedWeightGrams.toInt()} g', Colors.blue),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Nutrients Chart
                Row(
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 30,
                          sections: [
                            PieChartSectionData(value: _currentResult.carbsPercentage, color: Colors.green, title: '', radius: 15),
                            PieChartSectionData(value: _currentResult.proteinPercentage, color: Colors.blue, title: '', radius: 15),
                            PieChartSectionData(value: _currentResult.fatPercentage, color: Colors.orange, title: '', radius: 15),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        children: [
                          _buildNutrientRow(widget.isZh ? '碳水' : 'Carbs', _currentResult.carbsPercentage, Colors.green),
                          const SizedBox(height: 8),
                          _buildNutrientRow(widget.isZh ? '蛋白质' : 'Protein', _currentResult.proteinPercentage, Colors.blue),
                          const SizedBox(height: 8),
                          _buildNutrientRow(widget.isZh ? '脂肪' : 'Fat', _currentResult.fatPercentage, Colors.orange),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                // App Logo Placeholder
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Edu Tools · AI Food Analysis',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12, letterSpacing: 1.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildNutrientRow(String label, double percentage, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
        const Spacer(),
        Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _saveToGallery,
              icon: const Icon(Icons.download),
              label: Text(widget.isZh ? '保存相册' : 'Save'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF2563EB)),
                foregroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _captureAndShare,
              icon: const Icon(Icons.share),
              label: Text(widget.isZh ? '一键分享' : 'Share'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

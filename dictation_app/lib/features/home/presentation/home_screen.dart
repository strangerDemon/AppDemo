import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../core/utils/ocr_service.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../noise_monitor/presentation/noise_monitor_screen.dart';
import '../../food_calorie/presentation/food_result_screen.dart';
import '../../food_calorie/utils/food_ai_service.dart';
import '../../math_grader/presentation/math_grader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OCRService _ocrService = OCRService();
  final FoodAIService _foodAIService = FoodAIService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isScanning = false;
  bool _isAnalyzingFood = false;
  bool _isGradingMath = false;

  Future<void> _startMathGradeFlow(BuildContext context, {required bool fromCamera}) async {
    final XFile? image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (image == null) return;

    final isZh = context.read<DictationSettingsProvider>().isChinese;
    
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MathGraderScreen(
          imageFile: File(image.path),
          isZh: isZh,
        ),
      ),
    );
  }

  void _showMathOptions(BuildContext context) {
    final isZh = context.read<DictationSettingsProvider>().isChinese;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(isZh ? '拍作业批改' : 'Scan Homework'),
                onTap: () {
                  Navigator.pop(context);
                  _startMathGradeFlow(context, fromCamera: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(isZh ? '从相册选择' : 'Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _startMathGradeFlow(context, fromCamera: false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startFoodAnalysisFlow(BuildContext context, {required bool fromCamera}) async {
    final XFile? image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (image == null) return;

    setState(() => _isAnalyzingFood = true);
    
    try {
      final isZh = context.read<DictationSettingsProvider>().isChinese;
      final result = await _foodAIService.analyzeFoodImage(image, isZh);
      
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodResultScreen(
            imageFile: File(image.path),
            initialResult: result,
            isZh: isZh,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI Analysis Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isAnalyzingFood = false);
    }
  }

  void _showFoodOptions(BuildContext context) {
    final isZh = context.read<DictationSettingsProvider>().isChinese;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(isZh ? '拍照识别' : 'Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _startFoodAnalysisFlow(context, fromCamera: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(isZh ? '从相册选择' : 'Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _startFoodAnalysisFlow(context, fromCamera: false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startScanFlow(BuildContext context, {required bool fromCamera}) async {
    setState(() => _isScanning = true);
    try {
      final words = await _ocrService.extractWordsFromImage(fromCamera: fromCamera);
      if (!mounted) return;

      if (words.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未识别到单词，请重试 / No words found.')),
        );
        return;
      }

      // Update provider with recognized words
      context.read<DictationSettingsProvider>().updateRecognizedWords(words);

      // Navigate to dictation settings screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('识别错误: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _showScanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final settings = context.watch<DictationSettingsProvider>();
        final isZh = settings.isChinese;
        
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(isZh ? '拍照识别' : 'Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _startScanFlow(context, fromCamera: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(isZh ? '从相册选择' : 'Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _startScanFlow(context, fromCamera: false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<DictationSettingsProvider>();
    final isZh = settings.isChinese;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isZh ? '教育工具箱' : 'Edu Tools',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.blue.shade700),
            tooltip: 'Switch Language',
            onPressed: () {
              settings.toggleLanguage();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isZh ? '我的工具' : 'My Tools',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDictationToolCard(context, isZh),
            const SizedBox(height: 24),
            _buildNoiseMonitorCard(context, isZh),
            const SizedBox(height: 24),
            _buildFoodCalorieCard(context, isZh),
            const SizedBox(height: 24),
            _buildMathGraderCard(context, isZh),
            const SizedBox(height: 24),
            Text(
              isZh ? '即将推出...' : 'Coming Soon...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildComingSoonCard(
              isZh ? '口算批改' : 'Math Grader', 
              isZh ? '拍照自动批改口算题' : 'Auto grade math problems', 
              Icons.calculate
            ),
            const SizedBox(height: 12),
            _buildComingSoonCard(
              isZh ? '背课文助手' : 'Recite Helper', 
              isZh ? 'AI 辅助检查背诵情况' : 'AI assist for text recitation', 
              Icons.record_voice_over
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDictationToolCard(BuildContext context, bool isZh) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.spellcheck, color: Color(0xFF2563EB), size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF2563EB), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      isZh ? 'AI 驱动' : 'AI POWERED',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isZh ? '英语单词听写' : 'Vocabulary Dictation',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isZh ? '拍课本提取单词，AI 自动为你听写并批改。' : 'Snap a photo to extract words, AI will dictate and grade.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isScanning ? null : () => _showScanOptions(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isScanning 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(isZh ? '开始扫描' : 'Scan Now'),
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

  Widget _buildNoiseMonitorCard(BuildContext context, bool isZh) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.graphic_eq, color: Colors.green, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      isZh ? 'AI 分析' : 'AI POWERED',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isZh ? '环境噪音监测' : 'Noise Monitor',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isZh ? '实时分贝检测，AI 识别噪音源并提供降噪建议。' : 'Real-time dB meter, AI identifies sources & suggests solutions.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NoiseMonitorScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(isZh ? '进入工具' : 'Open'),
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

  Widget _buildFoodCalorieCard(BuildContext context, bool isZh) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant, color: Colors.orange, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      isZh ? '视觉大模型' : 'VISION AI',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isZh ? '饮食热量识别' : 'Food Calorie AI',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isZh ? '拍食物，秒算卡路里与营养，生成精美打卡图。' : 'Snap food, get calories & nutrients, create a beautiful card.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isAnalyzingFood ? null : () => _showFoodOptions(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isAnalyzingFood
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(isZh ? '拍照识别' : 'Scan Food'),
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

  Widget _buildMathGraderCard(BuildContext context, bool isZh) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calculate, color: Colors.purple, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.purple, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      isZh ? 'OCR 智能引擎' : 'SMART OCR',
                      style: const TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isZh ? '口算/方程式批改' : 'Math Homework Grader',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isZh ? '支持四则运算与基础方程，拍照即可原图批改对错。' : 'Supports arithmetic & basic equations. Snap to grade instantly.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isGradingMath ? null : () => _showMathOptions(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isGradingMath
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(isZh ? '拍作业' : 'Grade'),
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

  Widget _buildComingSoonCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.grey.shade500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade700)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('PRO', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

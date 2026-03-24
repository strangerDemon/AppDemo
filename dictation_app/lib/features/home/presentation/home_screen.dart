import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../core/services/ocr_service.dart';
import '../../../core/config/app_config.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../tools/noise_monitor/presentation/noise_monitor_screen.dart';
import '../../tools/food_calorie/presentation/food_result_screen.dart';
import '../../../core/services/food_ai_service.dart';
import '../../tools/math_grader/presentation/math_grader_screen.dart';
import 'widgets/tool_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();

  bool _isScanning = false;
  bool _isAnalyzingFood = false;
  bool _isGradingMath = false;
  bool _isGridView = false; // Add state for view mode

  Future<void> _startMathGradeFlow({required bool fromCamera}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      if (!mounted) return;
      final isZh = context.read<DictationSettingsProvider>().isChinese;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MathGraderScreen(
            imageFile: File(image.path),
            isZh: isZh,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showMathOptions(BuildContext context) {
    final isZh = context.read<DictationSettingsProvider>().isChinese;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(isZh ? '拍作业批改' : 'Scan Homework'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _startMathGradeFlow(fromCamera: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(isZh ? '从相册选择' : 'Choose from Gallery'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _startMathGradeFlow(fromCamera: false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startFoodAnalysisFlow({required bool fromCamera}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() => _isAnalyzingFood = true);
      
      try {
        if (!mounted) return;
        final isZh = context.read<DictationSettingsProvider>().isChinese;
        final foodAIService = FoodAIService();
        final result = await foodAIService.analyzeFoodImage(image, isZh);
        
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showFoodOptions(BuildContext context) {
    final isZh = context.read<DictationSettingsProvider>().isChinese;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(isZh ? '拍照识别' : 'Take a Photo'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _startFoodAnalysisFlow(fromCamera: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(isZh ? '从相册选择' : 'Choose from Gallery'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _startFoodAnalysisFlow(fromCamera: false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startScanFlow({required bool fromCamera}) async {
    setState(() => _isScanning = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        if (mounted) setState(() => _isScanning = false);
        return;
      }

      final words = await _ocrService.extractWordsFromImage(image);
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
      builder: (bottomSheetContext) {
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
                  Navigator.pop(bottomSheetContext);
                  _startScanFlow(fromCamera: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(isZh ? '从相册选择' : 'Choose from Gallery'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _startScanFlow(fromCamera: false);
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
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: Colors.blue.shade700,
            ),
            tooltip: isZh ? '切换视图' : 'Toggle View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.language, color: Colors.blue.shade700),
            tooltip: 'Switch Language',
            onPressed: () {
              settings.toggleLanguage();
            },
          ),
        ],
      ),
      body: _isGridView 
        ? GridView.count(
            padding: const EdgeInsets.all(16.0),
            crossAxisCount: 2,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            children: AppConfig.tools.map((config) {
              return _buildGridItem(context, config, isZh);
            }).toList(),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ToolCardWidget(
                  config: AppConfig.tools.firstWhere((t) => t.id == 'dictation'),
                  isZh: isZh,
                  isLoading: _isScanning,
                  onAction: () => _showScanOptions(context),
                ),
                ToolCardWidget(
                  config: AppConfig.tools.firstWhere((t) => t.id == 'noise_monitor'),
                  isZh: isZh,
                  onAction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NoiseMonitorScreen()),
                    );
                  },
                ),
                ToolCardWidget(
                  config: AppConfig.tools.firstWhere((t) => t.id == 'food_calorie'),
                  isZh: isZh,
                  isLoading: _isAnalyzingFood,
                  onAction: () => _showFoodOptions(context),
                ),
                ToolCardWidget(
                  config: AppConfig.tools.firstWhere((t) => t.id == 'math_grader'),
                  isZh: isZh,
                  isLoading: _isGradingMath,
                  onAction: () => _showMathOptions(context),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildGridItem(BuildContext context, ToolConfig config, bool isZh) {
    bool isLoading = false;
    VoidCallback onAction;

    if (config.id == 'dictation') {
      isLoading = _isScanning;
      onAction = () => _showScanOptions(context);
    } else if (config.id == 'noise_monitor') {
      onAction = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NoiseMonitorScreen()),
        );
      };
    } else if (config.id == 'food_calorie') {
      isLoading = _isAnalyzingFood;
      onAction = () => _showFoodOptions(context);
    } else {
      isLoading = _isGradingMath;
      onAction = () => _showMathOptions(context);
    }

    return InkWell(
      onTap: isLoading ? null : onAction,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: config.themeColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 40, 
                      height: 40, 
                      child: CircularProgressIndicator(color: config.themeColor, strokeWidth: 3)
                    )
                  : Icon(config.icon, color: config.themeColor, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              isZh ? config.titleZh : config.titleEn,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

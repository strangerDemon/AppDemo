import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../main.dart';
import '../utils/noise_service.dart';
import '../utils/noise_ai_service.dart';
import 'widgets/noise_dashboard.dart';

class NoiseMonitorScreen extends StatefulWidget {
  const NoiseMonitorScreen({super.key});

  @override
  State<NoiseMonitorScreen> createState() => _NoiseMonitorScreenState();
}

class _NoiseMonitorScreenState extends State<NoiseMonitorScreen> {
  final NoiseService _noiseService = NoiseService();
  final NoiseAIService _aiService = NoiseAIService();
  
  double _currentDb = 0.0;
  final List<double> _historyDb = [];
  final int _maxHistory = 50;

  bool _isAnalyzing = false;
  String? _aiSource;
  String? _aiSuggestion;
  bool _enableDirection = false;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _noiseService.stop();
    super.dispose();
  }

  void _startMonitoring() {
    _noiseService.onData = (db) {
      if (!mounted) return;
      setState(() {
        _currentDb = db;
        _historyDb.add(db);
        if (_historyDb.length > _maxHistory) {
          _historyDb.removeAt(0);
        }
      });
    };
    
    _noiseService.onError = (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $err')),
      );
    };

    _noiseService.start();
  }

  Future<void> _generateAIReport(bool isZh) async {
    setState(() {
      _isAnalyzing = true;
      _aiSource = null;
      _aiSuggestion = null;
    });

    try {
      final result = await _aiService.analyzeNoise(_currentDb, isZh);
      if (!mounted) return;
      setState(() {
        _aiSource = result['source'];
        _aiSuggestion = result['suggestion'];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI Analysis failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isZh ? '环境噪音监测' : 'Noise Monitor',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            NoiseDashboard(currentDb: _currentDb, historyDb: _historyDb),
            
            const SizedBox(height: 32),
            
            // Pro Feature Switch
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.explore, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isZh ? '声源方向标记 (需设备支持)' : 'Direction Tracking (Device dep.)',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('PRO', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  Switch(
                    value: _enableDirection,
                    onChanged: (val) {
                      setState(() => _enableDirection = val);
                      if (val) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isZh ? '正在尝试获取双麦克风数据...' : 'Attempting to access dual-mic...')),
                        );
                      }
                    },
                    activeColor: const Color(0xFF2563EB),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // AI Report Action
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : () => _generateAIReport(isZh),
                icon: _isAnalyzing 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isAnalyzing 
                      ? (isZh ? 'AI 正在分析...' : 'AI Analyzing...') 
                      : (isZh ? '生成 AI 降噪建议' : 'Generate AI Suggestion'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // AI Report Result Card
            if (_aiSource != null && _aiSuggestion != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology, color: Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        Text(
                          isZh ? 'AI 分析报告' : 'AI Analysis Report',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      isZh ? '推测噪音源：' : 'Likely Source:',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _aiSource!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isZh ? '降噪建议：' : 'Suggestion:',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _aiSuggestion!,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

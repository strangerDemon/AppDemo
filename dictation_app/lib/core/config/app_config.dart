import 'package:flutter/material.dart';

class ToolConfig {
  final String id;
  final String titleZh;
  final String titleEn;
  final String descZh;
  final String descEn;
  final IconData icon;
  final Color themeColor;
  final bool isAiPowered;
  final String actionLabelZh;
  final String actionLabelEn;

  const ToolConfig({
    required this.id,
    required this.titleZh,
    required this.titleEn,
    required this.descZh,
    required this.descEn,
    required this.icon,
    required this.themeColor,
    this.isAiPowered = true,
    this.actionLabelZh = '开始',
    this.actionLabelEn = 'Start',
  });
}

class AppConfig {
  static const List<ToolConfig> tools = [
    ToolConfig(
      id: 'dictation',
      titleZh: '英语单词听写',
      titleEn: 'Vocabulary Dictation',
      descZh: '拍课本提取单词，AI 自动为你听写并批改。',
      descEn: 'Snap a photo to extract words, AI will dictate and grade.',
      icon: Icons.spellcheck,
      themeColor: Color(0xFF2563EB),
      actionLabelZh: '开始扫描',
      actionLabelEn: 'Scan Now',
    ),
    ToolConfig(
      id: 'noise_monitor',
      titleZh: '环境噪音监测',
      titleEn: 'Noise Monitor',
      descZh: '实时分贝检测，AI 识别噪音源并提供降噪建议。',
      descEn: 'Real-time dB meter, AI identifies sources & suggests solutions.',
      icon: Icons.graphic_eq,
      themeColor: Colors.green,
      actionLabelZh: '进入工具',
      actionLabelEn: 'Open',
    ),
    ToolConfig(
      id: 'food_calorie',
      titleZh: '饮食热量识别',
      titleEn: 'Food Calorie AI',
      descZh: '拍照识别食物，AI 自动估算热量和营养成分。',
      descEn: 'Snap food to estimate calories and nutrients with AI.',
      icon: Icons.restaurant,
      themeColor: Colors.orange,
      actionLabelZh: '拍照识别',
      actionLabelEn: 'Scan Food',
    ),
    ToolConfig(
      id: 'math_grader',
      titleZh: '口算批改',
      titleEn: 'Math Grader',
      descZh: '拍照自动批改口算题',
      descEn: 'Auto grade math problems with camera.',
      icon: Icons.calculate,
      themeColor: Colors.purple,
      actionLabelZh: '拍照批改',
      actionLabelEn: 'Grade Math',
    ),
  ];
}
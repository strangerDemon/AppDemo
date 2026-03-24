import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../core/models/dictation_word.dart';
import '../../tools/dictation/presentation/dictation_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<DictationSettingsProvider>(
          builder: (context, settings, child) => Text(
            settings.isChinese ? '听写设置' : 'Dictation Settings',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<DictationSettingsProvider>(
        builder: (context, settings, child) {
          final isZh = settings.isChinese;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isZh ? '核对识别结果' : 'Review Recognized Words',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${settings.recognizedWords.length} ${isZh ? '词' : 'words'}', style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (settings.recognizedWords.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(isZh ? '未识别到单词，请返回重新扫描。' : 'No words recognized. Please try scanning again.'),
                  )
                else
                  ...settings.recognizedWords.map((word) => _buildWordItem(context, word, settings)).toList(),
                const SizedBox(height: 24),
                Text(
                  isZh ? '听写设置' : 'Session Settings',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildNumberSelector(settings, isZh),
                const SizedBox(height: 16),
                _buildSettingCard(
                  title: isZh ? 'AI 播报间隔' : 'AI Voice Frequency',
                  subtitle: isZh ? '词与词之间的停顿秒数' : 'Pause between words',
                  value: '${settings.voiceFrequency}s',
                  onDecrease: () => settings.updateFrequency(settings.voiceFrequency - 1),
                  onIncrease: () => settings.updateFrequency(settings.voiceFrequency + 1),
                ),
                const SizedBox(height: 12),
                _buildSettingCard(
                  title: isZh ? '重复次数' : 'Repeat Count',
                  subtitle: isZh ? '每个单词读几遍' : 'Times to repeat each word',
                  value: '${settings.repeatCount}x',
                  onDecrease: () => settings.updateRepeatCount(settings.repeatCount - 1),
                  onIncrease: () => settings.updateRepeatCount(settings.repeatCount + 1),
                ),
                const SizedBox(height: 12),
                _buildProToggle(
                  title: isZh ? '包含例句' : 'Include Sentences',
                  value: settings.includeSentences,
                  onChanged: (v) => settings.toggleSentences(v),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: settings.recognizedWords.isEmpty ? null : () {
                      List<DictationWord> finalWords = List.from(settings.recognizedWords);
                      finalWords.shuffle();
                      
                      if (settings.wordsCount > 0 && finalWords.length > settings.wordsCount) {
                        finalWords = finalWords.sublist(0, settings.wordsCount);
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DictationScreen(words: finalWords),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_circle_fill),
                    label: Text(
                      isZh ? '开始听写' : 'Start Dictation',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWordItem(BuildContext context, DictationWord wordData, DictationSettingsProvider settings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.edit_note, color: Color(0xFF2563EB), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(wordData.word, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                if (wordData.meaning.isNotEmpty)
                  Text(wordData.meaning, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.grey.shade400),
            onPressed: () {
              settings.removeWord(wordData);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumberSelector(DictationSettingsProvider settings, bool isZh) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isZh ? '听写数量' : 'NUMBER OF WORDS', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNumberOption(isZh ? '全部' : 'All', settings.wordsCount == 0, () => settings.updateWordsCount(0)),
              _buildNumberOption('10', settings.wordsCount == 10, () => settings.updateWordsCount(10)),
              _buildNumberOption('20', settings.wordsCount == 20, () => settings.updateWordsCount(20)),
              const Icon(Icons.code, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)) : null,
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
          Row(
            children: [
              _buildCircleButton(Icons.remove, Colors.blue.shade50, const Color(0xFF2563EB), onDecrease),
              SizedBox(
                width: 40,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              _buildCircleButton(Icons.add, const Color(0xFF2563EB), Colors.white, onIncrease),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildProToggle({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'PRO',
              style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }
}

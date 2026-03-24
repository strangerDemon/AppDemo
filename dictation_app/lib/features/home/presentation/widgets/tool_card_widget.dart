import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';

class ToolCardWidget extends StatelessWidget {
  final ToolConfig config;
  final bool isZh;
  final bool isLoading;
  final VoidCallback onAction;

  const ToolCardWidget({
    super.key,
    required this.config,
    required this.isZh,
    required this.onAction,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
              color: config.themeColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(config.icon, color: config.themeColor, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (config.isAiPowered)
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: config.themeColor, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        isZh ? 'AI 驱动' : 'AI POWERED',
                        style: TextStyle(
                          color: config.themeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Text(
                  isZh ? config.titleZh : config.titleEn,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isZh ? config.descZh : config.descEn,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: isLoading ? null : onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: config.themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isZh ? config.actionLabelZh : config.actionLabelEn),
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
}
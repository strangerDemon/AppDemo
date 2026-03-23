import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class NoiseDashboard extends StatelessWidget {
  final double currentDb;
  final List<double> historyDb;

  const NoiseDashboard({
    super.key,
    required this.currentDb,
    required this.historyDb,
  });

  Color _getNoiseColor(double db) {
    if (db < 40) return Colors.green;
    if (db < 60) return Colors.blue;
    if (db < 80) return Colors.orange;
    if (db < 100) return Colors.red;
    return Colors.black87;
  }

  String _getNoiseLabel(double db, bool isZh) {
    if (db < 40) return isZh ? '安静' : 'Quiet';
    if (db < 60) return isZh ? '正常' : 'Normal';
    if (db < 80) return isZh ? '吵闹' : 'Noisy';
    if (db < 100) return isZh ? '刺耳' : 'Loud';
    return isZh ? '危险' : 'Dangerous';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getNoiseColor(currentDb);
    final isZh = true; // TODO: get from provider later

    return Column(
      children: [
        // Dial
        Container(
          height: 250,
          width: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
            border: Border.all(color: color.withOpacity(0.5), width: 8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentDb.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Text(
                'dB',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getNoiseLabel(currentDb, isZh),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Waveform chart
        SizedBox(
          height: 120,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 50, // Show last 50 points
              minY: 0,
              maxY: 120,
              lineBarsData: [
                LineChartBarData(
                  spots: historyDb.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value);
                  }).toList(),
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/temperature/temperature_data.dart';
import 'package:intl/intl.dart';

class TemperatureChart extends StatelessWidget {
  final List<TemperatureData> temperatureData;
  final String title;
  final String subtitle;
  
  const TemperatureChart({
    super.key,
    required this.temperatureData,
    this.title = 'Histórico de Temperatura (24h)',
    this.subtitle = 'Temperatura registrada en °C',
  });

  @override
  Widget build(BuildContext context) {
    // Sort data by timestamp
    final sortedData = List<TemperatureData>.from(temperatureData)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Find min and max temperature values (add some padding)
    double minY = sortedData.isNotEmpty 
        ? (sortedData.map((e) => e.value).reduce((a, b) => a < b ? a : b) - 1).clamp(18, 30) 
        : 18;
    double maxY = sortedData.isNotEmpty 
        ? (sortedData.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 1).clamp(18, 30) 
        : 28;    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
            height: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(              subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                ),
              ),
              const SizedBox(height: 16),              Expanded(
                child: sortedData.isEmpty
                    ? const Center(child: Text('No hay datos disponibles'))
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            horizontalInterval: 3,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: isDarkMode 
                                  ? Colors.grey[700]!.withAlpha(30)
                                  : Colors.grey.withAlpha(20),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 3,                              getTitlesWidget: (value, meta) => Text(
                                  '${value.toInt()}°',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                                reservedSize: 28,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  // Only show some timestamps as labels
                                  if (value.toInt() % 4 != 0) {
                                    return const SizedBox.shrink();
                                  }
                                  
                                  if (value.toInt() >= sortedData.length || value.toInt() < 0) {
                                    return const SizedBox.shrink();
                                  }
                                  
                                  final time = sortedData[value.toInt()].timestamp;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat('HH:mm').format(time),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 22,
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: sortedData.length.toDouble() - 1,
                          minY: minY,
                          maxY: maxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: sortedData.asMap().entries.map((entry) {
                                return FlSpot(entry.key.toDouble(), entry.value.value);
                              }).toList(),
                              isCurved: true,
                              barWidth: 3,
                              color: Colors.red,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: Colors.red,
                                    strokeColor: Colors.white,
                                    strokeWidth: 2,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.red.withValues( alpha: 0.1),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(                          touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final data = sortedData[spot.x.toInt()];
                                  return LineTooltipItem(
                                    '${data.value.toStringAsFixed(1)}°C\n${DateFormat('HH:mm').format(data.timestamp)}',
                                    const TextStyle(color: Colors.red),
                                  );
                                }).toList();
                              },
                            ),                          ),                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

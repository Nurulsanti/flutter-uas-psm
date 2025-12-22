import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CitySalesChart extends StatelessWidget {
  final List<Map<String, dynamic>> cityData;
  final bool isDark;

  const CitySalesChart({
    super.key,
    required this.cityData,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    if (cityData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_city, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'Data Kota Tidak Tersedia',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Backend belum menyediakan endpoint',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Sort by sales descending and take top 10
    final sortedData = List<Map<String, dynamic>>.from(cityData)
      ..sort(
        (a, b) => (b['total_sales'] as num).compareTo(a['total_sales'] as num),
      );
    
    final displayData = sortedData.take(10).toList();

    final totalSales = displayData.fold<double>(
      0,
      (sum, item) => sum + (item['total_sales'] as num).toDouble(),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_city,
                  color: Color(0xFF00BCD4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analisis Kota',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Top 10 Kota Berdasarkan Pendapatan',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withOpacity(0.6)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Horizontal Bar Chart
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: displayData.first['total_sales'] * 1.15,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) =>
                        isDark ? const Color(0xFF2D2D2D) : Colors.white,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final city = displayData[group.x.toInt()]['city'];
                      final sales = rod.toY;
                      final percentage = (sales / totalSales * 100)
                          .toStringAsFixed(1);
                      return BarTooltipItem(
                        '$city\n',
                        TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: '\$',
                              decimalDigits: 0,
                            ).format(sales),
                            style: const TextStyle(
                              color: Color(0xFF00BCD4),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: '\n$percentage%',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < displayData.length) {
                          final city = displayData[value.toInt()]['city'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                city.length > 8 ? '${city.substring(0, 8)}...' : city,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.grey[700],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatCurrency(value),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.6)
                                : Colors.grey[600],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: displayData.first['total_sales'] / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.15),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                barGroups: List.generate(displayData.length, (index) {
                  final item = displayData[index];
                  final sales = (item['total_sales'] as num).toDouble();

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: sales,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00BCD4),
                            const Color(0xFF00BCD4).withOpacity(0.7),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: displayData.first['total_sales'] * 1.15,
                          color: isDark
                              ? Colors.white.withOpacity(0.03)
                              : Colors.grey.withOpacity(0.1),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Summary Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00BCD4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00BCD4).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  'Total Kota',
                  displayData.length.toString(),
                  Icons.location_city,
                  isDark,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.3),
                ),
                _buildStat(
                  'Total Pendapatan',
                  _formatCurrency(totalSales),
                  Icons.monetization_on,
                  isDark,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.3),
                ),
                _buildStat(
                  'Rata-rata',
                  _formatCurrency(totalSales / displayData.length),
                  Icons.trending_up,
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, bool isDark) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF00BCD4),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }
}

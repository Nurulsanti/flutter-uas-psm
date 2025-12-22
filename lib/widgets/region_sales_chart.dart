import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegionSalesChart extends StatelessWidget {
  final List<Map<String, dynamic>> regionData;
  final bool isDark;

  const RegionSalesChart({
    super.key,
    required this.regionData,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    if (regionData.isEmpty) {
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
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Text('No data available'),
          ),
        ),
      );
    }

    // Sort by sales descending
    final sortedData = List<Map<String, dynamic>>.from(regionData)
      ..sort(
        (a, b) => (b['total_sales'] as num).compareTo(a['total_sales'] as num),
      );

    final totalSales = sortedData.fold<double>(
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
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: Color(0xFFFF9800),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analisis Wilayah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pendapatan per Region',
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
          const SizedBox(height: 8),

          // Horizontal Bar Chart
          SizedBox(height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: sortedData.first['total_sales'] * 1.15,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) =>
                        isDark ? const Color(0xFF2D2D2D) : Colors.white,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final region = sortedData[group.x.toInt()]['region'];
                      final sales = rod.toY;
                      final percentage = (sales / totalSales * 100)
                          .toStringAsFixed(1);
                      return BarTooltipItem(
                        '$region\n',
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
                            style: TextStyle(
                              color: _getRegionColor(region),
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
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < sortedData.length) {
                          final region = sortedData[value.toInt()]['region'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              region,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.grey[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
                  horizontalInterval: sortedData.first['total_sales'] / 5,
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
                barGroups: List.generate(sortedData.length, (index) {
                  final item = sortedData[index];
                  final region = item['region'];
                  final sales = (item['total_sales'] as num).toDouble();

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: sales,
                        color: _getRegionColor(region),
                        width: 40,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: sortedData.first['total_sales'] * 1.15,
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

          const SizedBox(height: 8),

          // Legend with percentages
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: sortedData.map((item) {
              final region = item['region'];
              final sales = (item['total_sales'] as num).toDouble();
              final percentage = (sales / totalSales * 100);

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getRegionColor(region).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getRegionColor(region).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getRegionColor(region),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      region,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getRegionColor(String region) {
    switch (region.toLowerCase()) {
      case 'west':
        return const Color(0xFF2196F3); // Blue
      case 'east':
        return const Color(0xFF4CAF50); // Green
      case 'central':
        return const Color(0xFFFF9800); // Orange
      case 'south':
        return const Color(0xFF9C27B0); // Purple
      default:
        return Colors.grey;
    }
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






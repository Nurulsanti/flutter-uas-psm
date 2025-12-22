import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StateSalesChart extends StatelessWidget {
  final List<Map<String, dynamic>> stateData;
  final bool isDark;

  const StateSalesChart({
    super.key,
    required this.stateData,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    if (stateData.isEmpty) {
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
                Icon(Icons.map, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'Data Negara Bagian Tidak Tersedia',
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

    // Sort by sales descending
    final sortedData = List<Map<String, dynamic>>.from(stateData)
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
                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.public,
                  color: Color(0xFF9C27B0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analisis Negara Bagian',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pendapatan per State',
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
                maxY: sortedData.first['total_sales'] * 1.15,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) =>
                        isDark ? const Color(0xFF2D2D2D) : Colors.white,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final state = sortedData[group.x.toInt()]['state'];
                      final sales = rod.toY;
                      final percentage = (sales / totalSales * 100)
                          .toStringAsFixed(1);
                      return BarTooltipItem(
                        '$state\n',
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
                              color: _getStateColor(sortedData.indexOf(sortedData[group.x.toInt()])),
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
                            value.toInt() < sortedData.length) {
                          final state = sortedData[value.toInt()]['state'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                state.length > 10 ? '${state.substring(0, 10)}...' : state,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.grey[700],
                                  fontSize: 10,
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
                  final sales = (item['total_sales'] as num).toDouble();

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: sales,
                        gradient: LinearGradient(
                          colors: [
                            _getStateColor(index),
                            _getStateColor(index).withOpacity(0.7),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 16,
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

          const SizedBox(height: 16),

          // Top 5 States Legend
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: sortedData.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final state = item['state'];
              final sales = (item['total_sales'] as num).toDouble();
              final percentage = (sales / totalSales * 100);

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getStateColor(index).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStateColor(index).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStateColor(index),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state,
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

          const SizedBox(height: 16),

          // Summary Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF9C27B0).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  'Total States',
                  sortedData.length.toString(),
                  Icons.public,
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
                  _formatCurrency(totalSales / sortedData.length),
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
          color: const Color(0xFF9C27B0),
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

  Color _getStateColor(int index) {
    final colors = [
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFF673AB7), // Deep Purple
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFF2196F3), // Blue
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF009688), // Teal
      const Color(0xFF4CAF50), // Green
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFFCDDC39), // Lime
    ];
    return colors[index % colors.length];
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

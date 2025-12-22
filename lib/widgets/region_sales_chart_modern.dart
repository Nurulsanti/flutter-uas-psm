import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RegionSalesChart extends StatefulWidget {
  final List<Map<String, dynamic>> regionData;
  final bool isDark;

  const RegionSalesChart({
    super.key,
    required this.regionData,
    required this.isDark,
  });

  @override
  State<RegionSalesChart> createState() => _RegionSalesChartState();
}

class _RegionSalesChartState extends State<RegionSalesChart> {
  int touchedIndex = -1;

  // Modern color scheme with gradients
  final Map<String, List<Color>> regionColors = {
    'West': [const Color(0xFF2196F3), const Color(0xFF64B5F6)],
    'East': [const Color(0xFF4CAF50), const Color(0xFF81C784)],
    'South': [const Color(0xFF9C27B0), const Color(0xFFBA68C8)],
    'Central': [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
  };

  @override
  Widget build(BuildContext context) {
    if (widget.regionData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Chart
          SizedBox(
            height: 280,
            child: Row(
              children: [
                // Bar Chart
                Expanded(
                  flex: 2,
                  child: BarChart(
                    BarChartData(
                      maxY: _calculateMaxY(),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchCallback: (FlTouchEvent event, barTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                barTouchResponse == null ||
                                barTouchResponse.spot == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                          });
                        },
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.black87,
                          tooltipRoundedRadius: 12,
                          tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final region = widget.regionData[groupIndex]['region'];
                            final value = rod.toY;
                            return BarTooltipItem(
                              '$region\n\$${_formatCurrency(value)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= widget.regionData.length) {
                                return const SizedBox.shrink();
                              }
                              final region = widget.regionData[value.toInt()]['region'];
                              final isActive = touchedIndex == value.toInt();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  region,
                                  style: TextStyle(
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                                    fontSize: isActive ? 13 : 12,
                                    color: isActive
                                        ? (widget.isDark ? Colors.white : Colors.black87)
                                        : (widget.isDark ? Colors.white70 : Colors.black54),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  '\$${_formatShortCurrency(value)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                    color: widget.isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _calculateMaxY() / 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarGroups(),
                      alignment: BarChartAlignment.spaceAround,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend with percentage
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildLegend(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(widget.regionData.length, (index) {
      final region = widget.regionData[index]['region'];
      final value = (widget.regionData[index]['total_sales'] ?? 0).toDouble();
      final colors = regionColors[region] ?? [Colors.grey, Colors.grey.shade400];
      final isTouched = index == touchedIndex;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            width: isTouched ? 28 : 22,
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _calculateMaxY(),
              color: widget.isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
            ),
            rodStackItems: [],
          ),
        ],
        showingTooltipIndicators: isTouched ? [0] : [],
      );
    });
  }

  List<Widget> _buildLegend() {
    final total = widget.regionData.fold<double>(
      0,
      (sum, item) => sum + ((item['total_sales'] ?? 0) as num).toDouble(),
    );

    return widget.regionData.map((data) {
      final region = data['region'];
      final value = (data['total_sales'] ?? 0).toDouble();
      final percentage = total > 0 ? (value / total * 100) : 0;
      final colors = regionColors[region] ?? [Colors.grey, Colors.grey];
      final regionIndex = widget.regionData.indexOf(data);
      final isActive = touchedIndex == regionIndex;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          onTap: () {
            setState(() {
              touchedIndex = isActive ? -1 : regionIndex;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? (widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? colors[0].withOpacity(0.5)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: colors[0].withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      region,
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                        fontSize: isActive ? 13 : 12,
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: widget.isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  double _calculateMaxY() {
    final maxValue = widget.regionData.fold<double>(
      0,
      (max, item) {
        final value = (item['total_sales'] ?? 0).toDouble();
        return value > max ? value : max;
      },
    );
    // Add 20% padding to max value for better visualization
    return maxValue * 1.2;
  }

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  String _formatShortCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(0)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}

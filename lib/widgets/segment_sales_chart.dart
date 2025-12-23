import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class SegmentSalesChart extends StatelessWidget {
  final List<Map<String, dynamic>> segmentData;
  final bool isDark;

  const SegmentSalesChart({
    super.key,
    required this.segmentData,
    required this.isDark,
  });

  Color _getSegmentColor(String segment) {
    switch (segment.toLowerCase()) {
      case 'consumer':
        return const Color(0xFF2196F3); // Blue
      case 'corporate':
        return const Color(0xFF4CAF50); // Green
      case 'home office':
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return '\$${value.toStringAsFixed(0)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (segmentData.isEmpty) {
      return const Center(child: Text('No segment data available'));
    }

    // Calculate total sales
    final totalSales = segmentData.fold<double>(
      0,
      (sum, item) => sum + (item['total_sales'] as num).toDouble(),
    );

    // Sort by sales descending
    final sortedData = List<Map<String, dynamic>>.from(segmentData)
      ..sort(
        (a, b) => (b['total_sales'] as num).compareTo(a['total_sales'] as num),
      );

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Penjualan per Segmen Pelanggan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total: ${_formatCurrency(totalSales)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: Row(children: [
                // Pie Chart
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: sortedData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final segment = entry.value;
                        final segmentName = segment['segment'] as String;
                        final sales = (segment['total_sales'] as num)
                            .toDouble();
                        final percentage = (sales / totalSales) * 100;
                        final color = _getSegmentColor(segmentName);

                        return PieChartSectionData(
                          color: color,
                          value: sales,
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white,
                          ),
                          badgeWidget: index == 0
                              ? Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.star,
                                    color: color,
                                    size: 16,
                                  ),
                                )
                              : null,
                          badgePositionPercentageOffset: 1.3,
                        );
                      }).toList(),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // Handle touch events if needed
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Legend
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sortedData.map((segment) {
                      final segmentName = segment['segment'] as String;
                      final sales = (segment['total_sales'] as num).toDouble();
                      final percentage = (sales / totalSales) * 100;
                      final color = _getSegmentColor(segmentName);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                                  Text(
                                    segmentName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_formatCurrency(sales)} (${percentage.toStringAsFixed(1)}%)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Additional Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceAround,
              children: sortedData.map((segment) {
                final segmentName = segment['segment'] as String;
                final sales = (segment['total_sales'] as num).toDouble();
                final color = _getSegmentColor(segmentName);

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getSegmentIcon(segmentName),
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      segmentName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    Text(
                      _formatCurrency(sales),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSegmentIcon(String segment) {
    switch (segment.toLowerCase()) {
      case 'consumer':
        return Icons.shopping_cart;
      case 'corporate':
        return Icons.business;
      case 'home office':
        return Icons.home_work;
      default:
        return Icons.person;
    }
  }
}





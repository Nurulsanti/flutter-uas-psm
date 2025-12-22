import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesTrendChart extends StatefulWidget {
  final List<Map<String, dynamic>> salesData;
  final bool isDark;

  const SalesTrendChart({
    super.key,
    required this.salesData,
    this.isDark = false,
  });

  @override
  State<SalesTrendChart> createState() => _SalesTrendChartState();
}

class _SalesTrendChartState extends State<SalesTrendChart> {
  String _selectedPeriod = 'all';

  List<Map<String, dynamic>> get _filteredData {
    if (_selectedPeriod == 'all') return widget.salesData;

    final now = DateTime.now();
    final monthsToShow = int.parse(_selectedPeriod);

    return widget.salesData.where((data) {
      try {
        final period = data['period'] as String;
        final parts = period.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final dataDate = DateTime(year, month);
        final cutoffDate = DateTime(now.year, now.month - monthsToShow + 1);

        return dataDate.isAfter(cutoffDate) ||
            dataDate.isAtSameMomentAs(cutoffDate);
      } catch (e) {
        return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.salesData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text('No data available'),
        ),
      );
    }

    final filteredData = _filteredData;
    if (filteredData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            'No data for selected period',
            style: TextStyle(
              color: widget.isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ),
      );
    }

    final spots = _generateSpots(filteredData);
    final maxY = _calculateMaxY(filteredData);
    final minY = _calculateMinY(filteredData);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark
              ? const Color(0xFF2D2D2D)
              : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tren Penjualan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark
                          ? Colors.white
                          : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Penjualan Bulanan',
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.isDark
                          ? Colors.white.withOpacity(0.6)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${filteredData.length} Bulan',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? const Color(0xFF2D2D2D)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.isDark
                            ? const Color(0xFF3D3D3D)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedPeriod,
                      underline: const SizedBox(),
                      isDense: true,
                      icon: Icon(
                        Icons.filter_list,
                        size: 16,
                        color: widget.isDark
                            ? Colors.white70
                            : Colors.grey[700],
                      ),
                      dropdownColor: widget.isDark
                          ? const Color(0xFF2D2D2D)
                          : Colors.white,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      items: const [
                        DropdownMenuItem(value: '3', child: Text('3 Bulan')),
                        DropdownMenuItem(value: '6', child: Text('6 Bulan')),
                        DropdownMenuItem(value: '12', child: Text('12 Bulan')),
                        DropdownMenuItem(value: 'all', child: Text('Semua')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPeriod = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 280,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: widget.isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.15),
                      strokeWidth: 1,
                    );
                  },
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
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < filteredData.length) {
                          final period = filteredData[value.toInt()]['period'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _formatPeriod(period),
                              style: TextStyle(
                                color: widget.isDark
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.grey[600],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
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
                      interval: (maxY - minY) / 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatCurrency(value),
                          style: TextStyle(
                            color: widget.isDark
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
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: widget.isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: widget.isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                minX: 0,
                maxX: (filteredData.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: const Color(0xFF2196F3),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF2196F3),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2196F3).withOpacity(0.3),
                          const Color(0xFF2196F3).withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        widget.isDark ? const Color(0xFF2D2D2D) : Colors.white,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final period = filteredData[spot.x.toInt()]['period'];
                        final sales = spot.y;
                        return LineTooltipItem(
                          '${_formatPeriodFull(period)}\n',
                          TextStyle(
                            color: widget.isDark ? Colors.white : Colors.black,
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
                                color: Color(0xFF2196F3),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateSpots(List<Map<String, dynamic>> data) {
    return List.generate(
      data.length,
      (index) =>
          FlSpot(index.toDouble(), (data[index]['sales'] as num).toDouble()),
    );
  }

  double _calculateMaxY(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 100;
    final maxSales = data
        .map((e) => (e['sales'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    return (maxSales * 1.1).ceilToDouble();
  }

  double _calculateMinY(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0;
    final minSales = data
        .map((e) => (e['sales'] as num).toDouble())
        .reduce((a, b) => a < b ? a : b);
    return (minSales * 0.9).floorToDouble();
  }

  String _formatPeriod(String period) {
    try {
      final parts = period.split('-');
      if (parts.length == 2) {
        final monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agu',
          'Sep',
          'Okt',
          'Nov',
          'Des',
        ];
        final month = int.parse(parts[1]);
        return monthNames[month - 1];
      }
    } catch (e) {
      // Ignore
    }
    return period;
  }

  String _formatPeriodFull(String period) {
    try {
      final parts = period.split('-');
      if (parts.length == 2) {
        final monthNames = [
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ];
        final year = parts[0];
        final month = int.parse(parts[1]);
        return '${monthNames[month - 1]} $year';
      }
    } catch (e) {
      // Ignore
    }
    return period;
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

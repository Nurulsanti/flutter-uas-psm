import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dashboard_metrics.dart';

class DailyTrendChart extends StatelessWidget {
  final List<DailySales> dailySales;

  const DailyTrendChart({Key? key, required this.dailySales}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dailySales.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxSales = dailySales
        .map((e) => e.sales)
        .reduce((a, b) => a > b ? a : b);
    final minSales = dailySales
        .map((e) => e.sales)
        .reduce((a, b) => a < b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxSales / 5,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < dailySales.length) {
                  final date = dailySales[value.toInt()].date;
                  final parts = date.split('-');
                  if (parts.length >= 3) {
                    return Text(
                      '${parts[2]}/${parts[1]}',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return Text(
                    date.substring(date.length > 5 ? date.length - 5 : 0),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatSales(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minX: 0,
        maxX: (dailySales.length - 1).toDouble(),
        minY: minSales * 0.9,
        maxY: maxSales * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: dailySales.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.sales);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = dailySales[spot.x.toInt()].date;
                return LineTooltipItem(
                  '$date\n\$${spot.y.toStringAsFixed(0)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  String _formatSales(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}

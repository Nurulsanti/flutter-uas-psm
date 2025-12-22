import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/region_sales_chart.dart';
import '../widgets/monthly_trend_chart.dart';
import '../widgets/top_products_chart.dart';
import '../widgets/segment_sales_chart.dart';
import '../models/dashboard_metrics.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          if (provider.isLoading && provider.summary == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.deepPurple.shade300 : Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading Dashboard...',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header Banner
              _buildHeaderBanner(isDark, provider),
              
              // Summary Cards dalam container dengan height tetap
              Container(
                height: 240,
                padding: const EdgeInsets.all(16),
                child: _buildMetricCards(provider, isDark),
              ),
              
              // TabBar
              _buildTabBar(isDark),
              
              // TabBarView di dalam Expanded (tidak ada scroll luar)
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(provider, isDark),
                    _buildSalesTrendTab(provider, isDark),
                    _buildRegionalAnalysisTab(provider, isDark),
                    _buildProductAnalysisTab(provider, isDark),
                    _buildCustomerAnalysisTab(provider, isDark),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

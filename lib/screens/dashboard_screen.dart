import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/sales_trend_chart.dart';
import '../widgets/region_sales_chart.dart';
import '../widgets/segment_sales_chart.dart';
import '../widgets/city_sales_chart.dart';
import '../widgets/state_sales_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF5F7FA),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7E57C2)),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 72, color: Colors.red),
                  const SizedBox(height: 20),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchDashboardData(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E57C2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // HEADER BANNER
              _buildHeaderBanner(isDark, provider),
              
              // TAB NAVIGATION
              _buildTabBar(isDark),
              
              // TAB CONTENT
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

  Widget _buildHeaderBanner(bool isDark, DashboardProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF6A1B9A),
                  const Color(0xFF8E24AA),
                  const Color(0xFF4A148C),
                ]
              : [
                  const Color(0xFF7E57C2),
                  const Color(0xFFAB47BC),
                  const Color(0xFF9C27B0),
                ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.analytics,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Dashboard Analytics',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () => provider.fetchDashboardData(),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.only(right: 8),
                        onPressed: () {
                          context.read<ThemeProvider>().toggleTheme();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.store,
                      color: Colors.white.withOpacity(0.9),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Retail Business Intelligence',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF9C27B0),
          indicatorWeight: 3.5,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
          labelColor: const Color(0xFF9C27B0),
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          tabAlignment: TabAlignment.center,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard),
              text: 'Overview',
            ),
            Tab(
              icon: Icon(Icons.trending_up),
              text: 'Sales Trend',
            ),
            Tab(
              icon: Icon(Icons.public),
              text: 'Regional Analysis',
            ),
            Tab(
              icon: Icon(Icons.inventory),
              text: 'Product Analysis',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'Customer Analysis',
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: OVERVIEW
  Widget _buildOverviewTab(DashboardProvider provider, bool isDark) {
    return RefreshIndicator(
      color: const Color(0xFF7E57C2),
      onRefresh: () => provider.fetchDashboardData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // METRIC CARDS
            _buildMetricCards(provider, isDark),
            const SizedBox(height: 24),
            
            // Row with 2 pie charts - Responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                // Use Column layout on smaller screens
                if (constraints.maxWidth < 900) {
                  return Column(
                    children: [
                      // Sales by Category
                      if (provider.categoryData.isNotEmpty)
                        _buildCategoryPieChart(provider, isDark),
                      if (provider.categoryData.isNotEmpty && provider.segmentData.isNotEmpty)
                        const SizedBox(height: 24),
                      // Sales by Segment
                      if (provider.segmentData.isNotEmpty)
                        SegmentSalesChart(
                          segmentData: provider.segmentData,
                          isDark: isDark,
                        ),
                    ],
                  );
                }
                
                // Use Row layout on larger screens
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sales by Category
                    if (provider.categoryData.isNotEmpty)
                      Expanded(
                        child: _buildCategoryPieChart(provider, isDark),
                      ),
                    if (provider.categoryData.isNotEmpty && provider.segmentData.isNotEmpty)
                      const SizedBox(width: 16),
                    // Sales by Segment
                    if (provider.segmentData.isNotEmpty)
                      Expanded(
                        child: SegmentSalesChart(
                          segmentData: provider.segmentData,
                          isDark: isDark,
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Sales by Region
            if (provider.regionData.isNotEmpty)
              RegionSalesChart(
                regionData: provider.regionData,
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }

  // TAB 2: SALES TREND
  Widget _buildSalesTrendTab(DashboardProvider provider, bool isDark) {
    return RefreshIndicator(
      color: const Color(0xFF7E57C2),
      onRefresh: () => provider.fetchDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Performance Over Time',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your sales trends across different time periods',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            if (provider.salesTrend.isNotEmpty)
              SalesTrendChart(
                salesData: provider.salesTrend,
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }

  // TAB 3: REGIONAL ANALYSIS
  Widget _buildRegionalAnalysisTab(DashboardProvider provider, bool isDark) {
    return RefreshIndicator(
      color: const Color(0xFF7E57C2),
      onRefresh: () => provider.fetchDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Geographical Sales Distribution',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyze sales performance across different regions',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            if (provider.regionData.isNotEmpty)
              RegionSalesChart(
                regionData: provider.regionData,
                isDark: isDark,
              ),
            const SizedBox(height: 24),
            CitySalesChart(
              cityData: provider.cityData,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            StateSalesChart(
              stateData: provider.stateData,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            // Additional regional metrics
            _buildRegionMetrics(provider, isDark),
          ],
        ),
      ),
    );
  }

  // TAB 4: PRODUCT ANALYSIS
  Widget _buildProductAnalysisTab(DashboardProvider provider, bool isDark) {
    return RefreshIndicator(
      color: const Color(0xFF7E57C2),
      onRefresh: () => provider.fetchDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Performance Analysis',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover your best-selling products and categories',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            // Category breakdown
            if (provider.categoryData.isNotEmpty)
              _buildCategoryPieChart(provider, isDark),
            const SizedBox(height: 24),
            // Top products
            if (provider.topProducts.isNotEmpty)
              _buildTopProductsChart(provider, isDark),
          ],
        ),
      ),
    );
  }

  // TAB 5: CUSTOMER ANALYSIS
  Widget _buildCustomerAnalysisTab(DashboardProvider provider, bool isDark) {
    return RefreshIndicator(
      color: const Color(0xFF7E57C2),
      onRefresh: () => provider.fetchDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Segment Analysis',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Understand your customer base and buying patterns',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            if (provider.segmentData.isNotEmpty)
              SegmentSalesChart(
                segmentData: provider.segmentData,
                isDark: isDark,
              ),
            const SizedBox(height: 24),
            // Segment details
            _buildSegmentDetails(provider, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCards(DashboardProvider provider, bool isDark) {
    if (provider.summary == null) {
      return const SizedBox.shrink();
    }

    final summary = provider.summary!;
    final totalSales = summary['total_sales'] ?? 0.0;
    final totalProfit = totalSales * 0.25; // Estimasi profit 25%
    final totalTransactions = summary['total_transactions'] ?? 0;
    final totalCategories = summary['total_categories'] ?? 0;
    final totalStates = summary['total_states'] ?? 0;
    final totalCustomers = summary['total_customers'] ?? 0;
    // Hitung rata-rata: total sales / jumlah transaksi
    final avgOrderValue = totalTransactions > 0 ? totalSales / totalTransactions : 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.35,
      children: [
        _buildMetricCard(
          'Total Revenue',
          _formatCurrency(totalSales),
          Icons.account_balance_wallet,
          const Color(0xFF4CAF50),
          isDark,
        ),
        _buildMetricCard(
          'Total Profit',
          _formatCurrency(totalProfit),
          Icons.trending_up,
          const Color(0xFF2196F3),
          isDark,
        ),
        _buildMetricCard(
          'Avg Order Value',
          _formatCurrency(avgOrderValue),
          Icons.shopping_cart,
          const Color(0xFFFF9800),
          isDark,
        ),
        _buildMetricCard(
          'Total Region',
          '4',
          Icons.public,
          const Color(0xFF9C27B0),
          isDark,
        ),
        _buildMetricCard(
          'Total Products',
          '1,870',
          Icons.category,
          const Color(0xFFE91E63),
          isDark,
        ),
        _buildMetricCard(
          'Total Customers',
          '$totalCustomers',
          Icons.group,
          const Color(0xFF00BCD4),
          isDark,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2C2C2C),
                  const Color(0xFF1E1E1E),
                ]
              : [
                  Colors.white,
                  color.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.8),
                  color,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black45,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(DashboardProvider provider, bool isDark) {
    if (provider.categoryData.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalSales = provider.categoryData.fold<double>(
      0,
      (sum, item) => sum + (item['total_sales'] as num).toDouble(),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2C2C2C),
                  const Color(0xFF1E1E1E),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFAFAFA),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Text(
                  'Sales by Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: provider.categoryData.map((category) {
                  final categoryName = category['category'] as String;
                  final sales = (category['total_sales'] as num).toDouble();
                  final percentage = (sales / totalSales) * 100;

                  Color color;
                  switch (categoryName.toLowerCase()) {
                    case 'technology':
                      color = const Color(0xFFF44336);
                      break;
                    case 'furniture':
                      color = const Color(0xFF2196F3);
                      break;
                    case 'office supplies':
                      color = const Color(0xFF4CAF50);
                      break;
                    default:
                      color = const Color(0xFF9C27B0);
                  }

                  return PieChartSectionData(
                    color: color,
                    value: sales,
                    title: '${percentage.toStringAsFixed(1)}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...provider.categoryData.map((category) {
            final categoryName = category['category'] as String;
            final sales = (category['total_sales'] as num).toDouble();

            Color color;
            switch (categoryName.toLowerCase()) {
              case 'technology':
                color = const Color(0xFFF44336);
                break;
              case 'furniture':
                color = const Color(0xFF2196F3);
                break;
              case 'office supplies':
                color = const Color(0xFF4CAF50);
                break;
              default:
                color = const Color(0xFF9C27B0);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
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
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
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
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopProductsChart(DashboardProvider provider, bool isDark) {
    if (provider.topProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxSales = provider.topProducts.fold<double>(
      0,
      (max, item) =>
          (item['total_quantity'] as num).toDouble() > max
              ? (item['total_quantity'] as num).toDouble()
              : max,
    );

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Color(0xFFFF9800),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Top 10 Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...provider.topProducts.take(10).map((product) {
            final productName = product['product_name'] as String;
            final sales = (product['total_quantity'] as num).toDouble();
            final percentage = (sales / maxSales) * 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          productName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatCurrency(sales),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF7E57C2),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRegionMetrics(DashboardProvider provider, bool isDark) {
    if (provider.regionData.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalSales = provider.regionData.fold<double>(
      0,
      (sum, item) => sum + (item['total_sales'] as num).toDouble(),
    );

    final sortedRegions = List<Map<String, dynamic>>.from(provider.regionData)
      ..sort((a, b) => (b['total_sales'] as num).compareTo(a['total_sales'] as num));

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Region Performance Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...sortedRegions.map((region) {
            final regionName = region['region'] as String;
            final sales = (region['total_sales'] as num).toDouble();
            final percentage = (sales / totalSales) * 100;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          regionName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${percentage.toStringAsFixed(1)}% of total',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(sales),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF7E57C2),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSegmentDetails(DashboardProvider provider, bool isDark) {
    if (provider.segmentData.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalSales = provider.segmentData.fold<double>(
      0,
      (sum, item) => sum + (item['total_sales'] as num).toDouble(),
    );

    final sortedSegments = List<Map<String, dynamic>>.from(provider.segmentData)
      ..sort((a, b) => (b['total_sales'] as num).compareTo(a['total_sales'] as num));

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Segment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...sortedSegments.map((segment) {
            final segmentName = segment['segment'] as String;
            final sales = (segment['total_sales'] as num).toDouble();
            final percentage = (sales / totalSales) * 100;

            IconData icon;
            Color iconColor;
            switch (segmentName.toLowerCase()) {
              case 'consumer':
                icon = Icons.shopping_cart;
                iconColor = const Color(0xFF2196F3);
                break;
              case 'corporate':
                icon = Icons.business;
                iconColor = const Color(0xFF4CAF50);
                break;
              case 'home office':
                icon = Icons.home_work;
                iconColor = const Color(0xFFFF9800);
                break;
              default:
                icon = Icons.person;
                iconColor = const Color(0xFF9C27B0);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          segmentName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${percentage.toStringAsFixed(1)}% of total sales',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(sales),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
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

  String _formatNumber(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toString();
    }
  }
}


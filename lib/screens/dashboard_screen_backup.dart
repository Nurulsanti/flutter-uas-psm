import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/sales_trend_chart.dart';
import '../widgets/region_sales_chart.dart';
import '../widgets/segment_sales_chart.dart';
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
              
              // SUMMARY CARDS
              Padding(padding: const EdgeInsets.all(12),child: _buildMetricCards(provider, isDark),
              ),
              
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
                  const Color(0xFF7E57C2),
                  const Color(0xFF5E35B1),
                ]
              : [
                  const Color(0xFF7E57C2),
                  const Color(0xFF9575CD),
                ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard Analytics',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () => provider.fetchDashboardData(),
                      ),
                      IconButton(
                        icon: Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          context.read<ThemeProvider>().toggleTheme();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Retail Business Intelligence',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
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
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: const Color(0xFF7E57C2),
        indicatorWeight: 3,
        labelColor: const Color(0xFF7E57C2),
        unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
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
    );
  }

  // TAB 1: OVERVIEW
  Widget _buildOverviewTab(DashboardProvider provider, bool isDark) {
    return RefreshIndicator(
      color: const Color(0xFF7E57C2),
      onRefresh: () => provider.fetchDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with 2 pie charts
            Row(
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
    final totalCategories = summary['total_categories'] ?? 0;
    final totalTransactions = summary['total_transactions'] ?? 0;
    final totalStates = summary['total_states'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildMetricCard(
                'Total Revenue',
                _formatCurrency(totalSales),
                Icons.attach_money,
                const Color(0xFF4CAF50),
                isDark,
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                'Orders',
                _formatNumber(totalTransactions),
                Icons.shopping_cart,
                const Color(0xFFFF9800),
                isDark,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _buildMetricCard(
                'Categories',
                totalCategories.toString(),
                Icons.category,
                const Color(0xFF2196F3),
                isDark,
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                'States',
                totalStates.toString(),
                Icons.location_on,
                const Color(0xFF9C27B0),
                isDark,
              ),
            ],
          ),
        )
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
      padding: const EdgeInsets.all(12),
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
          Container(height: 40,width: 40,padding: const EdgeInsets.all(8),decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
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
              Icon(
                Icons.category,
                color: const Color(0xFF2196F3),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Sales by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
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

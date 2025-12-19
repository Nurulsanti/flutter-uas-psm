class DashboardMetrics {
  final double totalSales;
  final double totalProfit;
  final int totalOrders;
  final double avgOrderValue;

  DashboardMetrics({
    required this.totalSales,
    required this.totalProfit,
    required this.totalOrders,
    required this.avgOrderValue,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalProfit: (json['total_profit'] ?? 0).toDouble(),
      totalOrders: json['total_orders'] ?? 0,
      avgOrderValue: (json['avg_order_value'] ?? 0).toDouble(),
    );
  }
}

class CategorySales {
  final String category;
  final double sales;

  CategorySales({required this.category, required this.sales});

  factory CategorySales.fromJson(String category, dynamic sales) {
    return CategorySales(
      category: category,
      sales: (sales ?? 0).toDouble(),
    );
  }
}

class TopProduct {
  final String name;
  final double sales;

  TopProduct({required this.name, required this.sales});

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      name: json['name'] ?? '',
      sales: (json['sales'] ?? 0).toDouble(),
    );
  }
}

class MonthlySales {
  final String period;
  final double sales;

  MonthlySales({required this.period, required this.sales});

  factory MonthlySales.fromJson(Map<String, dynamic> json) {
    return MonthlySales(
      period: json['period'] ?? '',
      sales: (json['sales'] ?? 0).toDouble(),
    );
  }
}

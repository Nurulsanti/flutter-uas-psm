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
    return CategorySales(category: category, sales: (sales ?? 0).toDouble());
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

class DailySales {
  final String date;
  final double sales;

  DailySales({required this.date, required this.sales});

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: json['date'] ?? '',
      sales: (json['sales'] ?? 0).toDouble(),
    );
  }
}

class RegionSales {
  final String region;
  final double sales;

  RegionSales({required this.region, required this.sales});

  factory RegionSales.fromJson(Map<String, dynamic> json) {
    return RegionSales(
      region: json['region'] ?? '',
      sales: (json['sales'] ?? 0).toDouble(),
    );
  }
}

class StateSales {
  final String state;
  final double sales;

  StateSales({required this.state, required this.sales});

  factory StateSales.fromJson(Map<String, dynamic> json) {
    return StateSales(
      state: json['state'] ?? '',
      sales: (json['sales'] ?? 0).toDouble(),
    );
  }
}

class SegmentSales {
  final String segment;
  final double sales;

  SegmentSales({required this.segment, required this.sales});

  factory SegmentSales.fromJson(Map<String, dynamic> json) {
    return SegmentSales(
      segment: json['segment'] ?? '',
      sales: (json['sales'] ?? 0).toDouble(),
    );
  }
}


class CitySales {
  final String city;
  final double sales;

  CitySales({required this.city, required this.sales});

  factory CitySales.fromJson(Map<String, dynamic> json) {
    return CitySales(
      city: json['city'] ?? '',
      sales: (json['sales'] ?? 0).toDouble(),
    );
  }
}


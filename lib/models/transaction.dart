class Transaction {
  final int? id;
  final int productId;
  final int customerId;
  final int regionId;
  final double sales;
  final DateTime transactionDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Transaction({
    this.id,
    required this.productId,
    required this.customerId,
    required this.regionId,
    required this.sales,
    required this.transactionDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      productId: json['product_id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      regionId: json['region_id'] ?? 0,
      sales: double.parse(json['sales'].toString()),
      transactionDate: DateTime.parse(json['transaction_date']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'customer_id': customerId,
      'region_id': regionId,
      'sales': sales,
      'transaction_date': transactionDate.toIso8601String(),
    };
  }
}

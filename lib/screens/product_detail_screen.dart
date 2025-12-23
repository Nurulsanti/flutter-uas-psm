import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider = context.read<ProductProvider>();
    final product = await provider.fetchProductDetail(widget.productId);

    setState(() {
      _product = product;
      _isLoading = false;
      _error = provider.error;
    });
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'furniture':
        return const Color(0xFF6366F1); // Indigo
      case 'office supplies':
        return const Color(0xFFEC4899); // Pink
      case 'technology':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Product Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getCategoryColor('default'),
                ),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Oops! Something went wrong',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadProduct,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _product == null
                  ? const Center(child: Text('Product not found'))
                  : Stack(
                      children: [
                        // Gradient Background
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getCategoryColor(_product!.category),
                                _getCategoryColor(_product!.category).withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        
                        // Content
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 120),
                              
                              // Product Header Card with gradient
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        _getCategoryColor(_product!.category).withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getCategoryColor(_product!.category).withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _getCategoryColor(_product!.category),
                                                    _getCategoryColor(_product!.category).withOpacity(0.7),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.shopping_bag,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _product!.productName,
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      color: isDark ? Colors.black87 : Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getCategoryColor(_product!.category).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      'ID: ${_product!.productId}',
                                                      style: TextStyle(
                                                        color: _getCategoryColor(_product!.category),
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Category Info with modern design
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: _buildModernInfoCard(
                                  'Category Information',
                                  Icons.category,
                                  _getCategoryColor(_product!.category),
                                  [
                                    _buildModernInfoRow(
                                      Icons.folder,
                                      'Category',
                                      _product!.category,
                                      _getCategoryColor(_product!.category),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildModernInfoRow(
                                      Icons.label,
                                      'Sub-Category',
                                      _product!.subCategory,
                                      _getCategoryColor(_product!.category),
                                    ),
                                  ],
                                  isDark,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Additional Info with modern design
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: _buildModernInfoCard(
                                  'Additional Information',
                                  Icons.info_outline,
                                  const Color(0xFF10B981), // Green
                                  [
                                    _buildModernInfoRow(
                                      Icons.calendar_today,
                                      'Created At',
                                      _formatDate(_product!.createdAt),
                                      const Color(0xFF10B981),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildModernInfoRow(
                                      Icons.update,
                                      'Updated At',
                                      _formatDate(_product!.updatedAt),
                                      const Color(0xFF10B981),
                                    ),
                                  ],
                                  isDark,
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildModernInfoCard(
    String title,
    IconData icon,
    Color accentColor,
    List<Widget> children,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor,
                        accentColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoRow(IconData icon, String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

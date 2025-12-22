import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/quick_transaction_dialog.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = [
    'All',
    'Furniture',
    'Office Supplies',
    'Technology',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'All';
    _pageController.text = '1';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  void _performSearch() {
    final page = int.tryParse(_pageController.text) ?? 1;
    context.read<ProductProvider>().fetchProducts(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      page: page,
    );
  }

  void _goToPage(int page) {
    if (page < 1) return;
    final provider = context.read<ProductProvider>();
    if (page > provider.totalPages) return;

    setState(() {
      _pageController.text = page.toString();
    });
    _performSearch();
  }

  void _showQuickSellDialog(BuildContext context, product) {
    showDialog(
      context: context,
      builder: (context) => QuickTransactionDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.qr_code_scanner,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: isDark ? Colors.grey[850] : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  _performSearch();
                }
              },
              onSubmitted: (_) => _performSearch(),
            ),
          ),

          // Category Filter Chips
          Container(
            color: isDark ? Colors.grey[850] : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                          _performSearch();
                        });
                      },
                      backgroundColor: isDark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      selectedColor: const Color(0xFF6750A4).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF6750A4),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF6750A4)
                            : (isDark ? Colors.grey[300] : Colors.grey[700]),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF6750A4)
                            : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Product Grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6750A4)),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${provider.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => provider.fetchProducts(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6750A4),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchProducts(),
                  color: const Color(0xFF6750A4),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: provider.products.length,
                    itemBuilder: (context, index) {
                      final product = provider.products[index];
                      return _buildProductCard(product, isDark);
                    },
                  ),
                );
              },
            ),
          ),

          // Pagination Controls
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.products.isEmpty) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Button
                    ElevatedButton.icon(
                      onPressed: provider.currentPage > 1
                          ? () => _goToPage(provider.currentPage - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left, size: 18),
                      label: const Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6750A4),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),

                    // Page Info
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Page',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: _pageController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6750A4),
                                ),
                              ),
                            ),
                            onSubmitted: (value) {
                              final page = int.tryParse(value);
                              if (page != null &&
                                  page > 0 &&
                                  page <= provider.totalPages) {
                                _goToPage(page);
                              } else {
                                _pageController.text = provider.currentPage
                                    .toString();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'of ${provider.totalPages}',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    // Next Button
                    ElevatedButton.icon(
                      onPressed: provider.currentPage < provider.totalPages
                          ? () => _goToPage(provider.currentPage + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right, size: 18),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6750A4),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      iconAlignment: IconAlignment.end,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(product, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.devices,
                    size: 48,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ),
            ),

            // Product Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                    Text(
                      product.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 1),

                    // Category
                    Text(
                      '${product.category} - ${product.subCategory}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Buy Button
                    SizedBox(
                      width: double.infinity,
                      height: 24,
                      child: ElevatedButton(
                        onPressed: () => _showQuickSellDialog(context, product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF6750A4)
                              : const Color(0xFF6750A4).withOpacity(0.1),
                          foregroundColor: isDark
                              ? Colors.white
                              : const Color(0xFF6750A4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Buy',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

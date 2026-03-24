import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../presentation/controllers/product_controller.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ProductController _productController;
  String _title = 'Products';
  String _categoryId = '';

  @override
  void initState() {
    super.initState();
    _productController = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());

    final args = Get.arguments;
    if (args != null && args is Map) {
      _categoryId = args['categoryId'] ?? '';
      _title = args['title'] ?? 'Products';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productController.loadProducts(categoryId: _categoryId.isEmpty ? null : _categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            onPressed: _showSortFilterSheet,
            icon: const Icon(Icons.tune),
            tooltip: 'Filter & Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSortFilterBar(),
          Expanded(
            child: Obx(() {
              if (_productController.isLoading.value) {
                return _buildShimmer();
              }
              if (_productController.filteredProducts.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.inventory_2_outlined,
                  title: 'No Products Found',
                  subtitle: 'We couldn\'t find any products in this category.',
                  buttonText: 'Go Back',
                  onButtonTap: () => Get.back(),
                );
              }
              return RefreshIndicator(
                onRefresh: _productController.refresh,
                color: AppTheme.primaryColor,
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: _productController.filteredProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: _productController.filteredProducts[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSortFilterBar() {
    final sortOptions = [
      ('default', 'Default'),
      ('popular', 'Popular'),
      ('price_asc', 'Price: Low to High'),
      ('price_desc', 'Price: High to Low'),
      ('rating', 'Top Rated'),
      ('newest', 'Newest'),
    ];

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Obx(() => Row(
              children: sortOptions.map((option) {
                final isSelected = _productController.sortBy.value == option.$1;
                return GestureDetector(
                  onTap: () => _productController.setSortBy(option.$1),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      option.$2,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }

  Widget _buildShimmer() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(12),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.68,
      children: List.generate(6, (i) => const ProductCardShimmer()),
    );
  }

  void _showSortFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(controller: _productController),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final ProductController controller;

  const _FilterBottomSheet({required this.controller});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late RangeValues _priceRange;
  late String _sortBy;

  static const double minPrice = 0;
  static const double maxPrice = 200000;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      widget.controller.selectedMinPrice.value,
      widget.controller.selectedMaxPrice.value > maxPrice ? maxPrice : widget.controller.selectedMaxPrice.value,
    );
    _sortBy = widget.controller.sortBy.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filter & Sort', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: () {
                  widget.controller.resetFilters();
                  setState(() {
                    _priceRange = const RangeValues(minPrice, maxPrice);
                    _sortBy = 'default';
                  });
                },
                child: const Text('Reset All'),
              ),
            ],
          ),
          const Divider(),
          const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ('default', 'Default'),
              ('popular', 'Popular'),
              ('price_asc', 'Price: Low-High'),
              ('price_desc', 'Price: High-Low'),
              ('rating', 'Top Rated'),
              ('newest', 'Newest'),
            ].map((option) {
              final isSelected = _sortBy == option.$1;
              return GestureDetector(
                onTap: () => setState(() => _sortBy = option.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    option.$2,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Price Range', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('৳${_priceRange.start.round()}', style: const TextStyle(fontSize: 13)),
              Text('৳${_priceRange.end.round()}', style: const TextStyle(fontSize: 13)),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: minPrice,
            max: maxPrice,
            activeColor: AppTheme.primaryColor,
            inactiveColor: Colors.grey.shade200,
            onChanged: (values) => setState(() => _priceRange = values),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.controller.setSortBy(_sortBy);
                    widget.controller.setPriceRange(_priceRange.start, _priceRange.end);
                    Get.back();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

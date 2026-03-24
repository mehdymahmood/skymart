import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../presentation/controllers/sell_controller.dart';
import '../../../presentation/controllers/order_controller.dart';
import '../../../data/providers/mock_data_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellController = Get.find<SellController>();
    final orderController = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController());
    final allProducts = MockDataProvider().getProducts();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.postProduct),
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Post Product',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                Obx(() => _StatCard(
                      label: 'My Products',
                      value: sellController.myProducts.length.toString(),
                      icon: Icons.inventory_2_outlined,
                      color: AppTheme.primaryColor,
                      onTap: () => Get.toNamed(AppRoutes.adminProducts),
                    )),
                Obx(() => _StatCard(
                      label: 'Total Orders',
                      value: orderController.orders.length.toString(),
                      icon: Icons.shopping_bag_outlined,
                      color: const Color(0xFF2E7D32),
                      onTap: () => Get.toNamed(AppRoutes.orders),
                    )),
                _StatCard(
                  label: 'All Products',
                  value: allProducts.length.toString(),
                  icon: Icons.store_outlined,
                  color: const Color(0xFFE65100),
                  onTap: () => Get.toNamed(AppRoutes.adminProducts),
                ),
                Obx(() => _StatCard(
                      label: 'Revenue (Est.)',
                      value: '৳${_calcRevenue(orderController)}',
                      icon: Icons.attach_money,
                      color: const Color(0xFF6A1B9A),
                      onTap: () {},
                    )),
              ],
            ),
            const SizedBox(height: 20),

            // Quick actions
            const Text('Quick Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'Post Product',
                    color: AppTheme.primaryColor,
                    onTap: () => Get.toNamed(AppRoutes.postProduct),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.list_alt_outlined,
                    label: 'My Products',
                    color: const Color(0xFF00897B),
                    onTap: () => Get.toNamed(AppRoutes.adminProducts),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Recent products
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Posted Products',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.adminProducts),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (sellController.myProducts.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('📦', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      const Text('No products yet',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 6),
                      const Text('Tap "Post Product" to add your first listing',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed(AppRoutes.postProduct),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Post Product'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: sellController.myProducts.take(5).map((product) {
                  return _ProductListTile(
                    product: product,
                    onEdit: () => Get.toNamed(AppRoutes.postProduct, arguments: product),
                    onDelete: () => _confirmDelete(context, sellController, product.id),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.postProduct),
        icon: const Icon(Icons.add),
        label: const Text('Post Product'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  String _calcRevenue(OrderController ctrl) {
    final total = ctrl.completedOrders.fold(0.0, (sum, o) => sum + o.total);
    if (total >= 1000000) return '${(total / 1000000).toStringAsFixed(1)}M';
    if (total >= 1000) return '${(total / 1000).toStringAsFixed(1)}K';
    return total.toStringAsFixed(0);
  }

  void _confirmDelete(BuildContext context, SellController ctrl, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.deleteProduct(id);
              Get.snackbar('Deleted', 'Product removed',
                  snackPosition: SnackPosition.BOTTOM);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800, color: color)),
                Text(label,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final dynamic product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductListTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.images.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.images[0],
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey, size: 24),
                    ),
                  )
                : Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.inventory_2_outlined,
                        color: Colors.grey, size: 24),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('৳${product.price.toStringAsFixed(0)}  •  Stock: ${product.stock}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primaryColor),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}

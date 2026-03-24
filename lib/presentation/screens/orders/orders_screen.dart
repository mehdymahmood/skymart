import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../data/models/order_model.dart';
import '../../../presentation/controllers/order_controller.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderController _orderController;

  @override
  void initState() {
    super.initState();
    _orderController = Get.put(OrderController());
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      _orderController.setOrderTab(_tabController.index);
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
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Obx(() {
        if (_orderController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        return TabBarView(
          controller: _tabController,
          children: [
            _buildOrderList(_orderController.activeOrders, 'active'),
            _buildOrderList(_orderController.completedOrders, 'completed'),
            _buildOrderList(_orderController.cancelledOrders, 'cancelled'),
          ],
        );
      }),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, String type) {
    if (orders.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.shopping_bag_outlined,
        title: 'No ${type == 'active' ? 'Active' : type == 'completed' ? 'Completed' : 'Cancelled'} Orders',
        subtitle: type == 'active'
            ? 'You have no active orders right now.'
            : type == 'completed'
                ? 'You haven\'t completed any orders yet.'
                : 'No cancelled orders.',
        buttonText: type == 'active' ? 'Start Shopping' : null,
        onButtonTap: type == 'active' ? () => Get.offAllNamed(AppRoutes.main) : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _orderController.refresh,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => _OrderCard(order: orders[index]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.orderDetail, arguments: order.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppUtils.formatDateTime(order.placedAt),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: order.status),
                ],
              ),
            ),
            // Product images row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  ...order.items.take(3).map((item) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: CachedNetworkImage(
                            imageUrl: item.product.images.isNotEmpty ? item.product.images[0] : '',
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                            ),
                          ),
                        ),
                      )),
                  if (order.items.length > 3)
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '+${order.items.length - 3}',
                          style: const TextStyle(
                              color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order.itemCount} item${order.itemCount > 1 ? 's' : ''}',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                        Text(
                          AppUtils.formatPrice(order.total),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                          color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = _getStatusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  (Color, Color) _getStatusColors(String status) {
    switch (status) {
      case 'Placed':
        return (const Color(0xFF1565C0), const Color(0xFFE3F2FD));
      case 'Confirmed':
        return (const Color(0xFF6A1B9A), const Color(0xFFF3E5F5));
      case 'Shipped':
        return (const Color(0xFFE65100), const Color(0xFFFFF3E0));
      case 'Delivered':
        return (AppTheme.successColor, AppTheme.successColor.withOpacity(0.12));
      case 'Cancelled':
        return (AppTheme.errorColor, AppTheme.errorColor.withOpacity(0.12));
      default:
        return (Colors.grey.shade600, Colors.grey.shade100);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../presentation/controllers/order_controller.dart';
import '../../../data/models/order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderController _orderController;

  @override
  void initState() {
    super.initState();
    _orderController = Get.find<OrderController>();
    final orderId = Get.arguments?.toString() ?? '';
    if (orderId.isNotEmpty) {
      _orderController.loadOrderDetail(orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: Obx(() {
        final order = _orderController.selectedOrder.value;
        if (order == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(order),
              const SizedBox(height: 16),
              _buildTimeline(order),
              const SizedBox(height: 16),
              _buildOrderItems(order),
              const SizedBox(height: 16),
              _buildDeliveryAddress(order),
              const SizedBox(height: 16),
              _buildPaymentSummary(order),
              if (order.isActive) ...[
                const SizedBox(height: 20),
                _buildCancelButton(order),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderNumber,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppUtils.formatDateTime(order.placedAt),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          if (order.trackingNumber != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 18, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  const Text('Tracking: ', style: TextStyle(fontSize: 13)),
                  Text(
                    order.trackingNumber!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline(OrderModel order) {
    final timeline = order.timeline;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Timeline', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 16),
          ...timeline.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final isLast = index == timeline.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: event.isCompleted
                            ? AppTheme.successColor
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        event.isCompleted ? Icons.check : Icons.circle_outlined,
                        color: event.isCompleted ? Colors.white : Colors.grey.shade400,
                        size: 16,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: event.isCompleted
                            ? AppTheme.successColor.withOpacity(0.4)
                            : Colors.grey.shade200,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: event.isCompleted
                                ? const Color(0xFF212121)
                                : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          event.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: event.isCompleted
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                        ),
                        if (event.dateTime != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            AppUtils.formatDateTime(event.dateTime!),
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.successColor, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderItems(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items (${order.itemCount})',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: item.product.images.isNotEmpty ? item.product.images[0] : '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          if (item.selectedSize != null || item.selectedColor != null)
                            Text(
                              [
                                if (item.selectedSize != null) 'Size: ${item.selectedSize}',
                                if (item.selectedColor != null) 'Color: ${item.selectedColor}',
                              ].join(' | '),
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            '${AppUtils.formatPrice(item.product.price)} x ${item.quantity}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      AppUtils.formatPrice(item.totalPrice),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(OrderModel order) {
    final addr = order.deliveryAddress;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          Text(addr.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 2),
          Text(addr.phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 2),
          Text(addr.fullAddress,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          _SummaryRow('Payment Method', order.paymentMethod),
          const SizedBox(height: 8),
          _SummaryRow('Subtotal', AppUtils.formatPrice(order.subtotal)),
          const SizedBox(height: 8),
          _SummaryRow('Shipping Fee',
              order.shippingFee == 0 ? 'FREE' : AppUtils.formatPrice(order.shippingFee)),
          if (order.discount > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow('Discount', '-${AppUtils.formatPrice(order.discount)}',
                valueColor: AppTheme.successColor),
          ],
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
          _SummaryRow('Total', AppUtils.formatPrice(order.total),
              isBold: true, valueColor: AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildCancelButton(OrderModel order) {
    if (order.status == 'Shipped' || order.status == 'Delivered') {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmCancel(order),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.errorColor,
          side: const BorderSide(color: AppTheme.errorColor),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Cancel Order', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _confirmCancel(OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('No')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _orderController.cancelOrder(order.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: colors.$2, borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: colors.$1, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  (Color, Color) _getColors(String status) {
    switch (status) {
      case 'Placed': return (const Color(0xFF1565C0), const Color(0xFFE3F2FD));
      case 'Confirmed': return (const Color(0xFF6A1B9A), const Color(0xFFF3E5F5));
      case 'Shipped': return (const Color(0xFFE65100), const Color(0xFFFFF3E0));
      case 'Delivered': return (AppTheme.successColor, AppTheme.successColor.withOpacity(0.12));
      case 'Cancelled': return (AppTheme.errorColor, AppTheme.errorColor.withOpacity(0.12));
      default: return (Colors.grey.shade600, Colors.grey.shade100);
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow(this.label, this.value, {this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isBold ? 14 : 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
                color: isBold ? const Color(0xFF212121) : Colors.grey.shade600)),
        Text(value,
            style: TextStyle(
                fontSize: isBold ? 16 : 13,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: valueColor ?? const Color(0xFF212121))),
      ],
    );
  }
}

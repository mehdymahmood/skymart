import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../presentation/controllers/cart_controller.dart';
import '../../../data/models/cart_item_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController _cartController = Get.find<CartController>();
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              'Cart (${_cartController.totalItems})',
            )),
        automaticallyImplyLeading: false,
        actions: [
          Obx(() => _cartController.isEmpty
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: _confirmClearCart,
                  child: const Text('Clear', style: TextStyle(color: Colors.white)),
                )),
        ],
      ),
      body: Obx(() {
        if (_cartController.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.shopping_cart_outlined,
            title: 'Your Cart is Empty',
            subtitle: 'Looks like you haven\'t added anything to your cart yet.',
            buttonText: 'Start Shopping',
            onButtonTap: () => Get.offAllNamed(AppRoutes.main),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  ..._cartController.cartItems.map((item) => _CartItemTile(item: item)),
                  const SizedBox(height: 8),
                  _buildPromoCodeSection(),
                  const SizedBox(height: 8),
                  _buildOrderSummary(context),
                ],
              ),
            ),
            _buildCheckoutBar(context),
          ],
        );
      }),
    );
  }

  Widget _buildPromoCodeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              Icon(Icons.local_offer_outlined, color: AppTheme.accentColor, size: 20),
              SizedBox(width: 8),
              Text('Promo Code', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (_cartController.promoSuccess.value.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.successColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _cartController.promoSuccess.value,
                        style: const TextStyle(color: AppTheme.successColor, fontSize: 13),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _cartController.removePromoCode();
                        _promoController.clear();
                      },
                      child: const Icon(Icons.close, color: AppTheme.successColor, size: 18),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter promo code (e.g., SKYMART10)',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Obx(() => ElevatedButton(
                          onPressed: _cartController.isApplyingPromo.value
                              ? null
                              : () => _cartController.applyPromoCode(_promoController.text.trim()),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _cartController.isApplyingPromo.value
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Apply'),
                        )),
                  ],
                ),
                if (_cartController.promoError.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _cartController.promoError.value,
                      style: const TextStyle(color: AppTheme.errorColor, fontSize: 12),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 14),
          Obx(() => Column(
                children: [
                  _SummaryRow(
                    label: 'Subtotal (${_cartController.totalItems} items)',
                    value: AppUtils.formatPrice(_cartController.subtotal),
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Shipping Fee',
                    value: _cartController.effectiveShippingFee == 0
                        ? 'FREE'
                        : AppUtils.formatPrice(_cartController.effectiveShippingFee),
                    valueColor: _cartController.effectiveShippingFee == 0
                        ? AppTheme.successColor
                        : null,
                  ),
                  if (_cartController.promoDiscount.value > 0) ...[
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Promo Discount (${_cartController.promoCode.value})',
                      value: '-${AppUtils.formatPrice(_cartController.promoDiscount.value)}',
                      valueColor: AppTheme.successColor,
                    ),
                  ],
                  if (_cartController.subtotal < CartController.freeShippingThreshold) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.infoColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_shipping_outlined, size: 14, color: AppTheme.infoColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Add ৳${AppUtils.formatPrice(CartController.freeShippingThreshold - _cartController.subtotal)} more for free shipping!',
                              style: const TextStyle(
                                  color: AppTheme.infoColor, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  _SummaryRow(
                    label: 'Total',
                    value: AppUtils.formatPrice(_cartController.total),
                    isBold: true,
                    valueColor: AppTheme.primaryColor,
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Obx(() => Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  Text(
                    AppUtils.formatPrice(_cartController.total),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.checkout),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Proceed to Checkout'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  void _confirmClearCart() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _cartController.clearCart();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorColor,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white),
            Text('Remove', style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
      onDismissed: (_) => cartController.removeFromCart(item.id),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: item.product.images.isNotEmpty ? item.product.images[0] : '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  // Variant info
                  if (item.selectedSize != null || item.selectedColor != null)
                    Text(
                      [
                        if (item.selectedSize != null) 'Size: ${item.selectedSize}',
                        if (item.selectedColor != null) 'Color: ${item.selectedColor}',
                      ].join(' | '),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    AppUtils.formatPrice(item.product.price),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantity controls
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onTap: () => cartController.updateQuantity(item.id, item.quantity - 1),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          item.quantity.toString(),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onTap: () => cartController.updateQuantity(item.id, item.quantity + 1),
                      ),
                      const Spacer(),
                      Text(
                        AppUtils.formatPrice(item.totalPrice),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF424242),
                        ),
                      ),
                    ],
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

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: Icon(icon, size: 16, color: AppTheme.primaryColor),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            color: isBold ? const Color(0xFF212121) : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? (isBold ? AppTheme.primaryColor : const Color(0xFF212121)),
          ),
        ),
      ],
    );
  }
}

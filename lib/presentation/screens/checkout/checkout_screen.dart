import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/models/user_model.dart';
import '../../../presentation/controllers/order_controller.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../presentation/controllers/cart_controller.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderController _orderController = Get.find<OrderController>();
  final AuthController _authController = Get.find<AuthController>();
  final CartController _cartController = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    // Set default address
    final user = _authController.currentUser.value;
    if (user != null && user.addresses.isNotEmpty) {
      AddressModel? defaultAddr;
      try {
        defaultAddr = user.addresses.firstWhere((a) => a.isDefault);
      } catch (_) {
        defaultAddr = user.addresses.first;
      }
      _orderController.setAddress(defaultAddr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeliveryAddress(context),
            const SizedBox(height: 16),
            _buildPaymentMethod(),
            const SizedBox(height: 16),
            _buildOrderItems(),
            const SizedBox(height: 16),
            _buildOrderSummary(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildPlaceOrderBar(context),
    );
  }

  Widget _buildDeliveryAddress(BuildContext context) {
    final user = _authController.currentUser.value;
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
            children: [
              const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Delivery Address',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              if (user != null && user.addresses.isNotEmpty)
                TextButton(
                  onPressed: () => _showAddressSelection(context, user.addresses),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text('Change'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final address = _orderController.selectedAddress.value;
            if (address == null) {
              return GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.addresses),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppTheme.primaryColor, style: BorderStyle.solid, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: AppTheme.primaryColor),
                      SizedBox(width: 8),
                      Text('Add Delivery Address',
                          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          address.label,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(address.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(address.phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(address.fullAddress,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    final methods = [
      (AppConstants.paymentCOD, Icons.payments_outlined, 'Pay at doorstep'),
      (AppConstants.paymentCard, Icons.credit_card, 'Visa, Mastercard, AMEX'),
      (AppConstants.paymentBkash, Icons.account_balance_wallet_outlined, 'bKash Mobile Banking'),
      (AppConstants.paymentNagad, Icons.mobile_friendly, 'Nagad Mobile Banking'),
      (AppConstants.paymentRocket, Icons.rocket_launch_outlined, 'DBBL Rocket'),
    ];

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
              Icon(Icons.payment_outlined, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Column(
                children: methods.map((method) {
                  final isSelected = _orderController.selectedPaymentMethod.value == method.$1;
                  return GestureDetector(
                    onTap: () => _orderController.setPaymentMethod(method.$1),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.05) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: method.$1,
                            groupValue: _orderController.selectedPaymentMethod.value,
                            onChanged: (v) => _orderController.setPaymentMethod(v!),
                            activeColor: AppTheme.primaryColor,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(width: 6),
                          Icon(method.$2, size: 22, color: isSelected ? AppTheme.primaryColor : Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(method.$1,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      fontSize: 14,
                                      color: isSelected ? AppTheme.primaryColor : const Color(0xFF424242),
                                    )),
                                Text(method.$3,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
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
            children: [
              const Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Order Items (${_cartController.totalItems})',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Column(
                children: _cartController.cartItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'x${item.quantity}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            AppUtils.formatPrice(item.totalPrice),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                    )).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Obx(() => Column(
            children: [
              _Row('Subtotal', AppUtils.formatPrice(_cartController.subtotal)),
              const SizedBox(height: 8),
              _Row(
                'Shipping',
                _cartController.effectiveShippingFee == 0
                    ? 'FREE'
                    : AppUtils.formatPrice(_cartController.effectiveShippingFee),
                valueColor: _cartController.effectiveShippingFee == 0 ? AppTheme.successColor : null,
              ),
              if (_cartController.promoDiscount.value > 0) ...[
                const SizedBox(height: 8),
                _Row('Promo Discount', '-${AppUtils.formatPrice(_cartController.promoDiscount.value)}',
                    valueColor: AppTheme.successColor),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1),
              ),
              _Row(
                'Total Amount',
                AppUtils.formatPrice(_cartController.total),
                isBold: true,
                valueColor: AppTheme.primaryColor,
              ),
            ],
          )),
    );
  }

  Widget _buildPlaceOrderBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: Obx(() => PrimaryButton(
            text: 'Place Order - ${AppUtils.formatPrice(_cartController.total)}',
            isLoading: _orderController.isPlacingOrder.value,
            onTap: _orderController.placeOrder,
            icon: Icons.shopping_bag_outlined,
          )),
    );
  }

  void _showAddressSelection(BuildContext context, List<AddressModel> addresses) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Select Delivery Address',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          const Divider(height: 1),
          ...addresses.map((addr) => Obx(() {
                final isSelected = _orderController.selectedAddress.value?.id == addr.id;
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_on_outlined,
                        color: isSelected ? AppTheme.primaryColor : Colors.grey, size: 20),
                  ),
                  title: Text(addr.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(addr.fullAddress, style: const TextStyle(fontSize: 12)),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    _orderController.setAddress(addr);
                    Get.back();
                  },
                );
              })),
          ListTile(
            leading: const Icon(Icons.add_location_alt_outlined, color: AppTheme.primaryColor),
            title: const Text('Add New Address',
                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
            onTap: () {
              Get.back();
              Get.toNamed(AppRoutes.addresses);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _Row(this.label, this.value, {this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: isBold ? const Color(0xFF212121) : Colors.grey.shade600,
            )),
        Text(value,
            style: TextStyle(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? const Color(0xFF212121),
            )),
      ],
    );
  }
}

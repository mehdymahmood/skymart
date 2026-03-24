import 'package:get/get.dart';
import '../../data/models/order_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/providers/mock_data_provider.dart';
import '../../app/routes/app_routes.dart';
import 'cart_controller.dart';

class OrderController extends GetxController {
  final MockDataProvider _mockData = MockDataProvider();
  final CartController _cartController = Get.find<CartController>();

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<OrderModel?> selectedOrder = Rx<OrderModel?>(null);
  final RxInt orderTabIndex = 0.obs;

  // Checkout state
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);
  final RxString selectedPaymentMethod = 'Cash on Delivery'.obs;
  final RxBool isPlacingOrder = false.obs;
  final RxString lastOrderNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    orders.value = _mockData.getMockOrders();
    isLoading.value = false;
  }

  List<OrderModel> get activeOrders =>
      orders.where((o) => o.isActive).toList();

  List<OrderModel> get completedOrders =>
      orders.where((o) => o.isCompleted).toList();

  List<OrderModel> get cancelledOrders =>
      orders.where((o) => o.isCancelled).toList();

  void loadOrderDetail(String orderId) {
    final order = orders.firstWhereOrNull((o) => o.id == orderId);
    selectedOrder.value = order;
  }

  void setAddress(AddressModel address) {
    selectedAddress.value = address;
  }

  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  Future<void> placeOrder() async {
    if (selectedAddress.value == null) {
      Get.snackbar('Error', 'Please select a delivery address',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isPlacingOrder.value = true;
    await Future.delayed(const Duration(seconds: 2));

    final orderNumber = 'SKY-2026-${(orders.length + 1000 + 1).toString().padLeft(6, '0')}';

    final newOrder = OrderModel(
      id: 'ord_new_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: orderNumber,
      items: List<CartItemModel>.from(_cartController.cartItems),
      deliveryAddress: selectedAddress.value!,
      paymentMethod: selectedPaymentMethod.value,
      subtotal: _cartController.subtotal,
      shippingFee: _cartController.effectiveShippingFee,
      discount: _cartController.promoDiscount.value,
      total: _cartController.total,
      status: 'Placed',
      placedAt: DateTime.now(),
      promoCode: _cartController.promoCode.value.isNotEmpty
          ? _cartController.promoCode.value
          : null,
    );

    orders.insert(0, newOrder);
    lastOrderNumber.value = orderNumber;

    _cartController.clearCart();
    isPlacingOrder.value = false;

    selectedAddress.value = null;
    selectedPaymentMethod.value = 'Cash on Delivery';

    Get.offAllNamed(AppRoutes.orderSuccess);
  }

  void setOrderTab(int index) {
    orderTabIndex.value = index;
  }

  Future<void> cancelOrder(String orderId) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index < 0) return;

    final order = orders[index];
    if (!order.isActive) return;

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    orders[index] = OrderModel(
      id: order.id,
      orderNumber: order.orderNumber,
      items: order.items,
      deliveryAddress: order.deliveryAddress,
      paymentMethod: order.paymentMethod,
      subtotal: order.subtotal,
      shippingFee: order.shippingFee,
      discount: order.discount,
      total: order.total,
      status: 'Cancelled',
      placedAt: order.placedAt,
      cancelledAt: DateTime.now(),
    );

    isLoading.value = false;
    Get.snackbar('Order Cancelled', 'Your order has been cancelled',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> refresh() async {
    await loadOrders();
  }
}

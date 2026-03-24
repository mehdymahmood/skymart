import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/providers/mock_data_provider.dart';

class CartController extends GetxController {
  final MockDataProvider _mockData = MockDataProvider();

  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxString promoCode = ''.obs;
  final RxDouble promoDiscount = 0.0.obs;
  final RxBool isApplyingPromo = false.obs;
  final RxString promoError = ''.obs;
  final RxString promoSuccess = ''.obs;

  static const double shippingFee = 100.0;
  static const double freeShippingThreshold = 2000.0;

  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(AppConstants.keyCartItems);
      if (cartJson != null) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        cartItems.value = decoded.map((e) => CartItemModel.fromJson(e)).toList();
      }
    } catch (_) {}
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(cartItems.map((e) => e.toJson()).toList());
      await prefs.setString(AppConstants.keyCartItems, cartJson);
    } catch (_) {}
  }

  void addToCart(ProductModel product, {int qty = 1, String? size, String? color}) {
    final existingIndex = cartItems.indexWhere(
      (item) => item.product.id == product.id && item.selectedSize == size && item.selectedColor == color,
    );

    if (existingIndex >= 0) {
      final existing = cartItems[existingIndex];
      final newQty = existing.quantity + qty;
      if (newQty <= product.stock) {
        cartItems[existingIndex] = existing.copyWith(quantity: newQty);
      } else {
        Get.snackbar('Stock Limit', 'Only ${product.stock} items available',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
    } else {
      cartItems.add(CartItemModel(
        id: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        quantity: qty,
        selectedSize: size,
        selectedColor: color,
      ));
    }

    _saveCart();
    Get.snackbar(
      'Added to Cart',
      '${product.name} has been added to your cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void removeFromCart(String cartItemId) {
    cartItems.removeWhere((item) => item.id == cartItemId);
    _saveCart();
  }

  void updateQuantity(String cartItemId, int newQty) {
    final index = cartItems.indexWhere((item) => item.id == cartItemId);
    if (index < 0) return;

    if (newQty <= 0) {
      removeFromCart(cartItemId);
      return;
    }

    final item = cartItems[index];
    if (newQty > item.product.stock) {
      Get.snackbar('Stock Limit', 'Only ${item.product.stock} items available',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    cartItems[index] = item.copyWith(quantity: newQty);
    _saveCart();
  }

  void clearCart() {
    cartItems.clear();
    promoCode.value = '';
    promoDiscount.value = 0;
    promoError.value = '';
    promoSuccess.value = '';
    _saveCart();
  }

  Future<void> applyPromoCode(String code) async {
    if (code.isEmpty) {
      promoError.value = 'Please enter a promo code';
      return;
    }

    isApplyingPromo.value = true;
    promoError.value = '';
    promoSuccess.value = '';

    await Future.delayed(const Duration(milliseconds: 800));

    final discount = _mockData.validatePromoCode(code, subtotal);
    if (discount != null) {
      promoCode.value = code.toUpperCase();
      promoDiscount.value = discount;
      promoSuccess.value = 'Promo code applied! You saved ৳${discount.toStringAsFixed(2)}';
    } else {
      promoError.value = 'Invalid promo code';
      promoDiscount.value = 0;
    }

    isApplyingPromo.value = false;
  }

  void removePromoCode() {
    promoCode.value = '';
    promoDiscount.value = 0;
    promoError.value = '';
    promoSuccess.value = '';
  }

  bool isInCart(String productId) {
    return cartItems.any((item) => item.product.id == productId);
  }

  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get effectiveShippingFee {
    return subtotal >= freeShippingThreshold ? 0 : shippingFee;
  }

  double get total {
    return subtotal + effectiveShippingFee - promoDiscount.value;
  }

  int get totalItems {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isEmpty => cartItems.isEmpty;
}

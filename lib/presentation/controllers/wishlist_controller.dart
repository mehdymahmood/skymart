import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/product_model.dart';

class WishlistController extends GetxController {
  final RxList<ProductModel> wishlistItems = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString(AppConstants.keyWishlistItems);
      if (wishlistJson != null) {
        final List<dynamic> decoded = jsonDecode(wishlistJson);
        wishlistItems.value = decoded.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (_) {}
  }

  Future<void> _saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = jsonEncode(wishlistItems.map((e) => e.toJson()).toList());
      await prefs.setString(AppConstants.keyWishlistItems, wishlistJson);
    } catch (_) {}
  }

  void toggleWishlist(ProductModel product) {
    if (isInWishlist(product.id)) {
      removeFromWishlist(product.id);
    } else {
      addToWishlist(product);
    }
  }

  void addToWishlist(ProductModel product) {
    if (!isInWishlist(product.id)) {
      wishlistItems.add(product);
      _saveWishlist();
      Get.snackbar(
        'Wishlist',
        '${product.name} added to wishlist',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void removeFromWishlist(String productId) {
    wishlistItems.removeWhere((p) => p.id == productId);
    _saveWishlist();
    Get.snackbar(
      'Wishlist',
      'Product removed from wishlist',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  bool isInWishlist(String productId) {
    return wishlistItems.any((p) => p.id == productId);
  }

  void clearWishlist() {
    wishlistItems.clear();
    _saveWishlist();
  }

  int get count => wishlistItems.length;
}

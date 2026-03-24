import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/product_model.dart';
import '../../data/providers/mock_data_provider.dart';

class SellController extends GetxController {
  final RxList<ProductModel> myProducts = <ProductModel>[].obs;
  final RxBool isSubmitting = false.obs;

  static const _storageKey = 'my_posted_products';

  @override
  void onInit() {
    super.onInit();
    _loadMyProducts();
  }

  Future<void> _loadMyProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_storageKey);
      if (json != null) {
        final List decoded = jsonDecode(json);
        myProducts.value = decoded.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (_) {}
  }

  Future<void> _saveMyProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(myProducts.map((p) => p.toJson()).toList()));
    } catch (_) {}
  }

  Future<bool> postProduct({
    required String name,
    required String description,
    required double price,
    double? originalPrice,
    required String categoryId,
    required String categoryName,
    required int stock,
    required String brand,
    required List<String> images,
    List<String> sizes = const [],
    List<String> colors = const [],
  }) async {
    isSubmitting.value = true;
    await Future.delayed(const Duration(seconds: 1));

    final product = ProductModel(
      id: 'user_prod_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      price: price,
      originalPrice: originalPrice,
      categoryId: categoryId,
      categoryName: categoryName,
      stock: stock,
      brand: brand,
      images: images.isNotEmpty
          ? images
          : ['https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/400'],
      sizes: sizes,
      colors: colors,
      rating: 0,
      reviewCount: 0,
      soldCount: 0,
      isFeatured: false,
      isFlashSale: false,
      isPopular: false,
    );

    myProducts.insert(0, product);

    // Also add to the global mock data so it appears in listings
    MockDataProvider().addUserProduct(product);

    await _saveMyProducts();
    isSubmitting.value = false;
    return true;
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    double? originalPrice,
    required String categoryId,
    required String categoryName,
    required int stock,
    required String brand,
    required List<String> images,
    List<String> sizes = const [],
    List<String> colors = const [],
  }) async {
    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    final index = myProducts.indexWhere((p) => p.id == id);
    if (index == -1) {
      isSubmitting.value = false;
      return;
    }

    final existing = myProducts[index];
    final updated = existing.copyWith(
      name: name,
      description: description,
      price: price,
      originalPrice: originalPrice,
      categoryId: categoryId,
      categoryName: categoryName,
      stock: stock,
      brand: brand,
      images: images.isNotEmpty
          ? images
          : ['https://picsum.photos/seed/${id}/400/400'],
      sizes: sizes,
      colors: colors,
    );

    myProducts[index] = updated;
    MockDataProvider().addUserProduct(updated); // addUserProduct does remove+insert

    await _saveMyProducts();
    isSubmitting.value = false;
  }

  Future<void> deleteProduct(String productId) async {
    myProducts.removeWhere((p) => p.id == productId);
    MockDataProvider().removeUserProduct(productId);
    await _saveMyProducts();
  }
}

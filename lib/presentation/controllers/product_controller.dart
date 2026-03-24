import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../data/models/review_model.dart';
import '../../data/providers/mock_data_provider.dart';

class ProductController extends GetxController {
  final MockDataProvider _mockData = MockDataProvider();

  // Product list state
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString currentCategoryId = ''.obs;
  final RxString sortBy = 'default'.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 999999.0.obs;
  final RxDouble selectedMinPrice = 0.0.obs;
  final RxDouble selectedMaxPrice = 999999.0.obs;
  final RxBool showFilterPanel = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = false.obs;

  // Product detail state
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);
  final RxInt selectedImageIndex = 0.obs;
  final RxString selectedSize = ''.obs;
  final RxString selectedColor = ''.obs;
  final RxInt quantity = 1.obs;
  final RxInt detailTabIndex = 0.obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isDetailLoading = true.obs;
  final RxList<ProductModel> relatedProducts = <ProductModel>[].obs;

  // Recently viewed
  final RxList<ProductModel> recentlyViewed = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts({String? categoryId, bool refresh = false}) async {
    if (refresh) currentPage.value = 1;
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    final allProducts = _mockData.getProducts();

    if (categoryId != null && categoryId.isNotEmpty) {
      if (categoryId == 'flash') {
        products.value = allProducts.where((p) => p.isFlashSale).toList();
      } else if (categoryId == 'featured') {
        products.value = allProducts.where((p) => p.isFeatured).toList();
      } else if (categoryId == 'popular') {
        products.value = allProducts.where((p) => p.isPopular).toList();
      } else {
        products.value = allProducts.where((p) => p.categoryId == categoryId).toList();
      }
      currentCategoryId.value = categoryId;
    } else {
      products.value = allProducts;
    }

    _applyFilters();
    isLoading.value = false;
  }

  void _applyFilters() {
    var filtered = products.toList();

    // Price filter
    filtered = filtered.where((p) =>
        p.price >= selectedMinPrice.value && p.price <= selectedMaxPrice.value
    ).toList();

    // Sort
    switch (sortBy.value) {
      case 'price_asc':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'popular':
        filtered.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      case 'newest':
        // No date in model, keep as is for mock
        break;
      default:
        break;
    }

    filteredProducts.value = filtered;
  }

  void setSortBy(String sort) {
    sortBy.value = sort;
    _applyFilters();
  }

  void setPriceRange(double min, double max) {
    selectedMinPrice.value = min;
    selectedMaxPrice.value = max;
    _applyFilters();
  }

  void resetFilters() {
    sortBy.value = 'default';
    selectedMinPrice.value = 0;
    selectedMaxPrice.value = 999999;
    _applyFilters();
  }

  Future<void> loadProductDetail(String productId) async {
    isDetailLoading.value = true;
    selectedImageIndex.value = 0;
    selectedSize.value = '';
    selectedColor.value = '';
    quantity.value = 1;
    detailTabIndex.value = 0;

    await Future.delayed(const Duration(milliseconds: 500));

    final allProducts = _mockData.getProducts();
    final product = allProducts.firstWhereOrNull((p) => p.id == productId);

    if (product != null) {
      selectedProduct.value = product;
      if (product.sizes.isNotEmpty) selectedSize.value = product.sizes.first;
      if (product.colors.isNotEmpty) selectedColor.value = product.colors.first;
      reviews.value = _mockData.getReviews(productId);

      // Load related products (same category, exclude current)
      relatedProducts.value = allProducts
          .where((p) => p.categoryId == product.categoryId && p.id != productId)
          .take(6)
          .toList();

      // Track recently viewed (keep last 10, no duplicates)
      recentlyViewed.removeWhere((p) => p.id == productId);
      recentlyViewed.insert(0, product);
      if (recentlyViewed.length > 10) recentlyViewed.removeLast();
    }

    isDetailLoading.value = false;
  }

  void selectImage(int index) => selectedImageIndex.value = index;
  void selectSize(String size) => selectedSize.value = size;
  void selectColor(String color) => selectedColor.value = color;
  void setDetailTab(int index) => detailTabIndex.value = index;

  void incrementQuantity() {
    final product = selectedProduct.value;
    if (product == null) return;
    if (quantity.value < product.stock) {
      quantity.value++;
    }
  }

  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  Future<void> refresh() async {
    await loadProducts(categoryId: currentCategoryId.value.isEmpty ? null : currentCategoryId.value, refresh: true);
  }

  Future<void> submitReview({
    required String userName,
    required double rating,
    required String comment,
  }) async {
    final product = selectedProduct.value;
    if (product == null) return;

    await Future.delayed(const Duration(milliseconds: 600));

    final newReview = ReviewModel(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      productId: product.id,
      userId: 'current_user',
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    reviews.insert(0, newReview);
    Get.snackbar(
      'Review Submitted',
      'Thank you for your feedback!',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

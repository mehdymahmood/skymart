import 'dart:async';
import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/banner_model.dart';
import '../../data/providers/mock_data_provider.dart';
import '../controllers/product_controller.dart';

class HomeController extends GetxController {
  final MockDataProvider _mockData = MockDataProvider();

  final RxBool isLoading = true.obs;
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> flashSaleProducts = <ProductModel>[].obs;
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  final RxList<ProductModel> popularProducts = <ProductModel>[].obs;
  final RxInt currentBannerIndex = 0.obs;

  // Flash sale countdown
  final Rx<Duration> flashSaleCountdown = const Duration(hours: 8).obs;
  Timer? _countdownTimer;
  Timer? _endTimer;

  // Flash sale end time
  late DateTime _flashSaleEndTime;

  @override
  void onInit() {
    super.onInit();
    _flashSaleEndTime = DateTime.now().add(const Duration(hours: 8));
    loadData();
    _startFlashSaleCountdown();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _endTimer?.cancel();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    banners.value = _mockData.getBanners();
    categories.value = _mockData.getCategories();

    final allProducts = _mockData.getProducts();
    flashSaleProducts.value = allProducts.where((p) => p.isFlashSale).toList();
    featuredProducts.value = allProducts.where((p) => p.isFeatured).toList();
    popularProducts.value = allProducts.where((p) => p.isPopular).toList();

    isLoading.value = false;
  }

  Future<void> refresh() async {
    await loadData();
  }

  void _startFlashSaleCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = _flashSaleEndTime.difference(DateTime.now());
      if (remaining.isNegative) {
        flashSaleCountdown.value = Duration.zero;
        timer.cancel();
        // Reset flash sale for demo
        _flashSaleEndTime = DateTime.now().add(const Duration(hours: 8));
        _startFlashSaleCountdown();
      } else {
        flashSaleCountdown.value = remaining;
      }
    });
  }

  void updateBannerIndex(int index) {
    currentBannerIndex.value = index;
  }

  List<ProductModel> get recentlyViewed {
    try {
      final productController = Get.find<ProductController>();
      return productController.recentlyViewed.toList();
    } catch (_) {
      return [];
    }
  }
}

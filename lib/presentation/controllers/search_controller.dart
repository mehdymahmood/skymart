import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/product_model.dart';
import '../../data/providers/mock_data_provider.dart';
import '../../core/constants/app_constants.dart';

class SearchController extends GetxController {
  final MockDataProvider _mockData = MockDataProvider();

  final RxList<ProductModel> searchResults = <ProductModel>[].obs;
  final RxList<String> recentSearches = <String>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool hasSearched = false.obs;
  final RxString currentQuery = ''.obs;

  Timer? _debounceTimer;
  static const int maxRecentSearches = 10;

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    recentSearches.value = prefs.getStringList('recent_searches') ?? [];
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', recentSearches.toList());
  }

  void onSearchChanged(String query) {
    currentQuery.value = query;
    if (query.isEmpty) {
      searchResults.clear();
      hasSearched.value = false;
      isSearching.value = false;
      _debounceTimer?.cancel();
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.searchDebounce, () {
      search(query);
    });
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    isSearching.value = true;
    currentQuery.value = query;

    await Future.delayed(const Duration(milliseconds: 400));

    final allProducts = _mockData.getProducts();
    final lower = query.toLowerCase();
    searchResults.value = allProducts.where((p) {
      return p.name.toLowerCase().contains(lower) ||
          p.categoryName.toLowerCase().contains(lower) ||
          p.brand.toLowerCase().contains(lower) ||
          p.tags.any((t) => t.toLowerCase().contains(lower)) ||
          p.description.toLowerCase().contains(lower);
    }).toList();

    isSearching.value = false;
    hasSearched.value = true;

    // Add to recent searches
    _addToRecentSearches(query);
  }

  void _addToRecentSearches(String query) {
    recentSearches.remove(query);
    recentSearches.insert(0, query);
    if (recentSearches.length > maxRecentSearches) {
      recentSearches.removeRange(maxRecentSearches, recentSearches.length);
    }
    _saveRecentSearches();
  }

  void removeRecentSearch(String query) {
    recentSearches.remove(query);
    _saveRecentSearches();
  }

  void clearRecentSearches() {
    recentSearches.clear();
    _saveRecentSearches();
  }

  void clearSearch() {
    searchResults.clear();
    hasSearched.value = false;
    isSearching.value = false;
    currentQuery.value = '';
  }
}

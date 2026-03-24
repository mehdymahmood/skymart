import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../presentation/controllers/search_controller.dart' as sc;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late sc.SearchController _searchController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = Get.put(sc.SearchController());
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        automaticallyImplyLeading: false,
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            autofocus: false,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search products, brands...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              suffixIcon: Obx(() => _searchController.currentQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 20),
                      onPressed: () {
                        _textController.clear();
                        _searchController.clearSearch();
                      },
                    )
                  : const SizedBox.shrink()),
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
            ),
            onChanged: _searchController.onSearchChanged,
            onSubmitted: _searchController.search,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _textController.clear();
              _searchController.clearSearch();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Obx(() {
        // Searching state
        if (_searchController.isSearching.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        // Has searched but no results
        if (_searchController.hasSearched.value && _searchController.searchResults.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.search_off,
            title: 'No Results Found',
            subtitle: 'Try different keywords or check your spelling',
            buttonText: 'Clear Search',
            onButtonTap: () {
              _textController.clear();
              _searchController.clearSearch();
            },
          );
        }

        // Has search results
        if (_searchController.searchResults.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Text(
                  '${_searchController.searchResults.length} results for "${_searchController.currentQuery.value}"',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: _searchController.searchResults.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: _searchController.searchResults[index]);
                  },
                ),
              ),
            ],
          );
        }

        // Show recent searches and suggestions
        return _buildInitialState(context);
      }),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          Obx(() {
            if (_searchController.recentSearches.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Searches',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      TextButton(
                        onPressed: _searchController.clearRecentSearches,
                        child: const Text('Clear All', style: TextStyle(color: AppTheme.primaryColor)),
                      ),
                    ],
                  ),
                ),
                ..._searchController.recentSearches.map((query) => ListTile(
                      leading: const Icon(Icons.history, size: 20, color: Colors.grey),
                      title: Text(query, style: const TextStyle(fontSize: 14)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                        onPressed: () => _searchController.removeRecentSearch(query),
                      ),
                      onTap: () {
                        _textController.text = query;
                        _searchController.search(query);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    )),
              ],
            );
          }),
          // Popular searches
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text('Popular Searches',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Samsung Galaxy',
                'iPhone',
                'Laptop',
                'Dress',
                'Sneakers',
                'Headphones',
                'Smart TV',
                'Yoga Mat',
                'Books',
              ].map((term) => GestureDetector(
                    onTap: () {
                      _textController.text = term;
                      _searchController.search(term);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up, size: 14, color: AppTheme.primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            term,
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/section_header.dart';
import '../../../presentation/controllers/home_controller.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../presentation/controllers/notification_controller.dart';
import '../../../presentation/controllers/product_controller.dart';
import '../../../data/models/category_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeController _homeController;

  @override
  void initState() {
    super.initState();
    _homeController = Get.put(HomeController());
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final notifController = Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: _buildAppBar(context, authController, notifController),
      body: RefreshIndicator(
        onRefresh: _homeController.refresh,
        color: AppTheme.primaryColor,
        child: Obx(() {
          if (_homeController.isLoading.value) {
            return _buildShimmerLoading();
          }
          return _buildContent(context);
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AuthController authController,
    NotificationController notifController,
  ) {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Text('🛒', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppConstants.appName,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              Obx(() => Text(
                    'Hi, ${authController.currentUser.value?.name.split(' ').first ?? 'User'}! 👋',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                  )),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.notifications),
          icon: Obx(() => Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.white),
                  if (notifController.unreadCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            notifController.unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                ],
              )),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: AppTheme.primaryColor,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.search),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade400, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Search for products, brands...',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const BannerShimmer(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (i) => const CategoryShimmer()),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.7,
              children: List.generate(4, (i) => const ProductCardShimmer()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildBannerCarousel(),
          const SizedBox(height: 20),
          _buildCategoryGrid(context),
          const SizedBox(height: 20),
          _buildFlashSaleSection(context),
          const SizedBox(height: 20),
          _buildFeaturedProducts(context),
          const SizedBox(height: 20),
          _buildPopularProducts(context),
          const SizedBox(height: 20),
          _buildRecentlyViewed(context),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Obx(() {
      if (_homeController.banners.isEmpty) return const SizedBox.shrink();
      final pageController = PageController(viewportFraction: 0.92);
      return Column(
        children: [
          SizedBox(
            height: 184,
            child: PageView.builder(
              controller: pageController,
              itemCount: _homeController.banners.length,
              onPageChanged: _homeController.updateBannerIndex,
              itemBuilder: (context, index) {
                final banner = _homeController.banners[index];
                return GestureDetector(
                  onTap: () {
                    if (banner.actionRoute != null) {
                      Get.toNamed(banner.actionRoute!, arguments: banner.actionParam);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: banner.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: AppTheme.shimmerBase,
                              highlightColor: AppTheme.shimmerHighlight,
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: (context, url, error) =>
                                Container(color: AppTheme.primaryColor),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  Colors.black.withOpacity(0.05),
                                  Colors.black.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            bottom: 16,
                            right: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  banner.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  banner.subtitle,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    banner.buttonText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _homeController.banners.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _homeController.currentBannerIndex.value == index ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _homeController.currentBannerIndex.value == index
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              )),
        ],
      );
    });
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return Obx(() {
      if (_homeController.categories.isEmpty) return const SizedBox.shrink();
      final displayCategories = _homeController.categories.take(8).toList();
      return Column(
        children: [
          SectionHeader(
            title: 'Shop by Category',
            actionText: 'View All',
            onActionTap: () => Get.toNamed(AppRoutes.categories),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: displayCategories.length,
              itemBuilder: (context, index) {
                final category = displayCategories[index];
                return _buildCategoryItem(category);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCategoryItem(CategoryModel category) {
    final color = _parseColor(category.color);
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.productList, arguments: {'categoryId': category.id, 'title': category.name}),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2), width: 1.5),
              ),
              child: Center(
                child: Text(category.icon, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return AppTheme.primaryColor;
    }
  }

  Widget _buildRecentlyViewed(BuildContext context) {
    try {
      final productController = Get.find<ProductController>();
      return Obx(() {
        if (productController.recentlyViewed.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            SectionHeader(
              title: 'Recently Viewed',
              actionText: 'See All',
              onActionTap: () => Get.toNamed(AppRoutes.productList, arguments: {'categoryId': '', 'title': 'Recently Viewed'}),
            ),
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: productController.recentlyViewed.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ProductCard(
                      product: productController.recentlyViewed[index],
                      width: 160,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      });
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildFlashSaleSection(BuildContext context) {
    return Obx(() {
      if (_homeController.flashSaleProducts.isEmpty) return const SizedBox.shrink();
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.flash_on, color: Colors.red, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Flash Sale',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                // Countdown timer
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppUtils.formatCountdown(_homeController.flashSaleCountdown.value),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          letterSpacing: 1.5,
                        ),
                      ),
                    )),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.productList, arguments: {'categoryId': 'flash', 'title': 'Flash Sale'}),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('See All', style: TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
                      Icon(Icons.chevron_right, size: 18, color: AppTheme.primaryColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _homeController.flashSaleProducts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ProductCard(
                    product: _homeController.flashSaleProducts[index],
                    width: 160,
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFeaturedProducts(BuildContext context) {
    return Obx(() {
      if (_homeController.featuredProducts.isEmpty) return const SizedBox.shrink();
      return Column(
        children: [
          SectionHeader(
            title: 'Featured Products',
            actionText: 'See All',
            onActionTap: () => Get.toNamed(AppRoutes.productList, arguments: {'categoryId': 'featured', 'title': 'Featured Products'}),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: _homeController.featuredProducts.length.clamp(0, 6),
              itemBuilder: (context, index) {
                return ProductCard(product: _homeController.featuredProducts[index]);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPopularProducts(BuildContext context) {
    return Obx(() {
      if (_homeController.popularProducts.isEmpty) return const SizedBox.shrink();
      return Column(
        children: [
          SectionHeader(
            title: 'Popular Products',
            actionText: 'See All',
            onActionTap: () => Get.toNamed(AppRoutes.productList, arguments: {'categoryId': 'popular', 'title': 'Popular Products'}),
          ),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _homeController.popularProducts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ProductCard(
                    product: _homeController.popularProducts[index],
                    width: 160,
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

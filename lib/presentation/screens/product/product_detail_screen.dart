import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:readmore/readmore.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/product_card.dart';
import '../../../presentation/controllers/product_controller.dart';
import '../../../presentation/controllers/cart_controller.dart';
import '../../../presentation/controllers/wishlist_controller.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late ProductController _productController;
  late CartController _cartController;
  late WishlistController _wishlistController;
  late TabController _tabController;
  String _productId = '';

  @override
  void initState() {
    super.initState();
    _productController = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());
    _cartController = Get.find<CartController>();
    _wishlistController = Get.find<WishlistController>();
    _tabController = TabController(length: 2, vsync: this);

    _productId = Get.arguments?.toString() ?? '';
    if (_productId.isNotEmpty) {
      _productController.loadProductDetail(_productId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (_productController.isDetailLoading.value) {
          return _buildShimmer(context);
        }
        final product = _productController.selectedProduct.value;
        if (product == null) {
          return const Center(child: Text('Product not found'));
        }
        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildThumbnailList(),
                      _buildProductInfo(context),
                      _buildVariants(context),
                      _buildQuantitySelector(),
                      _buildTabSection(context),
                      _buildRelatedProducts(context),
                    ],
                  ),
                ),
              ],
            ),
            // Bottom action bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomActionBar(context),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 360,
          color: Colors.grey.shade100,
          child: Shimmer.fromColors(
            baseColor: AppTheme.shimmerBase,
            highlightColor: AppTheme.shimmerHighlight,
            child: Container(color: Colors.white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerBox(width: double.infinity, height: 24),
              SizedBox(height: 12),
              ShimmerBox(width: 200, height: 18),
              SizedBox(height: 16),
              ShimmerBox(width: 120, height: 28),
              SizedBox(height: 24),
              ShimmerBox(width: double.infinity, height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final product = _productController.selectedProduct.value!;
    final pageController = PageController();
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      actions: [
        Obx(() {
          final isWishlisted = _wishlistController.isInWishlist(product.id);
          return IconButton(
            onPressed: () => _wishlistController.toggleWishlist(product),
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : Colors.black87,
            ),
          );
        }),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.share_outlined),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: product.images.isEmpty
            ? Container(
                color: Colors.grey.shade100,
                child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
              )
            : Stack(
                children: [
                  PageView.builder(
                    controller: pageController,
                    itemCount: product.images.length,
                    onPageChanged: _productController.selectImage,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showImageViewer(context, index),
                        child: CachedNetworkImage(
                          imageUrl: product.images[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: AppTheme.shimmerBase,
                            highlightColor: AppTheme.shimmerHighlight,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                  if (product.images.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              product.images.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: _productController.selectedImageIndex.value == index ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _productController.selectedImageIndex.value == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          )),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildThumbnailList() {
    final product = _productController.selectedProduct.value!;
    if (product.images.length <= 1) return const SizedBox.shrink();
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: product.images.length,
            itemBuilder: (context, index) {
              final isSelected = _productController.selectedImageIndex.value == index;
              return GestureDetector(
                onTap: () => _productController.selectImage(index),
                child: Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: CachedNetworkImage(
                      imageUrl: product.images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    final product = _productController.selectedProduct.value!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          if (product.brand.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                product.brand,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          // Name
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          // Rating
          Row(
            children: [
              RatingBarIndicator(
                rating: product.rating,
                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 16,
              ),
              const SizedBox(width: 6),
              Text(
                product.rating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(width: 4),
              Text(
                '(${product.reviewCount} reviews)',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              const SizedBox(width: 16),
              Text(
                '${product.soldCount} sold',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppUtils.formatPrice(product.price),
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              if (product.hasDiscount) ...[
                Text(
                  AppUtils.formatPrice(product.originalPrice!),
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '-${product.discountPercent.round()}%',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          // Stock status
          Row(
            children: [
              Icon(
                product.stock > 10 ? Icons.check_circle : Icons.warning,
                size: 14,
                color: product.stock > 10 ? AppTheme.successColor : AppTheme.warningColor,
              ),
              const SizedBox(width: 4),
              Text(
                product.stock > 10
                    ? 'In Stock'
                    : product.stock > 0
                        ? 'Only ${product.stock} left'
                        : 'Out of Stock',
                style: TextStyle(
                  color: product.stock > 10 ? AppTheme.successColor : AppTheme.warningColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariants(BuildContext context) {
    final product = _productController.selectedProduct.value!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sizes
          if (product.sizes.isNotEmpty) ...[
            const Text('Size', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: product.sizes.map((size) {
                    final isSelected = _productController.selectedSize.value == size;
                    return GestureDetector(
                      onTap: () => _productController.selectSize(size),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          size,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 16),
          ],
          // Colors
          if (product.colors.isNotEmpty) ...[
            const Text('Color', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: product.colors.map((color) {
                    final isSelected = _productController.selectedColor.value == color;
                    return GestureDetector(
                      onTap: () => _productController.selectColor(color),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor.withOpacity(0.08) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              const Icon(Icons.check, size: 14, color: AppTheme.primaryColor),
                            if (isSelected) const SizedBox(width: 4),
                            Text(
                              color,
                              style: TextStyle(
                                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const Spacer(),
          Obx(() => Row(
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onTap: _productController.decrementQuantity,
                    enabled: _productController.quantity.value > 1,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _productController.quantity.value.toString(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _QuantityButton(
                    icon: Icons.add,
                    onTap: _productController.incrementQuantity,
                    enabled: _productController.quantity.value <
                        (_productController.selectedProduct.value?.stock ?? 1),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildTabSection(BuildContext context) {
    final product = _productController.selectedProduct.value!;
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: TabBar(
            controller: _tabController,
            onTap: _productController.setDetailTab,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey.shade500,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            tabs: const [
              Tab(text: 'Description'),
              Tab(text: 'Reviews'),
            ],
          ),
        ),
        Obx(() => IndexedStack(
              index: _productController.detailTabIndex.value,
              children: [
                _buildDescriptionTab(product.description),
                _buildReviewsTab(context),
              ],
            )),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildDescriptionTab(String description) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ReadMoreText(
        description,
        trimLines: 4,
        colorClickableText: AppTheme.primaryColor,
        trimMode: TrimMode.Line,
        trimCollapsedText: ' Read more',
        trimExpandedText: ' Read less',
        style: const TextStyle(height: 1.6, fontSize: 14, color: Color(0xFF424242)),
        moreStyle: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
        lessStyle: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildReviewsTab(BuildContext context) {
    return Obx(() {
      final product = _productController.selectedProduct.value!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating summary
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RatingBarIndicator(
                      rating: product.rating,
                      itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 16,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.reviewCount} reviews',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [5, 4, 3, 2, 1].map((star) {
                      final pct = star == 5 ? 0.6 : star == 4 ? 0.25 : star == 3 ? 0.1 : star == 2 ? 0.03 : 0.02;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text('$star', style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            const Icon(Icons.star, size: 12, color: Colors.amber),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Write review button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: OutlinedButton.icon(
              onPressed: () => _showWriteReviewSheet(context),
              icon: const Icon(Icons.rate_review_outlined, size: 18),
              label: const Text('Write a Review'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          // Reviews list
          if (_productController.reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No reviews yet. Be the first!')),
            )
          else
            ..._productController.reviews.map((review) {
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: review.userAvatar != null
                              ? CachedNetworkImageProvider(review.userAvatar!)
                              : null,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                          child: review.userAvatar == null
                              ? Text(review.userName[0],
                                  style: const TextStyle(color: AppTheme.primaryColor))
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(review.userName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text(
                                AppUtils.timeAgo(review.createdAt),
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        RatingBarIndicator(
                          rating: review.rating,
                          itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(review.comment,
                        style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF424242))),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
        ],
      );
    });
  }

  void _showWriteReviewSheet(BuildContext context) {
    double selectedRating = 5;
    final commentController = TextEditingController();
    final nameController = TextEditingController(
      text: _productController.selectedProduct.value?.name.isNotEmpty == true ? 'You' : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Write a Review',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              const Text('Your Rating', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              RatingBar.builder(
                initialRating: selectedRating,
                minRating: 1,
                itemSize: 36,
                itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (r) => setState(() => selectedRating = r),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Your Review',
                  hintText: 'Share your experience with this product...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (commentController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Please write a review comment',
                        snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  Get.back();
                  await _productController.submitReview(
                    userName: nameController.text.trim().isEmpty ? 'Anonymous' : nameController.text.trim(),
                    rating: selectedRating,
                    comment: commentController.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final product = _productController.selectedProduct.value!;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: product.stock > 0
                  ? () {
                      _cartController.addToCart(
                        product,
                        qty: _productController.quantity.value,
                        size: _productController.selectedSize.value.isNotEmpty
                            ? _productController.selectedSize.value
                            : null,
                        color: _productController.selectedColor.value.isNotEmpty
                            ? _productController.selectedColor.value
                            : null,
                      );
                    }
                  : null,
              icon: const Icon(Icons.shopping_cart_outlined, size: 18),
              label: const Text('Add to Cart'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: product.stock > 0
                  ? () {
                      _cartController.addToCart(
                        product,
                        qty: _productController.quantity.value,
                        size: _productController.selectedSize.value.isNotEmpty
                            ? _productController.selectedSize.value
                            : null,
                        color: _productController.selectedColor.value.isNotEmpty
                            ? _productController.selectedColor.value
                            : null,
                      );
                      Get.toNamed(AppRoutes.cart);
                    }
                  : null,
              icon: const Icon(Icons.flash_on, size: 18),
              label: const Text('Buy Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts(BuildContext context) {
    return Obx(() {
      if (_productController.relatedProducts.isEmpty) return const SizedBox.shrink();
      return Column(
        children: [
          const SizedBox(height: 8),
          SectionHeader(
            title: 'You May Also Like',
            actionText: 'See All',
            onActionTap: () {
              final product = _productController.selectedProduct.value;
              if (product != null) {
                Get.toNamed(AppRoutes.productList, arguments: {
                  'categoryId': product.categoryId,
                  'title': product.categoryName,
                });
              }
            },
          ),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _productController.relatedProducts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ProductCard(
                    product: _productController.relatedProducts[index],
                    width: 160,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    });
  }

  void _showImageViewer(BuildContext context, int initialIndex) {
    final product = _productController.selectedProduct.value!;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: CachedNetworkImage(
                imageUrl: product.images[initialIndex],
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? AppTheme.primaryColor.withOpacity(0.3) : Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppTheme.primaryColor : Colors.grey.shade400,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../presentation/controllers/wishlist_controller.dart';
import '../../../presentation/controllers/cart_controller.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();
    final cartController = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Wishlist (${wishlistController.count})')),
        actions: [
          Obx(() => wishlistController.wishlistItems.isNotEmpty
              ? TextButton(
                  onPressed: () => _showMoveAllToCartDialog(context, wishlistController, cartController),
                  child: const Text('Move All to Cart', style: TextStyle(color: Colors.white, fontSize: 13)),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (wishlistController.wishlistItems.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.favorite_outline,
            title: 'Your Wishlist is Empty',
            subtitle: 'Save items you love for later by tapping the heart icon.',
            buttonText: 'Explore Products',
            onButtonTap: () => Get.offAllNamed(AppRoutes.main),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemCount: wishlistController.wishlistItems.length,
          itemBuilder: (context, index) {
            final product = wishlistController.wishlistItems[index];
            return ProductCard(product: product);
          },
        );
      }),
    );
  }

  void _showMoveAllToCartDialog(
    BuildContext context,
    WishlistController wishlistController,
    CartController cartController,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Move All to Cart'),
        content: const Text('Add all wishlisted items to your cart?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              for (final product in wishlistController.wishlistItems.toList()) {
                cartController.addToCart(product);
              }
              wishlistController.clearWishlist();
              Get.snackbar(
                'Done!',
                'All wishlist items moved to cart',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Move All'),
          ),
        ],
      ),
    );
  }
}

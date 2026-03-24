import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/main_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/category/category_screen.dart';
import '../presentation/screens/product/product_list_screen.dart';
import '../presentation/screens/product/product_detail_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/cart/cart_screen.dart';
import '../presentation/screens/checkout/checkout_screen.dart';
import '../presentation/screens/checkout/order_success_screen.dart';
import '../presentation/screens/orders/orders_screen.dart';
import '../presentation/screens/orders/order_detail_screen.dart';
import '../presentation/screens/wishlist/wishlist_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/profile/edit_profile_screen.dart';
import '../presentation/screens/profile/addresses_screen.dart';
import '../presentation/screens/profile/notifications_screen.dart';
import '../presentation/screens/profile/settings_screen.dart';
import '../presentation/screens/admin/admin_dashboard_screen.dart';
import '../presentation/screens/admin/admin_products_screen.dart';
import '../presentation/screens/admin/post_product_screen.dart';

class SkyMartApp extends StatelessWidget {
  const SkyMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: [
        GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
        GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen()),
        GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
        GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),
        GetPage(name: AppRoutes.main, page: () => const MainScreen()),
        GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
        GetPage(name: AppRoutes.categories, page: () => const CategoryScreen()),
        GetPage(name: AppRoutes.productList, page: () => const ProductListScreen()),
        GetPage(name: AppRoutes.productDetail, page: () => const ProductDetailScreen()),
        GetPage(name: AppRoutes.search, page: () => const SearchScreen()),
        GetPage(name: AppRoutes.cart, page: () => const CartScreen()),
        GetPage(name: AppRoutes.checkout, page: () => const CheckoutScreen()),
        GetPage(name: AppRoutes.orderSuccess, page: () => const OrderSuccessScreen()),
        GetPage(name: AppRoutes.orders, page: () => const OrdersScreen()),
        GetPage(name: AppRoutes.orderDetail, page: () => const OrderDetailScreen()),
        GetPage(name: AppRoutes.wishlist, page: () => const WishlistScreen()),
        GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
        GetPage(name: AppRoutes.editProfile, page: () => const EditProfileScreen()),
        GetPage(name: AppRoutes.addresses, page: () => const AddressesScreen()),
        GetPage(name: AppRoutes.notifications, page: () => const NotificationsScreen()),
        GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
        GetPage(name: AppRoutes.adminDashboard, page: () => const AdminDashboardScreen()),
        GetPage(name: AppRoutes.adminProducts, page: () => const AdminProductsScreen()),
        GetPage(name: AppRoutes.postProduct, page: () => const PostProductScreen()),
      ],
    );
  }
}

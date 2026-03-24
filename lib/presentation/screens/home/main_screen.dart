import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../presentation/controllers/navigation_controller.dart';
import '../../../presentation/controllers/cart_controller.dart';
import 'home_screen.dart';
import '../category/category_screen.dart';
import '../search/search_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavigationController>();
    final cartController = Get.find<CartController>();

    final List<Widget> pages = [
      const HomeScreen(),
      const CategoryScreen(),
      const SearchScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: navController.currentIndex.value,
            children: pages,
          ),
          // Sell FAB in center of bottom nav
          floatingActionButton: FloatingActionButton(
            onPressed: () => Get.toNamed(AppRoutes.postProduct),
            backgroundColor: AppTheme.accentColor,
            elevation: 4,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 22),
                Text('Sell', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 6,
            elevation: 8,
            child: SizedBox(
              height: 60,
              child: Obx(() => Row(
                    children: [
                      // Home
                      _NavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: 'Home',
                        index: 0,
                        currentIndex: navController.currentIndex.value,
                        onTap: () => navController.changePage(0),
                      ),
                      // Categories
                      _NavItem(
                        icon: Icons.grid_view_outlined,
                        activeIcon: Icons.grid_view,
                        label: 'Categories',
                        index: 1,
                        currentIndex: navController.currentIndex.value,
                        onTap: () => navController.changePage(1),
                      ),
                      // Spacer for FAB
                      const Expanded(child: SizedBox()),
                      // Cart
                      _NavItemBadge(
                        icon: Icons.shopping_cart_outlined,
                        activeIcon: Icons.shopping_cart,
                        label: 'Cart',
                        index: 3,
                        currentIndex: navController.currentIndex.value,
                        badgeCount: cartController.totalItems,
                        onTap: () => navController.changePage(3),
                      ),
                      // Profile
                      _NavItem(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: 'Profile',
                        index: 4,
                        currentIndex: navController.currentIndex.value,
                        onTap: () => navController.changePage(4),
                      ),
                    ],
                  )),
            ),
          ),
        ));
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon,
                color: isActive ? AppTheme.primaryColor : Colors.grey.shade500,
                size: 24),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? AppTheme.primaryColor : Colors.grey.shade500,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }
}

class _NavItemBadge extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItemBadge({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            badges.Badge(
              showBadge: badgeCount > 0,
              badgeContent: Text(
                badgeCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: AppTheme.accentColor,
                padding: EdgeInsets.all(4),
              ),
              child: Icon(isActive ? activeIcon : icon,
                  color: isActive ? AppTheme.primaryColor : Colors.grey.shade500,
                  size: 24),
            ),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? AppTheme.primaryColor : Colors.grey.shade500,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }
}

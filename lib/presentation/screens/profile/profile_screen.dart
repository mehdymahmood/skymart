import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../presentation/controllers/wishlist_controller.dart';
import '../../../presentation/controllers/order_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final wishlistController = Get.find<WishlistController>();
    final orderController = Get.put(OrderController());

    return Scaffold(
      body: Obx(() {
        final user = authController.currentUser.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppTheme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -40,
                        right: -40,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 44,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundImage: user.avatar != null
                                          ? CachedNetworkImageProvider(user.avatar!)
                                          : null,
                                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                                      child: user.avatar == null
                                          ? Text(
                                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                              style: const TextStyle(
                                                  fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => Get.toNamed(AppRoutes.editProfile),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.accentColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.edit, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
                              ),
                              if (user.isAdmin) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified, color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Text('ADMIN',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1)),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => Get.toNamed(AppRoutes.settings),
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Stats row
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Obx(() => Row(
                          children: [
                            _StatItem(
                              label: 'Orders',
                              value: orderController.orders.length.toString(),
                              icon: Icons.shopping_bag_outlined,
                              onTap: () => Get.toNamed(AppRoutes.orders),
                            ),
                            Container(width: 1, height: 40, color: Colors.grey.shade200),
                            _StatItem(
                              label: 'Wishlist',
                              value: wishlistController.count.toString(),
                              icon: Icons.favorite_outline,
                              onTap: () => Get.toNamed(AppRoutes.wishlist),
                            ),
                            Container(width: 1, height: 40, color: Colors.grey.shade200),
                            _StatItem(
                              label: 'Reviews',
                              value: '7',
                              icon: Icons.star_outline,
                              onTap: () {},
                            ),
                          ],
                        )),
                  ),
                  const SizedBox(height: 12),
                  // Menu sections
                  // Admin panel (admin only)
                  if (authController.isAdmin) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 26),
                        title: const Text('Admin Panel',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                        subtitle: const Text('Manage products & view orders',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                        onTap: () => Get.toNamed(AppRoutes.adminDashboard),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildMenuSection(context, 'Account', [
                    _MenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () => Get.toNamed(AppRoutes.editProfile),
                    ),
                    _MenuItem(
                      icon: Icons.shopping_bag_outlined,
                      title: 'My Orders',
                      subtitle: '${orderController.orders.length} orders',
                      onTap: () => Get.toNamed(AppRoutes.orders),
                    ),
                    _MenuItem(
                      icon: Icons.favorite_outline,
                      title: 'Wishlist',
                      subtitle: '${wishlistController.count} items',
                      onTap: () => Get.toNamed(AppRoutes.wishlist),
                    ),
                    _MenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Saved Addresses',
                      onTap: () => Get.toNamed(AppRoutes.addresses),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _buildMenuSection(context, 'Notifications & Settings', [
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () => Get.toNamed(AppRoutes.notifications),
                    ),
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () => Get.toNamed(AppRoutes.settings),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _buildMenuSection(context, 'Support', [
                    _MenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () => Get.snackbar('Coming Soon', 'Help center coming soon',
                          snackPosition: SnackPosition.BOTTOM),
                    ),
                    _MenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => Get.snackbar('Privacy Policy', 'Privacy policy page',
                          snackPosition: SnackPosition.BOTTOM),
                    ),
                    _MenuItem(
                      icon: Icons.info_outline,
                      title: 'About ${AppConstants.appName}',
                      subtitle: 'Version ${AppConstants.appVersion}',
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: AppConstants.appName,
                        applicationVersion: AppConstants.appVersion,
                        applicationLegalese: '© 2026 SkyMart. All rights reserved.',
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // Logout button
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.logout, color: AppTheme.errorColor, size: 20),
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w600),
                      ),
                      onTap: () => _confirmLogout(context, authController),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<_MenuItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, color: AppTheme.primaryColor, size: 20),
                  ),
                  title: Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: item.subtitle != null
                      ? Text(item.subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500))
                      : null,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  onTap: item.onTap,
                ),
                if (index < items.length - 1)
                  const Divider(height: 1, indent: 60, endIndent: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 3),
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

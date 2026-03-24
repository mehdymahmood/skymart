import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/controllers/settings_controller.dart';
import '../../../presentation/controllers/auth_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Appearance
          _SectionHeader(title: 'Appearance'),
          Obx(() => _ToggleTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark theme',
                value: settingsController.isDarkMode.value,
                onChanged: settingsController.toggleDarkMode,
              )),
          // Language
          _SectionHeader(title: 'Language & Region'),
          Obx(() => _ActionTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: settingsController.language.value,
                onTap: () => _showLanguagePicker(context, settingsController),
              )),
          // Notifications
          _SectionHeader(title: 'Notifications'),
          Obx(() => _ToggleTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive order and promo alerts',
                value: settingsController.pushNotifications.value,
                onChanged: settingsController.togglePushNotifications,
              )),
          Obx(() => _ToggleTile(
                icon: Icons.email_outlined,
                title: 'Email Notifications',
                subtitle: 'Receive updates via email',
                value: settingsController.emailNotifications.value,
                onChanged: settingsController.toggleEmailNotifications,
              )),
          Obx(() => _ToggleTile(
                icon: Icons.sms_outlined,
                title: 'SMS Notifications',
                subtitle: 'Receive updates via SMS',
                value: settingsController.smsNotifications.value,
                onChanged: settingsController.toggleSmsNotifications,
              )),
          // About
          _SectionHeader(title: 'About'),
          _ActionTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: AppConstants.appVersion,
            onTap: () {},
          ),
          _ActionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            onTap: () => Get.snackbar('Info', 'Privacy policy coming soon',
                snackPosition: SnackPosition.BOTTOM),
          ),
          _ActionTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'View terms and conditions',
            onTap: () => Get.snackbar('Info', 'Terms of service coming soon',
                snackPosition: SnackPosition.BOTTOM),
          ),
          // Account
          _SectionHeader(title: 'Account'),
          _ActionTile(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Log out of your account',
            iconColor: AppTheme.errorColor,
            titleColor: AppTheme.errorColor,
            onTap: () => _confirmSignOut(authController),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsController controller) {
    final languages = ['English', 'বাংলা', 'Arabic', 'Hindi', 'French'];
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Select Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            ...languages.map((lang) => Obx(() => ListTile(
                  title: Text(lang),
                  trailing: controller.language.value == lang
                      ? const Icon(Icons.check, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    controller.changeLanguage(lang);
                    Get.back();
                  },
                ))),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

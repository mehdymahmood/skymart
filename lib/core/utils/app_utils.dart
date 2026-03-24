import 'package:intl/intl.dart';

class AppUtils {
  static String formatPrice(double price, {String currency = '৳'}) {
    final formatter = NumberFormat('#,##0.00');
    return '$currency${formatter.format(price)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 30) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  static String formatCountdown(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static double calculateDiscount(double originalPrice, double salePrice) {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - salePrice) / originalPrice) * 100;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^(\+?88)?01[3-9]\d{8}$').hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static String getProductImageUrl(int seed, {int width = 400, int height = 400}) {
    return 'https://picsum.photos/seed/$seed/$width/$height';
  }

  static String getBannerImageUrl(int seed, {int width = 800, int height = 300}) {
    return 'https://picsum.photos/seed/$seed/$width/$height';
  }

  static String getAvatarUrl(int seed, {int size = 200}) {
    return 'https://picsum.photos/seed/$seed/$size/$size';
  }
}

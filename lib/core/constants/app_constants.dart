class AppConstants {
  static const String appName = 'SkyMart';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Global Sourcing & Shopping';

  // Colors (hex strings)
  static const String primaryColorHex = '#1A237E';
  static const String accentColorHex = '#FF6F00';

  // Storage Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserData = 'user_data';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyCartItems = 'cart_items';
  static const String keyWishlistItems = 'wishlist_items';
  static const String keyThemeMode = 'theme_mode';

  // API/Mock config
  static const String baseImageUrl = 'https://picsum.photos';
  static const int productsPerPage = 10;
  static const int flashSaleDurationHours = 8;

  // Shimmer
  static const Duration shimmerDuration = Duration(milliseconds: 1500);

  // Search debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 50.0;

  // Card elevation
  static const double cardElevation = 4.0;

  // Bottom nav
  static const int bottomNavHome = 0;
  static const int bottomNavCategories = 1;
  static const int bottomNavSearch = 2;
  static const int bottomNavCart = 3;
  static const int bottomNavProfile = 4;

  // Order statuses
  static const String orderPlaced = 'Placed';
  static const String orderConfirmed = 'Confirmed';
  static const String orderShipped = 'Shipped';
  static const String orderDelivered = 'Delivered';
  static const String orderCancelled = 'Cancelled';

  // Payment methods
  static const String paymentCOD = 'Cash on Delivery';
  static const String paymentCard = 'Credit/Debit Card';
  static const String paymentBkash = 'bKash';
  static const String paymentNagad = 'Nagad';
  static const String paymentRocket = 'Rocket';
}

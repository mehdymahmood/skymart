import 'package:get/get.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/cart_controller.dart';
import '../../presentation/controllers/wishlist_controller.dart';
import '../../presentation/controllers/navigation_controller.dart';
import '../../presentation/controllers/settings_controller.dart';
import '../../presentation/controllers/notification_controller.dart';
import '../../presentation/controllers/sell_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<WishlistController>(WishlistController(), permanent: true);
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.put<SettingsController>(SettingsController(), permanent: true);
    Get.put<NotificationController>(NotificationController(), permanent: true);
    Get.put<SellController>(SellController(), permanent: true);
  }
}

import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  bool get isHome => currentIndex.value == AppConstants.bottomNavHome;
  bool get isCategories => currentIndex.value == AppConstants.bottomNavCategories;
  bool get isSearch => currentIndex.value == AppConstants.bottomNavSearch;
  bool get isCart => currentIndex.value == AppConstants.bottomNavCart;
  bool get isProfile => currentIndex.value == AppConstants.bottomNavProfile;
}

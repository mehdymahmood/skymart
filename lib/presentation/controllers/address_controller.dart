import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import 'auth_controller.dart';

class AddressController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAddresses();
  }

  void _loadAddresses() {
    final user = _authController.currentUser.value;
    if (user != null) {
      addresses.value = user.addresses;
    }
  }

  Future<void> addAddress(AddressModel address) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    if (address.isDefault) {
      addresses.value = addresses.map((a) => a.copyWith(isDefault: false)).toList();
    }

    addresses.add(address);
    _updateUserAddresses();
    isLoading.value = false;
    Get.back();
    Get.snackbar('Success', 'Address added successfully',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> updateAddress(AddressModel address) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    final index = addresses.indexWhere((a) => a.id == address.id);
    if (index >= 0) {
      if (address.isDefault) {
        addresses.value = addresses.map((a) => a.copyWith(isDefault: false)).toList();
      }
      addresses[index] = address;
    }
    _updateUserAddresses();
    isLoading.value = false;
    Get.back();
    Get.snackbar('Success', 'Address updated successfully',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> deleteAddress(String addressId) async {
    addresses.removeWhere((a) => a.id == addressId);
    _updateUserAddresses();
    Get.snackbar('Deleted', 'Address removed',
        snackPosition: SnackPosition.BOTTOM);
  }

  void setAsDefault(String addressId) {
    addresses.value = addresses
        .map((a) => a.copyWith(isDefault: a.id == addressId))
        .toList();
    _updateUserAddresses();
  }

  void _updateUserAddresses() {
    final user = _authController.currentUser.value;
    if (user != null) {
      _authController.currentUser.value = user.copyWith(addresses: addresses.toList());
    }
  }

  AddressModel? get defaultAddress {
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }
}

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';
import '../../data/providers/mock_data_provider.dart';
import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final MockDataProvider _mockData = MockDataProvider();

  final RxBool isLoggedIn = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  // Form fields
  final RxString loginError = ''.obs;
  final RxString registerError = ''.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  bool get isAdmin => currentUser.value?.isAdmin ?? false;

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    if (loggedIn) {
      final savedEmail = prefs.getString('saved_email') ?? '';
      currentUser.value = savedEmail == 'admin@skymart.com'
          ? _mockData.getAdminUser()
          : _mockData.getMockUser();
      isLoggedIn.value = true;
    }
  }

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      loginError.value = 'Please enter email and password';
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      loginError.value = 'Please enter a valid email';
      return false;
    }
    if (password.length < 6) {
      loginError.value = 'Password must be at least 6 characters';
      return false;
    }

    isLoading.value = true;
    loginError.value = '';

    await Future.delayed(const Duration(seconds: 2));

    // Admin credentials check
    final isAdminLogin =
        email.trim().toLowerCase() == 'admin@skymart.com' && password == 'admin123';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString('saved_email', email.trim().toLowerCase());

    currentUser.value = isAdminLogin ? _mockData.getAdminUser() : _mockData.getMockUser();
    isLoggedIn.value = true;
    isLoading.value = false;
    return true;
  }

  Future<bool> register(String name, String email, String phone, String password) async {
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      registerError.value = 'All fields are required';
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      registerError.value = 'Please enter a valid email';
      return false;
    }
    if (password.length < 6) {
      registerError.value = 'Password must be at least 6 characters';
      return false;
    }

    isLoading.value = true;
    registerError.value = '';

    await Future.delayed(const Duration(seconds: 2));

    final newUser = UserModel(
      id: 'user_new',
      name: name,
      email: email,
      phone: phone,
      orderCount: 0,
      wishlistCount: 0,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    currentUser.value = newUser;
    isLoggedIn.value = true;
    isLoading.value = false;
    return true;
  }

  Future<void> logout() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
    currentUser.value = null;
    isLoggedIn.value = false;
    isLoading.value = false;
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    String? avatar,
  }) async {
    if (currentUser.value == null) return;
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    currentUser.value = currentUser.value!.copyWith(
      name: name,
      phone: phone,
      avatar: avatar ?? currentUser.value!.avatar,
    );
    isLoading.value = false;
    Get.snackbar('Success', 'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM);
  }

  void toggleObscurePassword() => obscurePassword.value = !obscurePassword.value;
  void toggleObscureConfirmPassword() => obscureConfirmPassword.value = !obscureConfirmPassword.value;

  void clearErrors() {
    loginError.value = '';
    registerError.value = '';
  }

  Future<void> forgotPassword(String email) async {
    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    Get.snackbar('Email Sent', 'Password reset link sent to $email',
        snackPosition: SnackPosition.BOTTOM);
  }
}

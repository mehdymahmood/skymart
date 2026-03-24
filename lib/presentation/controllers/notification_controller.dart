import 'package:get/get.dart';
import '../../data/models/notification_model.dart';
import '../../data/providers/mock_data_provider.dart';

class NotificationController extends GetxController {
  final MockDataProvider _mockData = MockDataProvider();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    notifications.value = _mockData.getMockNotifications();
    isLoading.value = false;
  }

  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      notifications[index] = notifications[index].copyWith(isRead: true);
    }
  }

  void markAllAsRead() {
    notifications.value = notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
  }

  void deleteNotification(String notificationId) {
    notifications.removeWhere((n) => n.id == notificationId);
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

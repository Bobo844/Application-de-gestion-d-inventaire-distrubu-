import 'dart:async';

class SystemNotification {
  static const String TYPE_TRANSFER = 'transfer';
  static const String TYPE_STOCK = 'stock';
  static const String TYPE_ORDER = 'order';

  static List<Map<String, dynamic>> notifications = [];

  static Map<String, dynamic> createNotification({
    required String type,
    required String title,
    required String message,
    required String userId,
    String? relatedId,
  }) {
    final notification = {
      'id': DateTime.now().toString(),
      'type': type,
      'title': title,
      'message': message,
      'userId': userId,
      'relatedId': relatedId,
      'date': DateTime.now().toIso8601String(),
      'read': false,
    };
    notifications.add(notification);
    return notification;
  }

  static void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      notifications[index]['read'] = true;
    }
  }

  static void markAllAsRead(String userId) {
    for (var notification in notifications) {
      if (notification['userId'] == userId) {
        notification['read'] = true;
      }
    }
  }

  static List<Map<String, dynamic>> getNotifications(String userId) {
    return notifications
        .where((notification) => notification['userId'] == userId)
        .toList()
      ..sort((a, b) =>
          DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
  }

  static Stream<List<Map<String, dynamic>>> getNotificationsStream(
      String userId) {
    return Stream.periodic(const Duration(seconds: 1))
        .map((_) => getNotifications(userId));
  }

  static int getUnreadCount(String userId) {
    return notifications
        .where((notification) =>
            notification['userId'] == userId && !notification['read'])
        .length;
  }

  static void deleteNotification(String notificationId) {
    notifications.removeWhere((n) => n['id'] == notificationId);
  }

  static void deleteAllNotifications(String userId) {
    notifications.removeWhere((n) => n['userId'] == userId);
  }
}

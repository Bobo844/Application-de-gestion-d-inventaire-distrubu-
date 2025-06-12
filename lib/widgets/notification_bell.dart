import 'package:flutter/material.dart';
import '../models/notification.dart';
import 'package:intl/intl.dart';
import '../screens/transfers/transfer_history_page.dart';

class NotificationBell extends StatefulWidget {
  final String userId;
  final VoidCallback? onNotificationTap;

  const NotificationBell({
    super.key,
    required this.userId,
    this.onNotificationTap,
  });

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: SystemNotification.getNotificationsStream(widget.userId),
            builder: (context, snapshot) {
              final notifications = snapshot.data ?? [];
              if (notifications.isEmpty) {
                return const Center(
                  child: Text('Aucune notification non lue'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return ListTile(
                    leading: Icon(
                      _getNotificationIcon(
                          notification['type'] as String? ?? 'unknown'),
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(notification['title'] as String? ?? 'N/A'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification['message'] as String? ?? 'N/A'),
                        Text(
                          _dateFormat.format(DateTime.parse(
                              notification['date'] as String? ??
                                  DateTime.now().toIso8601String())),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      SystemNotification.markAsRead(
                          notification['id'] as String? ?? '');
                      setState(() {});
                      Navigator.pop(context);
                      if ((notification['type'] as String? ?? '') ==
                          SystemNotification.TYPE_TRANSFER) {
                        Navigator.pushNamed(
                          context,
                          '/transfers/history/:id',
                          arguments: {
                            'transferId': notification['relatedId'],
                          },
                        );
                      } else if (widget.onNotificationTap != null) {
                        widget.onNotificationTap!();
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case SystemNotification.TYPE_TRANSFER:
        return Icons.swap_horiz;
      case SystemNotification.TYPE_STOCK:
        return Icons.inventory;
      case SystemNotification.TYPE_ORDER:
        return Icons.shopping_cart;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = SystemNotification.getUnreadCount(widget.userId);

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: _showNotifications,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

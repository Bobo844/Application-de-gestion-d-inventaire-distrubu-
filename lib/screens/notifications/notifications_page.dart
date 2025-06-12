import 'package:flutter/material.dart';
import '../../models/notification.dart';
import '../../models/user_account.dart';
import '../../widgets/custom_drawer.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Couleurs personnalisées
  final Color _primaryColor = const Color(0xFF2196F3);
  final Color _accentColor = const Color(0xFF64B5F6);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final currentUser = UserAccount.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: const CustomDrawer(),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: SystemNotification.getNotificationsStream(currentUser['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!;
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(
                          notification['type'] as String? ?? ''),
                      color: _primaryColor,
                    ),
                  ),
                  title: Text(
                    notification['title'] as String? ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        notification['message'] as String? ?? '',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(notification['date'] as String? ?? ''),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: !notification['read']
                      ? Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _primaryColor.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        )
                      : null,
                  onTap: () {
                    SystemNotification.markAsRead(
                        notification['id'] as String? ?? '');
                    setState(() {});

                    if ((notification['type'] as String? ?? '') ==
                        SystemNotification.TYPE_TRANSFER) {
                      Navigator.pushNamed(
                        context,
                        '/transfers/history/:id',
                        arguments: {
                          'transferId': notification['relatedId'],
                        },
                      );
                    } else if ((notification['type'] as String? ?? '') ==
                        SystemNotification.TYPE_ORDER) {
                      Navigator.pushNamed(
                        context,
                        '/orders/history/:id',
                        arguments: {
                          'orderId': notification['relatedId'],
                        },
                      );
                    }
                  },
                ),
              );
            },
          );
        },
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return 'Date invalide';
    }
  }
}

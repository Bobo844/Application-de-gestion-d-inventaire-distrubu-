import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../models/notification.dart';
import '../screens/auth/login_page.dart';
import '../screens/dashboard/dashboard_page.dart';
import '../screens/products/product_management.dart';
import '../screens/stores/store_management.dart';
import '../screens/stocks/stock_alerts.dart';
import '../screens/stocks/stock_history.dart';
import '../screens/suppliers/supplier_management.dart';
import '../screens/orders/supplier_order_list.dart';
import '../screens/reports/reports_page.dart';
import '../screens/users/user_management.dart';
import '../screens/transfers/stock_transfer_form.dart';
import '../screens/sales/new_sale_page.dart';
import '../screens/sales/sales_history_page.dart';
import '../screens/sales/sales_stats_page.dart';
import '../screens/transfers/transfer_history_page.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isProductsExpanded = false;
  bool _isTransfersExpanded = false;
  bool _isSalesExpanded = false;
  bool _isAdminExpanded = false;
  bool _isOrdersExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = UserAccount.currentUser;
    if (currentUser == null) {
      return const Drawer(
        child: Center(
          child: Text('Vous devez être connecté pour accéder à cette page'),
        ),
      );
    }

    final isAdmin = UserAccount.isAdmin();
    final isManager = UserAccount.isManager();
    final isSeller = currentUser['role'] == UserAccount.ROLE_SELLER;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // En-tête du drawer
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Colors.blue.shade700],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inventory,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Gestion de Stock',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Section Ventes (accessible à tous les utilisateurs)
          ExpansionTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text(
              'Ventes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            initiallyExpanded: _isSalesExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isSalesExpanded = expanded;
              });
            },
            children: [
              ListTile(
                leading: const Icon(Icons.add_shopping_cart),
                title: const Text('Nouvelle vente'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NewSalePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Historique des ventes'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SalesHistoryPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Statistiques des ventes'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SalesStatsPage()),
                  );
                },
              ),
            ],
          ),

          // Section Gestion des Produits (Admin + Manager)
          if (isAdmin || isManager) ...[
            ExpansionTile(
              leading: const Icon(Icons.inventory),
              title: const Text(
                'Gestion des Produits',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              initiallyExpanded: _isProductsExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isProductsExpanded = expanded;
                });
              },
              children: [
                ListTile(
                  leading: const Icon(Icons.inventory),
                  title: const Text('Gestion des produits'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProductManagementPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.warning),
                  title: const Text('Alertes de stock'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StockAlertsPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Historique des stocks'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StockHistoryPage()),
                    );
                  },
                ),
              ],
            ),
          ],

          // Section Transferts (Admin + Manager)
          if (isAdmin || isManager) ...[
            ExpansionTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text(
                'Transferts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              initiallyExpanded: _isTransfersExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isTransfersExpanded = expanded;
                });
              },
              children: [
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: const Text('Nouveau transfert'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StockTransferForm()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Historique des transferts'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TransferHistoryPage()),
                    );
                  },
                ),
              ],
            ),
          ],

          // Section Commandes (Admin + Manager)
          if (isAdmin || isManager) ...[
            ExpansionTile(
              leading: const Icon(Icons.shopping_basket),
              title: const Text(
                'Commandes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              initiallyExpanded: _isOrdersExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isOrdersExpanded = expanded;
                });
              },
              children: [
                ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('Commandes fournisseurs'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SupplierOrderListPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assessment),
                  title: const Text('Rapports de commandes'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReportsPage()),
                    );
                  },
                ),
              ],
            ),
          ],

          // Section Administration (Admin uniquement)
          if (isAdmin) ...[
            ExpansionTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text(
                'Administration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              initiallyExpanded: _isAdminExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isAdminExpanded = expanded;
                });
              },
              children: [
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Gestion des utilisateurs'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserManagementPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.storefront),
                  title: const Text('Gestion des magasins'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StoreManagementPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: const Text('Gestion des fournisseurs'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SupplierManagementPage()),
                    );
                  },
                ),
                // Notifications for admin
                if (isAdmin && SystemNotification.notifications.isNotEmpty) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  ...SystemNotification.notifications.map((notification) {
                    return ListTile(
                      leading: const Icon(Icons.notifications_active,
                          color: Colors.orange),
                      title: Text(notification['message']),
                      subtitle: Text(notification['type']),
                      onTap: () {
                        print(
                            'DEBUG: Notification tapped. Type: ${notification['type']}, RelatedId: ${notification['relatedId']}');
                        // Handle notification click
                        Navigator.pop(context); // Close the drawer
                        if (notification['type'] ==
                            SystemNotification.TYPE_TRANSFER) {
                          Navigator.pushNamed(
                            context,
                            '/transfers/history/:id',
                            arguments: {
                              'transferId': notification['relatedId'],
                            },
                          );
                        } else if (notification['type'] ==
                            SystemNotification.TYPE_ORDER) {
                          Navigator.pushNamed(
                            context,
                            '/orders/history/:id',
                            arguments: {
                              'orderId': notification['relatedId'],
                            },
                          );
                        } else {
                          // Handle other notification types if needed
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Notification: ${notification['message']}')),
                          );
                        }
                      },
                    );
                  }).toList(),
                ],
              ],
            ),
          ],

          // Section Notifications (Admin + Manager)
          if (isAdmin || isManager) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: StreamBuilder<List<Map<String, dynamic>>>(
                stream: SystemNotification.getNotificationsStream(
                    currentUser['id']),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final unreadCount = snapshot.data!
                        .where((notification) => !notification['read'])
                        .length;
                    if (unreadCount > 0) {
                      return Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notifications');
              },
            ),
          ],

          // Section Rapport des transactions (Tous les utilisateurs)
          const Divider(),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Rapport des transactions'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsPage()),
              );
            },
          ),

          // Section Déconnexion (Tous les utilisateurs)
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content:
                      const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Fermer la boîte de dialogue
                        Navigator.pop(dialogContext);
                        // Fermer le drawer
                        Navigator.pop(context);

                        // Déconnecter l'utilisateur
                        UserAccount.logout();

                        // Forcer la navigation vers la page de connexion
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Déconnecter',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

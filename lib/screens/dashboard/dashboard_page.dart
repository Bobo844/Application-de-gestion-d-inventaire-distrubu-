import 'package:flutter/material.dart';
import '../../models/user_account.dart';
import '../../models/store.dart';
import '../../models/product.dart';
import '../../models/stock.dart';
import '../../widgets/custom_drawer.dart';
import '../products/product_management.dart';
import '../stores/store_management.dart';
import '../stocks/stock_alerts.dart';
import '../stocks/stock_history.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Couleurs personnalisées
  final Color _primaryColor = const Color(0xFF2196F3);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

  void _showUserInfo() {
    final currentUser = UserAccount.currentUser;
    if (currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _primaryColor.withOpacity(0.1),
              child: Text(
                currentUser['firstName'] != null
                    ? currentUser['firstName'][0].toUpperCase()
                    : ' ',
                style: TextStyle(
                  fontSize: 16,
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: const Text('Informations utilisateur'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Nom d\'utilisateur',
                  currentUser['username'] as String? ?? 'N/A'),
              const SizedBox(height: 8),
              _buildInfoRow(
                  'Prénom', currentUser['firstName'] as String? ?? 'N/A'),
              const SizedBox(height: 8),
              _buildInfoRow('Nom', currentUser['lastName'] as String? ?? 'N/A'),
              const SizedBox(height: 8),
              _buildInfoRow('Email', currentUser['email'] as String? ?? 'N/A'),
              const SizedBox(height: 8),
              _buildInfoRow('Rôle',
                  _getRoleLabel(currentUser['role'] as String? ?? 'N/A')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: TextStyle(color: _primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 13.0,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            ': $value',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13.0,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case UserAccount.ROLE_ADMIN:
        return 'Administrateur';
      case UserAccount.ROLE_MANAGER:
        return 'Gestionnaire';
      case UserAccount.ROLE_EMPLOYEE:
        return 'Employé';
      case UserAccount.ROLE_SELLER:
        return 'Vendeur';
      default:
        return role;
    }
  }

  Widget _buildDashboardCard(
    String title,
    IconData icon,
    String value,
    Color color,
    VoidCallback? onTap, {
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UserAccount.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Vous devez être connecté pour accéder à cette page'),
        ),
      );
    }

    final activeStores = Store.stores
        .where((store) => store['status'] == Store.STATUS_ACTIVE)
        .length;
    final totalStores = Store.stores.length;
    final totalProducts = Product.products.length;
    final lowStockProducts = Stock.stockMovements
        .where((stock) =>
            (stock['quantity'] as num? ?? 0) <=
            (stock['threshold'] as num? ?? 0))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          InkWell(
            onTap: _showUserInfo,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      currentUser['firstName'] != null
                          ? currentUser['firstName'][0].toUpperCase()
                          : ' ',
                      style: TextStyle(
                        fontSize: 16,
                        color: _primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_primaryColor.withOpacity(0.1), _backgroundColor],
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.95,
            shrinkWrap: true,
            primary: false,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 20.0,
            children: [
              _buildDashboardCard(
                'Produits',
                Icons.inventory,
                '$totalProducts',
                _primaryColor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductManagementPage(),
                    ),
                  );
                },
              ),
              _buildDashboardCard(
                'Alertes Stock',
                Icons.warning,
                '$lowStockProducts',
                Colors.orange,
                () {
                  if (lowStockProducts > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StockAlertsPage(),
                      ),
                    );
                  }
                },
              ),
              _buildDashboardCard(
                'Magasins',
                Icons.store,
                '$activeStores / $totalStores',
                Colors.green,
                () {
                  if (UserAccount.isAdmin()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StoreManagementPage(),
                      ),
                    );
                  }
                },
                subtitle: 'Magasins actifs',
              ),
              _buildDashboardCard(
                'Mouvements',
                Icons.sync_alt,
                '${Stock.movements.length}',
                Colors.purple,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StockHistoryPage(),
                    ),
                  );
                },
                subtitle: 'Historique',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

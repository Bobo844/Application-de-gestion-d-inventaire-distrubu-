import 'package:flutter/material.dart';
import '../../models/sale.dart';
import '../../models/store.dart';
import '../../models/user_account.dart';

class SalesStatsPage extends StatefulWidget {
  const SalesStatsPage({super.key});

  @override
  State<SalesStatsPage> createState() => _SalesStatsPageState();
}

class _SalesStatsPageState extends State<SalesStatsPage> {
  String _selectedPeriod = 'all';
  String _selectedView = 'overview';
  String? _selectedSellerId;

  @override
  void initState() {
    super.initState();
    if (UserAccount.users.isNotEmpty) {
      _selectedSellerId = UserAccount.users.first['id'] as String?;
    }
  }

  String _getSellerFullName(String? sellerId) {
    if (sellerId == null) return 'Vendeur inconnu';
    
    final seller = UserAccount.users.firstWhere(
      (user) => user['id'] == sellerId,
      orElse: () => {
        'firstName': 'Vendeur',
        'lastName': 'inconnu',
      },
    );
    
    return '${seller['firstName'] ?? 'Vendeur'} ${seller['lastName'] ?? 'inconnu'}';
  }

  Widget _buildSellerDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSellerId,
      decoration: InputDecoration(
        labelText: 'Vendeur',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: UserAccount.users.map((user) {
        return DropdownMenuItem<String>(
          value: user['id'] as String?,
          child: Text('${user['firstName']} ${user['lastName']}'),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedSellerId = newValue;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sales = Sale.sales;
    double totalSales = 0.0;
    int numberOfSales = 0;
    double averageSale = 0.0;
    Map<String, int> productCount = {};
    String bestProduct = 'Aucun';

    try {
      final filteredSales = _selectedSellerId != null
          ? sales.where((sale) => sale['sellerId'] == _selectedSellerId).toList()
          : sales;

      totalSales = filteredSales.fold(
          0.0, (sum, sale) => sum + (sale['finalAmount'] ?? 0.0));
      numberOfSales = filteredSales.length;
      averageSale = numberOfSales > 0 ? totalSales / numberOfSales : 0.0;

      // Produit le plus vendu
      for (var sale in filteredSales) {
        if (sale['items'] != null) {
          for (var item in (sale['items'] as List)) {
            if (item['productName'] != null && item['quantity'] != null) {
              productCount[item['productName']] =
                  (productCount[item['productName']] ?? 0) +
                      ((item['quantity'] ?? 0) as int);
            }
          }
        }
      }

      if (productCount.isNotEmpty) {
        bestProduct = productCount.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }
    } catch (e) {
      print('Erreur lors du calcul des statistiques: $e');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques des Ventes'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtres
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPeriod,
                    decoration: InputDecoration(
                      labelText: 'Période',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Toutes')),
                      DropdownMenuItem(
                          value: 'day', child: Text('Aujourd\'hui')),
                      DropdownMenuItem(
                          value: 'week', child: Text('Cette semaine')),
                      DropdownMenuItem(value: 'month', child: Text('Ce mois')),
                      DropdownMenuItem(
                          value: 'year', child: Text('Cette année')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value ?? 'all';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedView,
                    decoration: InputDecoration(
                      labelText: 'Vue',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'overview', child: Text('Vue d\'ensemble')),
                      DropdownMenuItem(
                          value: 'stores', child: Text('Par magasin')),
                      DropdownMenuItem(
                          value: 'sellers', child: Text('Par vendeur')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedView = value ?? 'overview';
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_selectedView == 'overview') _buildSellerDropdown(),
            const SizedBox(height: 20),
            // Contenu selon la vue sélectionnée
            Expanded(
              child: _selectedView == 'overview'
                  ? _buildOverviewStats(
                      totalSales, numberOfSales, bestProduct, averageSale)
                  : _selectedView == 'stores'
                      ? _buildStoreStats()
                      : _buildSellerStats(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStats(double totalSales, int numberOfSales,
      String bestProduct, double averageSale) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Ventes Totales',
          '${totalSales.toStringAsFixed(2)} €',
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          'Nombre de Ventes',
          '$numberOfSales',
          Icons.shopping_cart,
          Colors.blue,
        ),
        _buildStatCard(
          'Produit le Plus Vendu',
          bestProduct,
          Icons.star,
          Colors.orange,
        ),
        _buildStatCard(
          'Moyenne par Vente',
          '${averageSale.toStringAsFixed(2)} €',
          Icons.analytics,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStoreStats() {
    try {
      final storeStats = Sale.getSalesByStore();
      return ListView.builder(
        itemCount: storeStats.length,
        itemBuilder: (context, index) {
          try {
            final storeId = storeStats.keys.elementAt(index);
            final store = Store.stores.firstWhere(
              (s) => s['id'] == storeId,
              orElse: () => {'id': storeId, 'name': 'Magasin inconnu'},
            );
            final stats = storeStats[storeId]!;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store['name'] as String? ?? 'Magasin inconnu',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Ventes totales: ${(stats['totalSales'] ?? 0.0).toStringAsFixed(2)} €'),
                    Text('Nombre de ventes: ${stats['numberOfSales'] ?? 0}'),
                    const SizedBox(height: 8),
                    const Text(
                      'Produits vendus:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (stats['items'] != null)
                      ...(stats['items'] as Map<String, dynamic>).entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child:
                                  Text('${entry.key}: ${entry.value} unités'),
                            ),
                          ),
                  ],
                ),
              ),
            );
          } catch (e) {
            print(
                'Erreur lors de l\'affichage des statistiques du magasin: $e');
            return const SizedBox.shrink();
          }
        },
      );
    } catch (e) {
      print('Erreur lors du chargement des statistiques des magasins: $e');
      return const Center(
          child: Text('Erreur lors du chargement des statistiques'));
    }
  }

  Widget _buildSellerStats() {
    try {
      final sellerStats = Sale.getSalesBySeller();
      return ListView.builder(
        itemCount: sellerStats.length,
        itemBuilder: (context, index) {
          try {
            final userId = sellerStats.keys.elementAt(index);
            final user = UserAccount.users.firstWhere(
              (u) => u['id'] == userId,
              orElse: () => {
                'id': userId,
                'firstName': 'Vendeur',
                'lastName': 'inconnu',
              },
            );
            final stats = sellerStats[userId]!;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user['firstName'] ?? 'Vendeur'} ${user['lastName'] ?? 'inconnu'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Ventes totales: ${(stats['totalSales'] ?? 0.0).toStringAsFixed(2)} €'),
                    Text('Nombre de ventes: ${stats['numberOfSales'] ?? 0}'),
                    const SizedBox(height: 8),
                    const Text(
                      'Produits vendus:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (stats['items'] != null)
                      ...(stats['items'] as Map<String, dynamic>).entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child:
                                  Text('${entry.key}: ${entry.value} unités'),
                            ),
                          ),
                  ],
                ),
              ),
            );
          } catch (e) {
            print(
                'Erreur lors de l\'affichage des statistiques du vendeur: $e');
            return const SizedBox.shrink();
          }
        },
      );
    } catch (e) {
      print('Erreur lors du chargement des statistiques des vendeurs: $e');
      return const Center(
          child: Text('Erreur lors du chargement des statistiques'));
    }
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

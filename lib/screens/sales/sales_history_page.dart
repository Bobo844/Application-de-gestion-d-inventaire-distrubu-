import 'package:flutter/material.dart';
import '../../models/sale.dart';
import '../../models/store.dart';
import '../../models/user_account.dart';
import 'package:intl/intl.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStore;
  String? _selectedSeller;
  String _selectedStatus = 'all';

  List<Map<String, dynamic>> get filteredSales {
    List<Map<String, dynamic>> result = List.from(Sale.sales);

    // Filtrage par recherche
    if (_searchController.text.isNotEmpty) {
      result = result.where((sale) {
        return sale['id'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
            (sale['items'] as List).any((item) =>
                item['productName'].toString().toLowerCase().contains(_searchController.text.toLowerCase()));
      }).toList();
    }

    // Filtrage par magasin
    if (_selectedStore != null) {
      result = result.where((sale) => sale['storeId'] == _selectedStore).toList();
    }

    // Filtrage par vendeur
    if (_selectedSeller != null) {
      result = result.where((sale) => sale['userId'] == _selectedSeller).toList();
    }

    // Filtrage par statut
    if (_selectedStatus != 'all') {
      result = result.where((sale) => sale['status'] == _selectedStatus).toList();
    }

    // Tri par date (plus récent en premier)
    result.sort((a, b) => DateTime.parse(b['saleDate']).compareTo(DateTime.parse(a['saleDate'])));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final sales = filteredSales;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Ventes'),
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
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher une vente...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Filtres'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedStore,
                              decoration: const InputDecoration(
                                labelText: 'Magasin',
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Tous les magasins'),
                                ),
                                ...Store.stores.map((store) {
                                  return DropdownMenuItem(
                                    value: store['id'] as String,
                                    child: Text(store['name'] as String),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStore = value;
                                });
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: _selectedSeller,
                              decoration: const InputDecoration(
                                labelText: 'Vendeur',
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Tous les vendeurs'),
                                ),
                                ...UserAccount.users
                                    .where((user) => user['role'] == 'seller')
                                    .map((user) {
                                  return DropdownMenuItem(
                                    value: user['id'] as String,
                                    child: Text('${user['firstName']} ${user['lastName']}'),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedSeller = value;
                                });
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Statut',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text('Tous les statuts'),
                                ),
                                DropdownMenuItem(
                                  value: 'completed',
                                  child: Text('Complétée'),
                                ),
                                DropdownMenuItem(
                                  value: 'cancelled',
                                  child: Text('Annulée'),
                                ),
                                DropdownMenuItem(
                                  value: 'refunded',
                                  child: Text('Remboursée'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value ?? 'all';
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Liste des ventes
            Expanded(
              child: ListView.builder(
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  final store = Store.stores.firstWhere((s) => s['id'] == sale['storeId']);
                  final seller = UserAccount.users.firstWhere((u) => u['id'] == sale['userId']);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      title: Text('Vente #${sale['id']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${dateFormat.format(DateTime.parse(sale['saleDate']))}'),
                          Text('Magasin: ${store['name']}'),
                          Text('Vendeur: ${seller['firstName']} ${seller['lastName']}'),
                          Text('Total: ${sale['finalAmount'].toStringAsFixed(2)}'),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Produits:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...(sale['items'] as List).map((item) => Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      '${item['productName']} - ${item['quantity']} x ${item['unitPrice']} = ${item['totalPrice']}',
                                    ),
                                  )),
                              const SizedBox(height: 8),
                              Text('Remise: ${sale['discount']}'),
                              Text('Méthode de paiement: ${sale['paymentMethod']}'),
                              Text('Statut: ${sale['status']}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

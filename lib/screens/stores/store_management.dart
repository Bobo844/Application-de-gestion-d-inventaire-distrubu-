import 'package:flutter/material.dart';
import '../../models/store.dart';
import '../../models/stock.dart';
import 'store_form.dart';

class StoreManagementPage extends StatefulWidget {
  const StoreManagementPage({super.key});

  @override
  _StoreManagementPageState createState() => _StoreManagementPageState();
}

class _StoreManagementPageState extends State<StoreManagementPage> {
  // Couleurs personnalisées
  final Color _primaryColor = const Color(0xFF2196F3);
 // final Color _accentColor = const Color(0xFF64B5F6);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get filteredStores {
    if (_searchController.text.isEmpty) {
      return Store.stores;
    }
    return Store.stores.where((store) {
      return store['name']
          .toString()
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Gestion des Magasins',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Nouveau Magasin',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StoreFormPage(),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_primaryColor.withOpacity(0.1), _backgroundColor],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Rechercher un magasin',
                    labelStyle: TextStyle(color: _primaryColor),
                    prefixIcon: Icon(Icons.search, color: _primaryColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: _primaryColor),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _primaryColor.withOpacity(0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _primaryColor.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            Expanded(
              child: filteredStores.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun magasin trouvé',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredStores.length,
                      itemBuilder: (context, index) {
                        final store = filteredStores[index];
                        final isActive = store['status'] == Store.STATUS_ACTIVE;
                        final stockCount = Stock.stockMovements
                            .where((stock) => stock['storeId'] == store['id'])
                            .length;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.store,
                                color: isActive ? Colors.green : Colors.grey,
                              ),
                            ),
                            title: Text(
                              store['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Adresse: ${store['address']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Produits en stock: $stockCount',
                                  style: TextStyle(
                                    color: stockCount > 0 ? _primaryColor : Colors.orange,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: isActive,
                                  activeColor: Colors.green,
                                  onChanged: (value) {
                                    setState(() {
                                      store['status'] = value
                                          ? Store.STATUS_ACTIVE
                                          : Store.STATUS_INACTIVE;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit, color: _primaryColor),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StoreFormPage(
                                          store: store,
                                          index: index,
                                        ),
                                      ),
                                    ).then((_) => setState(() {}));
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                          'Confirmation',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        content: Text(
                                          'Voulez-vous vraiment supprimer le magasin ${store['name']} ?',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text(
                                              'Annuler',
                                              style: TextStyle(color: _primaryColor),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                Store.stores.removeAt(index);
                                              });
                                              Navigator.pop(context);
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Supprimer'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
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

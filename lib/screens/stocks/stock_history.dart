import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/stock.dart';
import '../../models/store.dart';

class StockHistoryPage extends StatefulWidget {
  const StockHistoryPage({super.key});

  @override
  _StockHistoryPageState createState() => _StockHistoryPageState();
}

class _StockHistoryPageState extends State<StockHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStore;
  StockMovementType? _selectedType;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  // Couleurs personnalisées
  final Color _primaryColor = const Color(0xFF2196F3);
  //final Color _accentColor = const Color(0xFF64B5F6);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

  List<Map<String, dynamic>> get filteredMovements {
    List<Map<String, dynamic>> result = List.from(Stock.movements);

    if (_searchController.text.isNotEmpty) {
      result = result.where((movement) {
        return movement['productName']
            .toString()
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    }

    if (_selectedStore != null) {
      result = result
          .where((movement) => movement['storeId'] == _selectedStore)
          .toList();
    }

    if (_selectedType != null) {
      result = result
          .where((movement) => movement['type'] == _selectedType!.name)
          .toList();
    }

    result.sort((a, b) =>
        DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Historique des Mouvements',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 16.0),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Rechercher un produit',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.search, color: _primaryColor),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 12.0),
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
                            borderSide: BorderSide(color: _primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: _primaryColor.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: _primaryColor, width: 2),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              value: _selectedStore,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Magasin',
                                labelStyle: TextStyle(color: Colors.grey[600]),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 6.0, vertical: 12.0),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: _primaryColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: _primaryColor.withOpacity(0.5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: _primaryColor, width: 2),
                                ),
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
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<StockMovementType>(
                              value: _selectedType,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Type',
                                labelStyle: TextStyle(color: Colors.grey[600]),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 6.0, vertical: 12.0),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: _primaryColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: _primaryColor.withOpacity(0.5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: _primaryColor, width: 2),
                                ),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Tous les types'),
                                ),
                                ...StockMovementType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type.label),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredMovements.length,
                itemBuilder: (context, index) {
                  final movement = filteredMovements[index];
                  final store = Store.stores.firstWhere(
                    (s) => s['id'] == movement['storeId'],
                    orElse: () => {'name': 'Magasin inconnu'},
                  );
                  final isEntry =
                      movement['type'] == StockMovementType.entry.name;

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
                          color: isEntry
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isEntry ? Icons.add : Icons.remove,
                          color: isEntry ? Colors.green : Colors.orange,
                        ),
                      ),
                      title: Text(
                        movement['productName'],
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
                            'Magasin: ${store['name']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quantité: ${movement['quantity']} - ${movement['reason']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Date: ${_dateFormat.format(DateTime.parse(movement['date']))}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
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

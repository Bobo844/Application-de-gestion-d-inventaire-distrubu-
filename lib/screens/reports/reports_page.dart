import 'package:flutter/material.dart';
import '../../models/stock.dart';
import '../../models/store.dart';
import '../../models/product.dart';
import '../../models/supplier_order.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedReport = 'stock';
  String? _selectedStore;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  // Couleurs personnalisées
  final Color _primaryColor = const Color(0xFF2196F3);
  //final Color _accentColor = const Color(0xFF64B5F6);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

  List<Map<String, dynamic>> get _filteredMovements {
    return Stock.movements.where((movement) {
      final date = DateTime.parse(movement['date']);
      final isInDateRange = date.isAfter(_startDate) &&
          date.isBefore(_endDate.add(const Duration(days: 1)));

      if (_selectedStore != null) {
        return movement['storeId'] == _selectedStore && isInDateRange;
      }
      return isInDateRange;
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredOrders {
    return SupplierOrder.orders.where((order) {
      final date = DateTime.parse(order['date']);
      return date.isAfter(_startDate) &&
          date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Widget _buildStockReport() {
    final stockByProduct = <String, int>{};
    final valueByProduct = <String, double>{};

    for (var movement in _filteredMovements) {
      final productName = movement['productName'];
      final quantity = ((movement['quantity'] as num?) ?? 0).toInt();
      final type = movement['type'];

      stockByProduct[productName] = (stockByProduct[productName] ?? 0) +
          (type == StockMovementType.entry.name ? quantity : -quantity);

      final product = Product.products.firstWhere(
        (p) => p['name'] == productName,
        orElse: () => {'price': 0.0},
      );
      valueByProduct[productName] = (stockByProduct[productName] ?? 0) *
          ((product['price'] as num?)?.toDouble() ?? 0.0);
    }

    return Column(
      children: [
        Container(
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
            title: Text(
              'Valeur totale du stock',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Text(
              '${valueByProduct.values.fold(0.0, (sum, value) => sum + value)}€',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: stockByProduct.length,
            itemBuilder: (context, index) {
              final productName = stockByProduct.keys.elementAt(index);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
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
                  title: Text(
                    productName,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Quantité: ${stockByProduct[productName]}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Text(
                    '${valueByProduct[productName]}€',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovementsReport() {
    final entriesCount = _filteredMovements
        .where((m) => m['type'] == StockMovementType.entry.name)
        .length;
    final exitsCount = _filteredMovements
        .where((m) => m['type'] == StockMovementType.exit.name)
        .length;

    return Column(
      children: [
        Container(
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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Entrées',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$entriesCount',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Sorties',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$exitsCount',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredMovements.length,
            itemBuilder: (context, index) {
              final movement = _filteredMovements[index];
              final isEntry = movement['type'] == StockMovementType.entry.name;
              final store = Store.stores.firstWhere(
                (s) => s['id'] == movement['storeId'],
                orElse: () => {'name': 'Magasin inconnu'},
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
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
                  leading: CircleAvatar(
                    backgroundColor: isEntry
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    child: Icon(
                      isEntry ? Icons.add : Icons.remove,
                      color: isEntry ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(
                    movement['productName'],
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Magasin: ${store['name']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Quantité: ${(movement['quantity'] as num? ?? 0)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Date: ${_dateFormat.format(DateTime.parse(movement['date']))}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersReport() {
    final totalOrders = _filteredOrders.length;
    final totalValue = _filteredOrders.fold<double>(
      0,
      (sum, order) => sum + ((order['total'] as num?)?.toDouble() ?? 0.0),
    );

    return Column(
      children: [
        Container(
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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Nombre de commandes',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$totalOrders',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Valeur totale',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${totalValue.toStringAsFixed(2)}€',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredOrders.length,
            itemBuilder: (context, index) {
              final order = _filteredOrders[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
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
                  leading: CircleAvatar(
                    backgroundColor: _primaryColor.withOpacity(0.2),
                    child: Icon(Icons.shopping_cart, color: _primaryColor),
                  ),
                  title: Text(
                    'Commande ${order['reference']}',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: ${_dateFormat.format(DateTime.parse(order['date']))}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Statut: ${order['status']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Total: ${order['total']}€',
                        style: TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.w500,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Rapports',
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'stock',
                            label: Text('Stock'),
                            icon: Icon(Icons.inventory),
                          ),
                          ButtonSegment(
                            value: 'movements',
                            label: Text('Mouvements'),
                            icon: Icon(Icons.sync_alt),
                          ),
                          ButtonSegment(
                            value: 'orders',
                            label: Text('Commandes'),
                            icon: Icon(Icons.shopping_cart),
                          ),
                        ],
                        selected: {_selectedReport},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _selectedReport = newSelection.first;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return _primaryColor;
                              }
                              return Colors.grey[200]!;
                            },
                          ),
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.white;
                              }
                              return Colors.grey[800]!;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(2020),
                                  lastDate: _endDate,
                                );
                                if (date != null) {
                                  setState(() {
                                    _startDate = date;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date début',
                                  labelStyle:
                                      TextStyle(color: Colors.grey[600]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: _primaryColor),
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
                                child: Text(
                                  _dateFormat.format(_startDate),
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: _startDate,
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() {
                                    _endDate = date;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date fin',
                                  labelStyle:
                                      TextStyle(color: Colors.grey[600]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: _primaryColor),
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
                                child: Text(
                                  _dateFormat.format(_endDate),
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedReport != 'orders') ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedStore,
                          decoration: InputDecoration(
                            labelText: 'Magasin',
                            labelStyle: TextStyle(color: Colors.grey[600]),
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
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text(
                                'Tous les magasins',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                            ),
                            ...Store.stores.map((store) {
                              return DropdownMenuItem(
                                value: store['id'] as String,
                                child: Text(
                                  store['name'] as String,
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStore = value;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _selectedReport == 'stock'
                    ? _buildStockReport()
                    : _selectedReport == 'movements'
                        ? _buildMovementsReport()
                        : _buildOrdersReport(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

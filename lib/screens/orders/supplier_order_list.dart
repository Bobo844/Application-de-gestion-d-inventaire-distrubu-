import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/supplier_order.dart';
import '../../models/supplier.dart';
import 'supplier_order_form.dart';

class SupplierOrderListPage extends StatefulWidget {
  const SupplierOrderListPage({super.key});

  @override
  _SupplierOrderListPageState createState() => _SupplierOrderListPageState();
}

class _SupplierOrderListPageState extends State<SupplierOrderListPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // Couleurs personnalisées
  final Color _primaryColor = const Color(0xFF2196F3);
 // final Color _accentColor = const Color(0xFF64B5F6);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

  List<Map<String, dynamic>> get filteredOrders {
    List<Map<String, dynamic>> result = List.from(SupplierOrder.orders);

    if (_searchController.text.isNotEmpty) {
      result = result.where((order) {
        return order['reference']
            .toString()
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    }

    if (_selectedStatus != null) {
      result =
          result.where((order) => order['status'] == _selectedStatus).toList();
    }

    result.sort((a, b) =>
        DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    return result;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case SupplierOrder.STATUS_DRAFT:
        return Colors.grey;
      case SupplierOrder.STATUS_PENDING:
        return Colors.orange;
      case SupplierOrder.STATUS_RECEIVED:
        return Colors.green;
      case SupplierOrder.STATUS_CANCELLED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case SupplierOrder.STATUS_DRAFT:
        return 'Brouillon';
      case SupplierOrder.STATUS_PENDING:
        return 'En attente';
      case SupplierOrder.STATUS_RECEIVED:
        return 'Reçue';
      case SupplierOrder.STATUS_CANCELLED:
        return 'Annulée';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Commandes Fournisseurs',
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
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle Commande'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupplierOrderForm(),
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Rechercher une commande',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.search, color: _primaryColor),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear,
                                      color: Colors.grey[600]),
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
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Statut',
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
                              'Tous les statuts',
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ),
                          DropdownMenuItem(
                            value: SupplierOrder.STATUS_DRAFT,
                            child: Text(
                              _getStatusLabel(SupplierOrder.STATUS_DRAFT),
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ),
                          DropdownMenuItem(
                            value: SupplierOrder.STATUS_PENDING,
                            child: Text(
                              _getStatusLabel(SupplierOrder.STATUS_PENDING),
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ),
                          DropdownMenuItem(
                            value: SupplierOrder.STATUS_RECEIVED,
                            child: Text(
                              _getStatusLabel(SupplierOrder.STATUS_RECEIVED),
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ),
                          DropdownMenuItem(
                            value: SupplierOrder.STATUS_CANCELLED,
                            child: Text(
                              _getStatusLabel(SupplierOrder.STATUS_CANCELLED),
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  final supplier = Supplier.suppliers.firstWhere(
                    (s) => s['id'] == order['supplierId'],
                    orElse: () => {'name': 'Fournisseur inconnu'},
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
                        backgroundColor:
                            _getStatusColor(order['status']).withOpacity(0.2),
                        child: Icon(
                          Icons.shopping_cart,
                          color: _getStatusColor(order['status']),
                        ),
                      ),
                      title: Text(
                        order['reference'],
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fournisseur: ${supplier['name']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            'Date: ${_dateFormat.format(DateTime.parse(order['date']))}',
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order['status'])
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _getStatusLabel(order['status']),
                              style: TextStyle(
                                color: _getStatusColor(order['status']),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon:
                                Icon(Icons.more_vert, color: Colors.grey[600]),
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SupplierOrderForm(
                                      existingOrder: order,
                                    ),
                                  ),
                                ).then((_) => setState(() {}));
                              } else if (value == 'status') {
                                _showStatusChangeDialog(order);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: _primaryColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Modifier',
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                  ],
                                ),
                              ),
                              if (order['status'] !=
                                      SupplierOrder.STATUS_RECEIVED &&
                                  order['status'] !=
                                      SupplierOrder.STATUS_CANCELLED)
                                PopupMenuItem(
                                  value: 'status',
                                  child: Row(
                                    children: [
                                      Icon(Icons.update, color: _primaryColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Changer le statut',
                                        style:
                                            TextStyle(color: Colors.grey[800]),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
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

  void _showStatusChangeDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Changer le statut',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (order['status'] == SupplierOrder.STATUS_DRAFT)
              ListTile(
                title: Text(
                  _getStatusLabel(SupplierOrder.STATUS_PENDING),
                  style: TextStyle(color: Colors.grey[800]),
                ),
                onTap: () {
                  SupplierOrder.updateOrderStatus(
                    order['id'],
                    SupplierOrder.STATUS_PENDING,
                  );
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
            if (order['status'] == SupplierOrder.STATUS_PENDING) ...[
              ListTile(
                title: Text(
                  _getStatusLabel(SupplierOrder.STATUS_RECEIVED),
                  style: TextStyle(color: Colors.grey[800]),
                ),
                onTap: () {
                  SupplierOrder.updateOrderStatus(
                    order['id'],
                    SupplierOrder.STATUS_RECEIVED,
                  );
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  _getStatusLabel(SupplierOrder.STATUS_CANCELLED),
                  style: TextStyle(color: Colors.grey[800]),
                ),
                onTap: () {
                  SupplierOrder.updateOrderStatus(
                    order['id'],
                    SupplierOrder.STATUS_CANCELLED,
                  );
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
            ],
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

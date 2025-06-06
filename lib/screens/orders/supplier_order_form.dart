import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/supplier_order.dart';
import '../../models/supplier.dart';

class SupplierOrderForm extends StatefulWidget {
  final Map<String, dynamic>? existingOrder;

  const SupplierOrderForm({super.key, this.existingOrder});

  @override
  _SupplierOrderFormState createState() => _SupplierOrderFormState();
}

class _SupplierOrderFormState extends State<SupplierOrderForm> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _orderLines = [];
  String _status = 'draft';
  DateTime? _deliveryDate;
  String? _selectedSupplierId;

  // Couleurs personnalisées
  final Color _primaryColor = const Color(0xFF2196F3);
  //final Color _accentColor = const Color(0xFF64B5F6);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    if (widget.existingOrder != null) {
      _status = widget.existingOrder!['status'];
      _orderLines.addAll(
        List<Map<String, dynamic>>.from(widget.existingOrder!['products']),
      );
      _selectedSupplierId = widget.existingOrder!['supplierId'];
      if (widget.existingOrder!['deliveryDate'] != null) {
        _deliveryDate = DateTime.parse(widget.existingOrder!['deliveryDate']);
      }
    }
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) => ProductSelectionDialog(
        onProductSelected: (product, quantity, price) {
          setState(() {
            _orderLines.add({
              'productName': product['name'],
              'quantity': quantity,
              'price': price,
              'total': quantity * price,
            });
          });
        },
      ),
    );
  }

  double _calculateTotal() {
    return _orderLines.fold(0, (sum, line) => sum + (line['total'] as double));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.existingOrder == null
              ? 'Nouvelle Commande'
              : 'Modifier Commande',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          if (_orderLines.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Valider'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final orderData = {
                    'id': widget.existingOrder?['id'] ??
                        DateTime.now().toString(),
                    'reference': widget.existingOrder?['reference'] ??
                        'CMD${DateTime.now().millisecondsSinceEpoch}',
                    'supplierId': _selectedSupplierId,
                    'date': widget.existingOrder?['date'] ??
                        DateTime.now().toIso8601String(),
                    'status': _status,
                    'products': _orderLines,
                    'total': _calculateTotal(),
                    'deliveryDate': _deliveryDate?.toIso8601String(),
                    'lastUpdate': DateTime.now().toIso8601String(),
                  };

                  if (widget.existingOrder == null) {
                    SupplierOrder.orders.add(orderData);
                  } else {
                    final index = SupplierOrder.orders.indexWhere(
                      (order) => order['id'] == widget.existingOrder!['id'],
                    );
                    if (index != -1) {
                      SupplierOrder.orders[index] = orderData;
                    }
                  }

                  Navigator.pop(context);
                }
              },
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations de la commande',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedSupplierId,
                              decoration: InputDecoration(
                                labelText: 'Fournisseur',
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
                                  borderSide: BorderSide(
                                      color: _primaryColor, width: 2),
                                ),
                              ),
                              items: Supplier.suppliers
                                  .where((s) =>
                                      s['status'] == Supplier.STATUS_ACTIVE)
                                  .map((supplier) {
                                return DropdownMenuItem(
                                  value: supplier['id'] as String,
                                  child: Text(
                                    supplier['name'] as String,
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                );
                              }).toList(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez sélectionner un fournisseur';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _selectedSupplierId = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            _deliveryDate ?? DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now()
                                            .add(const Duration(days: 365)),
                                      );
                                      if (date != null) {
                                        setState(() {
                                          _deliveryDate = date;
                                        });
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Date de livraison',
                                        labelStyle:
                                            TextStyle(color: Colors.grey[600]),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: _primaryColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: _primaryColor
                                                  .withOpacity(0.5)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: _primaryColor, width: 2),
                                        ),
                                      ),
                                      child: Text(
                                        _deliveryDate == null
                                            ? 'Sélectionner une date'
                                            : '${_deliveryDate!.day}/${_deliveryDate!.month}/${_deliveryDate!.year}',
                                        style:
                                            TextStyle(color: Colors.grey[800]),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              'Produits',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.add, color: _primaryColor),
                              onPressed: _addProduct,
                            ),
                          ),
                          if (_orderLines.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Aucun produit ajouté',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _orderLines.length,
                              itemBuilder: (context, index) {
                                final line = _orderLines[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      line['productName'],
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Quantité: ${line['quantity']} - Prix: ${line['price']}€',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${line['total']}€',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _primaryColor,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red[400]),
                                          onPressed: () {
                                            setState(() {
                                              _orderLines.removeAt(index);
                                            });
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
                    ),
                  ],
                ),
              ),
              if (_orderLines.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_calculateTotal()}€',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductSelectionDialog extends StatefulWidget {
  final Function(Map<String, dynamic>, int, double) onProductSelected;

  const ProductSelectionDialog({super.key, required this.onProductSelected});

  @override
  _ProductSelectionDialogState createState() => _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<ProductSelectionDialog> {
  String? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  // Couleurs personnalisées
  final Color _primaryColor = const Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Ajouter un produit',
        style: TextStyle(
          color: Colors.grey[800],
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedProduct,
            decoration: InputDecoration(
              labelText: 'Produit',
              labelStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _primaryColor),
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
            items: Product.products.map((product) {
              return DropdownMenuItem(
                value: product['name'] as String,
                child: Text(
                  product['name'] as String,
                  style: TextStyle(color: Colors.grey[800]),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProduct = value;
                if (value != null) {
                  final product = Product.products.firstWhere(
                    (p) => p['name'] == value,
                  );
                  _priceController.text = product['price'].toString();
                }
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: 'Quantité',
              labelStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _primaryColor),
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
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Prix unitaire',
              labelStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _primaryColor),
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
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Annuler',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedProduct != null) {
              final product = Product.products.firstWhere(
                (p) => p['name'] == _selectedProduct,
              );
              widget.onProductSelected(
                product,
                int.parse(_quantityController.text),
                double.parse(_priceController.text),
              );
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

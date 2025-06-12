import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/store.dart';
import '../../models/stock.dart';

class StockMovementForm extends StatefulWidget {
  final String? storeId;
  final Map<String, dynamic>? initialProduct;
  final StockMovementType? initialType;

  const StockMovementForm({
    super.key,
    this.storeId,
    this.initialProduct,
    this.initialType,
  });

  @override
  _StockMovementFormState createState() => _StockMovementFormState();
}

class _StockMovementFormState extends State<StockMovementForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProduct;
  String? _selectedStore;
  StockMovementType _movementType = StockMovementType.entry;
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedStore = widget.storeId;
    if (widget.initialProduct != null) {
      _selectedProduct = widget.initialProduct!['name'];
    }
    if (widget.initialType != null) {
      _movementType = widget.initialType!;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final product = Product.products.firstWhere(
        (p) => p['name'] == _selectedProduct,
      );

      // Mettre à jour le stock
      final stockIndex = Stock.stockMovements.indexWhere(
        (stock) =>
            stock['storeId'] == _selectedStore &&
            stock['productName'] == _selectedProduct,
      );

      final quantity = int.parse(_quantityController.text);
      final finalQuantity =
          _movementType == StockMovementType.entry ? quantity : -quantity;

      if (stockIndex != -1) {
        Stock.stockMovements[stockIndex]['quantity'] =
            ((Stock.stockMovements[stockIndex]['quantity'] as num?) ?? 0) +
                finalQuantity;
        Stock.stockMovements[stockIndex]['lastUpdate'] =
            DateTime.now().toIso8601String();
      } else if (_movementType == StockMovementType.entry) {
        Stock.stockMovements.add({
          'id': DateTime.now().toString(),
          'storeId': _selectedStore,
          'productName': _selectedProduct,
          'quantity': quantity,
          'threshold': 5,
          'unit': product['unit'],
          'lastUpdate': DateTime.now().toIso8601String(),
        });
      }

      // Ajouter dans l'historique
      Stock.movements.add({
        'id': DateTime.now().toString(),
        'storeId': _selectedStore,
        'productName': _selectedProduct,
        'type': _movementType.name,
        'quantity': quantity,
        'date': DateTime.now().toIso8601String(),
        'reason': _reasonController.text,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mouvement de Stock'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.storeId == null)
                DropdownButtonFormField<String>(
                  value: _selectedStore,
                  decoration: const InputDecoration(
                    labelText: 'Magasin',
                    border: OutlineInputBorder(),
                  ),
                  items: Store.stores
                      .where((store) => store['status'] == Store.STATUS_ACTIVE)
                      .map((store) {
                    return DropdownMenuItem(
                      value: store['id'] as String,
                      child: Text(store['name'] as String),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un magasin';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedStore = value;
                    });
                  },
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedProduct,
                decoration: const InputDecoration(
                  labelText: 'Produit',
                  border: OutlineInputBorder(),
                ),
                items: widget.initialProduct != null
                    ? [
                        DropdownMenuItem(
                          value: widget.initialProduct!['name'] as String,
                          child: Text(widget.initialProduct!['name'] as String),
                        ),
                      ]
                    : Product.products.map((product) {
                        return DropdownMenuItem(
                          value: product['name'] as String,
                          child: Text(product['name'] as String),
                        );
                      }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un produit';
                  }
                  return null;
                },
                onChanged: widget.initialProduct != null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedProduct = value;
                        });
                      },
              ),
              const SizedBox(height: 16),
              SegmentedButton<StockMovementType>(
                segments: StockMovementType.values
                    .map(
                      (type) => ButtonSegment(
                        value: type,
                        label: Text(type.label),
                        icon: Icon(
                          type == StockMovementType.entry
                              ? Icons.add
                              : type == StockMovementType.exit
                                  ? Icons.remove
                                  : Icons.sync,
                        ),
                      ),
                    )
                    .toList(),
                selected: {_movementType},
                onSelectionChanged: widget.initialType != null
                    ? null
                    : (Set<StockMovementType> newSelection) {
                        setState(() {
                          _movementType = newSelection.first;
                        });
                      },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantité',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une quantité';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motif',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un motif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Valider',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}

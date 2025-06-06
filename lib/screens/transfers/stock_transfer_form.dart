import 'package:flutter/material.dart';
import '../../models/transfer.dart';
import '../../models/stock.dart';
import '../../models/notification.dart';
import '../../models/user_account.dart';
import '../../widgets/custom_drawer.dart';

class StockTransferForm extends StatefulWidget {
  const StockTransferForm({Key? key}) : super(key: key);

  @override
  _StockTransferFormState createState() => _StockTransferFormState();
}

class _StockTransferFormState extends State<StockTransferForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedFromStore;
  String? _selectedToStore;
  final List<Map<String, dynamic>> _items = [];
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedProduct;
        final quantityController = TextEditingController();
        String? selectedUnit;

        return AlertDialog(
          title: const Text('Ajouter un produit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Produit'),
                value: selectedProduct,
                items: Stock.stockMovements
                    .where((stock) => stock['storeId'] == _selectedFromStore)
                    .map((stock) => DropdownMenuItem<String>(
                          value: stock['productName'] as String,
                          child: Text(stock['productName'] as String),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedProduct = value;
                },
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantité'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Unité'),
                value: selectedUnit,
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                  DropdownMenuItem(value: 'g', child: Text('g')),
                  DropdownMenuItem(value: 'l', child: Text('l')),
                  DropdownMenuItem(value: 'ml', child: Text('ml')),
                  DropdownMenuItem(value: 'unité', child: Text('unité')),
                ],
                onChanged: (value) {
                  selectedUnit = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (selectedProduct != null &&
                    quantityController.text.isNotEmpty &&
                    selectedUnit != null) {
                  setState(() {
                    _items.add({
                      'productName': selectedProduct,
                      'quantity': double.parse(quantityController.text),
                      'unit': selectedUnit,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _submitTransfer() {
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      final currentUser = UserAccount.currentUser;
      if (currentUser != null) {
        Transfer.createTransfer(
          fromStoreId: _selectedFromStore!,
          toStoreId: _selectedToStore!,
          items: _items,
          userId: currentUser['id'] as String,
          reason: _reasonController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande de transfert créée avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    }
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

    final userStores = Stock.stockMovements
        .where((stock) => stock['storeId'] == currentUser['storeId'])
        .map((stock) => stock['storeId'] as String)
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau transfert'),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Magasin source'),
                value: _selectedFromStore,
                items: userStores.map((storeId) {
                  return DropdownMenuItem(
                    value: storeId,
                    child: Text('Magasin $storeId'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFromStore = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un magasin source';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Magasin destination'),
                value: _selectedToStore,
                items: Stock.stockMovements
                    .map((stock) => stock['storeId'] as String)
                    .toSet()
                    .where((storeId) => storeId != _selectedFromStore)
                    .map((storeId) {
                  return DropdownMenuItem(
                    value: storeId,
                    child: Text('Magasin $storeId'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedToStore = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un magasin destination';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration:
                    const InputDecoration(labelText: 'Raison du transfert'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Produits à transférer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._items.map((item) {
                return Card(
                  child: ListTile(
                    title: Text(item['productName']),
                    subtitle: Text('${item['quantity']} ${item['unit']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _items.remove(item);
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un produit'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitTransfer,
                child: const Text('Créer la demande de transfert'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

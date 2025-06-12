import 'package:flutter/material.dart';
import '../../models/transfer.dart';
import '../../models/stock.dart';
import '../../models/notification.dart';
import '../../models/user_account.dart';
import '../../models/store.dart';
import '../../widgets/custom_drawer.dart';

class StockTransferForm extends StatefulWidget {
  const StockTransferForm({Key? key}) : super(key: key);

  @override
  _StockTransferFormState createState() => _StockTransferFormState();
}

class _StockTransferFormState extends State<StockTransferForm> {
  // Custom colors for consistency
  final Color _primaryColor = const Color(0xFF2196F3);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

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

    // Get all stores from the Store model
    final allStores = Store.stores;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau transfert'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Magasin source',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  value: _selectedFromStore,
                  items: allStores.map((store) {
                    return DropdownMenuItem(
                      value: store['id'] as String,
                      child: Text(store['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFromStore = value;
                      if (_selectedToStore == value) {
                        _selectedToStore = null;
                      }
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
                  decoration: InputDecoration(
                    labelText: 'Magasin destination',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  value: _selectedToStore,
                  items: allStores
                      .where((store) => store['id'] != _selectedFromStore)
                      .map((store) {
                    return DropdownMenuItem(
                      value: store['id'] as String,
                      child: Text(store['name'] as String),
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
                  decoration: InputDecoration(
                    labelText: 'Raison du transfert',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Produits à transférer',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor),
                ),
                const SizedBox(height: 8),
                ..._items.map((item) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(item['productName'],
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('${item['quantity']} ${item['unit']}',
                          style: TextStyle(color: Colors.grey[600])),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[400]),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitTransfer,
                  child: const Text('Créer la demande de transfert'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

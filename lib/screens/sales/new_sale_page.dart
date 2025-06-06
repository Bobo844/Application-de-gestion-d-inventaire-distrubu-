import 'package:flutter/material.dart';
import '../../models/sale.dart';
import '../../models/stock.dart';
import '../../models/store.dart';
import '../../models/user_account.dart';
import '../../models/product.dart';

class NewSalePage extends StatefulWidget {
  const NewSalePage({super.key});

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  String? _selectedStoreId;
  String? _selectedUserId;
  String? _selectedProductId;

  List<Map<String, dynamic>> items = [];
  double total = 0.0;

  void _addItem() {
    if (_selectedProductId != null && _quantityController.text.isNotEmpty) {
      final int quantity = int.tryParse(_quantityController.text) ?? 0;

      // Récupérer le produit sélectionné
      final product = Product.products.firstWhere(
        (p) => p['id'] == _selectedProductId,
      );

      // Vérifier le stock
      final stockIndex = Stock.stockMovements.indexWhere(
        (stock) => stock['productName'] == product['name'],
      );

      if (stockIndex == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit non trouvé dans le stock')),
        );
        return;
      }

      if (Stock.stockMovements[stockIndex]['quantity'] < quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Stock insuffisant. Disponible: ${Stock.stockMovements[stockIndex]['quantity']}'),
          ),
        );
        return;
      }

      final double price = product['price'] as double;
      final double itemTotal = quantity * price;
      setState(() {
        items.add({
          'productName': product['name'],
          'quantity': quantity,
          'unitPrice': price,
          'totalPrice': itemTotal,
        });
        total += itemTotal;
        _quantityController.clear();
        _selectedProductId = null;
      });
    }
  }

  void _createSale() {
    if (_selectedStoreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un magasin')),
      );
      return;
    }

    if (_selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un vendeur')),
      );
      return;
    }

    double discount = double.tryParse(_discountController.text) ?? 0.0;
    if (items.isNotEmpty) {
      try {
        Sale.createSale(
          storeId: _selectedStoreId!,
          userId: _selectedUserId!,
          items: items,
          totalAmount: total,
          discount: discount,
          paymentMethod: 'cash',
        );
        setState(() {
          items.clear();
          total = 0.0;
          _discountController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vente enregistrée !')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Vente'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Formulaire de vente',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Sélection du magasin
              DropdownButtonFormField<String>(
                value: _selectedStoreId,
                decoration: const InputDecoration(
                  labelText: 'Magasin',
                  border: OutlineInputBorder(),
                ),
                items: Store.stores.map((store) {
                  return DropdownMenuItem<String>(
                    value: store['id'] as String,
                    child: Text(store['name'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStoreId = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Sélection du vendeur
              DropdownButtonFormField<String>(
                value: _selectedUserId,
                decoration: const InputDecoration(
                  labelText: 'Vendeur',
                  border: OutlineInputBorder(),
                ),
                items: UserAccount.users
                    .where((user) => user['role'] == UserAccount.ROLE_SELLER)
                    .map((user) {
                  return DropdownMenuItem<String>(
                    value: user['id'] as String,
                    child: Text('${user['firstName']} ${user['lastName']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUserId = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Sélection du produit
              DropdownButtonFormField<String>(
                value: _selectedProductId,
                decoration: const InputDecoration(
                  labelText: 'Produit',
                  border: OutlineInputBorder(),
                ),
                items: Product.products.map((product) {
                  return DropdownMenuItem<String>(
                    value: product['id'] as String,
                    child: Text('${product['name']} - ${product['price']}€'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProductId = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantité',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addItem,
                child: const Text('Ajouter le produit'),
              ),
              const SizedBox(height: 20),
              const Text('Produits ajoutés :'),
              ...items.map((item) => ListTile(
                    title: Text(item['productName']),
                    subtitle: Text(
                        'Quantité: ${item['quantity']} x ${item['unitPrice']}'),
                    trailing: Text('${item['totalPrice']}'),
                  )),
              const SizedBox(height: 20),
              TextField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Remise',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Text('Total: $total'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createSale,
                child: const Text('Enregistrer la vente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/store.dart';
import '../../models/stock.dart';
import 'product_form.dart';
import '../stocks/stock_movement_form.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  _ProductManagementPageState createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  // Couleurs personnalisées
  final Color _primaryColor = const Color(0xFF2196F3);
  //final Color _accentColor = const Color(0xFF64B5F6);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Toutes';
  final String _sortBy = 'name';
  bool _sortAscending = true;

  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> result = List.from(Product.products);

    // Filtrage par recherche
    if (_searchController.text.isNotEmpty) {
      result = result.where((product) {
        return product['name']
                .toString()
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            product['sku']
                .toString()
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
      }).toList();
    }

    // Filtrage par catégorie
    if (_selectedCategory != 'Toutes') {
      result = result
          .where((product) => product['category'] == _selectedCategory)
          .toList();
    }

    // Tri
    result.sort((a, b) {
      if (_sortAscending) {
        return a[_sortBy].toString().compareTo(b[_sortBy].toString());
      } else {
        return b[_sortBy].toString().compareTo(a[_sortBy].toString());
      }
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Gestion des Produits',
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
                'Nouveau Produit',
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
                    builder: (context) => const ProductFormPage(),
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
                      // Barre de recherche
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Rechercher un produit',
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
                            borderSide: BorderSide(
                                color: _primaryColor.withOpacity(0.5)),
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
                      // Filtres
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: _primaryColor.withOpacity(0.5)),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                decoration: InputDecoration(
                                  labelText: 'Catégorie',
                                  labelStyle: TextStyle(color: _primaryColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: 'Toutes',
                                    child: Text('Toutes les catégories'),
                                  ),
                                  ...Product.categories.map((category) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _primaryColor.withOpacity(0.5)),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _sortAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: _primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _sortAscending = !_sortAscending;
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
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun produit trouvé',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
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
                            leading: product['imagePath'] != null
                                ? (kIsWeb
                                    ? Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: _primaryColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.image,
                                            color: _primaryColor),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(product['imagePath']),
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ))
                                : Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child:
                                        Icon(Icons.image, color: _primaryColor),
                                  ),
                            title: Text(
                              product['name'],
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
                                  'Référence: ${product['sku']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Prix: ${product['price']} €',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Catégorie: ${product['category']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: _primaryColor),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductFormPage(
                                          product: product,
                                          index:
                                              Product.products.indexOf(product),
                                        ),
                                      ),
                                    ).then((_) => setState(() {}));
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                          'Confirmation',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: Text(
                                          'Voulez-vous vraiment supprimer le produit ${product['name']} ?',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                              'Annuler',
                                              style: TextStyle(
                                                  color: _primaryColor),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                Stock.movements.removeWhere(
                                                  (movement) =>
                                                      movement['productName'] ==
                                                      product['name'],
                                                );
                                                Stock.stockMovements
                                                    .removeWhere(
                                                  (stock) =>
                                                      stock['productName'] ==
                                                      product['name'],
                                                );
                                                Product.products
                                                    .remove(product);
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
                                IconButton(
                                  icon: Icon(Icons.info, color: _primaryColor),
                                  onPressed: () {
                                    _showStockDetails(product);
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

  void _showStockDetails(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final stockByStore = <String, int>{};

          // Calculer le stock par magasin
          for (var stock in Stock.stockMovements) {
            if (stock['productName'] == product['name']) {
              stockByStore[stock['storeId']] =
                  (stock['quantity'] as num? ?? 0).toInt();
            }
          }

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stock de ${product['name']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Entrée'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockMovementForm(
                                initialProduct: product,
                                initialType: StockMovementType.entry,
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.remove),
                        label: const Text('Sortie'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockMovementForm(
                                initialProduct: product,
                                initialType: StockMovementType.exit,
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Stock par magasin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: Store.stores.length,
                    itemBuilder: (context, index) {
                      final store = Store.stores[index];
                      final quantity = stockByStore[store['id']] ?? 0;
                      final stock = Stock.stockMovements.firstWhere(
                        (s) =>
                            s['storeId'] == store['id'] &&
                            s['productName'] == product['name'],
                        orElse: () => {'threshold': 0},
                      );
                      final isLowStock = quantity <= (stock['threshold'] ?? 0);

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isLowStock
                                ? Colors.red.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            child: Icon(
                              isLowStock ? Icons.warning : Icons.check,
                              color: isLowStock ? Colors.red : Colors.green,
                            ),
                          ),
                          title: Text(store['name']),
                          subtitle: Text(
                            'Seuil d\'alerte: ${stock['threshold'] ?? 'Non défini'}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$quantity ${product['unit']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isLowStock ? Colors.red : null,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showThresholdDialog(product, store['id']);
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
          );
        },
      ),
    );
  }

  void _showThresholdDialog(Map<String, dynamic> product, String storeId) {
    final controller = TextEditingController();
    final stock = Stock.stockMovements.firstWhere(
      (s) => s['storeId'] == storeId && s['productName'] == product['name'],
      orElse: () => {'threshold': 0},
    );
    controller.text = (stock['threshold'] ?? 0).toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le seuil d\'alerte'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nouveau seuil',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final threshold = int.tryParse(controller.text) ?? 0;
              final stockIndex = Stock.stockMovements.indexWhere(
                (s) =>
                    s['storeId'] == storeId &&
                    s['productName'] == product['name'],
              );

              if (stockIndex != -1) {
                setState(() {
                  Stock.stockMovements[stockIndex]['threshold'] = threshold;
                });
              } else {
                setState(() {
                  Stock.stockMovements.add({
                    'id': DateTime.now().toString(),
                    'storeId': storeId,
                    'productName': product['name'],
                    'quantity': 0,
                    'threshold': threshold,
                    'unit': product['unit'],
                    'lastUpdate': DateTime.now().toIso8601String(),
                  });
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

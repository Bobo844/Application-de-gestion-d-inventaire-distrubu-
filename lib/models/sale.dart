import 'stock.dart';
//import 'user_account.dart';

class Sale {
  static List<Map<String, dynamic>> sales = [];

  static const String STATUS_COMPLETED = 'completed';
  static const String STATUS_CANCELLED = 'cancelled';
  static const String STATUS_REFUNDED = 'refunded';

  static Map<String, dynamic> createSale({
    required String storeId,
    required String userId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    double discount = 0.0,
    required String paymentMethod,
  }) {
    // Vérifier le stock pour chaque produit
    for (var item in items) {
      final stockIndex = Stock.stockMovements.indexWhere(
        (stock) => stock['productName'] == item['productName'],
      );
      final itemQuantity = (item['quantity'] as num?) ?? 0;

      if (stockIndex == -1 ||
          ((Stock.stockMovements[stockIndex]['quantity'] as num?) ?? 0) <
              itemQuantity) {
        throw Exception('Stock insuffisant pour ${item['productName']}');
      }
    }

    final sale = {
      'id': DateTime.now().toString(),
      'storeId': storeId,
      'userId': userId,
      'items': items,
      'totalAmount': totalAmount,
      'discount': discount,
      'finalAmount': totalAmount - discount,
      'saleDate': DateTime.now().toIso8601String(),
      'paymentMethod': paymentMethod,
      'status': STATUS_COMPLETED,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
    sales.add(sale);

    // Mettre à jour le stock (sortie)
    for (var item in items) {
      final stockIndex = Stock.stockMovements.indexWhere(
        (stock) => stock['productName'] == item['productName'],
      );
      final itemQuantity = (item['quantity'] as num?) ?? 0;
      if (stockIndex != -1) {
        Stock.stockMovements[stockIndex]['quantity'] =
            ((Stock.stockMovements[stockIndex]['quantity'] as num?) ?? 0) -
                itemQuantity;
        Stock.stockMovements[stockIndex]['lastUpdate'] =
            DateTime.now().toIso8601String();
      }
    }
    return sale;
  }

  static void updateSaleStatus(String saleId, String newStatus) {
    final index = sales.indexWhere((sale) => sale['id'] == saleId);
    if (index != -1) {
      sales[index]['status'] = newStatus;
      sales[index]['lastUpdate'] = DateTime.now().toIso8601String();
      // Si la vente est annulée ou remboursée, remettre les produits en stock
      if (newStatus == STATUS_CANCELLED || newStatus == STATUS_REFUNDED) {
        final items = sales[index]['items'] as List<Map<String, dynamic>>;
        for (var item in items) {
          final stockIndex = Stock.stockMovements.indexWhere(
            (stock) => stock['productName'] == item['productName'],
          );
          final itemQuantity = (item['quantity'] as num?) ?? 0;
          if (stockIndex != -1) {
            Stock.stockMovements[stockIndex]['quantity'] =
                ((Stock.stockMovements[stockIndex]['quantity'] as num?) ?? 0) +
                    itemQuantity;
            Stock.stockMovements[stockIndex]['lastUpdate'] =
                DateTime.now().toIso8601String();
          }
        }
      }
    }
  }

  // Méthode pour obtenir les statistiques de ventes par magasin
  static Map<String, Map<String, dynamic>> getSalesByStore() {
    Map<String, Map<String, dynamic>> storeStats = {};

    for (var sale in sales) {
      final storeId = sale['storeId'];
      if (!storeStats.containsKey(storeId)) {
        storeStats[storeId] = {
          'totalSales': 0.0,
          'numberOfSales': 0,
          'items': {},
        };
      }

      storeStats[storeId]!['totalSales'] +=
          (sale['finalAmount'] as num?) ?? 0.0;
      storeStats[storeId]!['numberOfSales']++;

      // Compter les produits vendus
      for (var item in sale['items']) {
        final productName = item['productName'];
        if (!storeStats[storeId]!['items'].containsKey(productName)) {
          storeStats[storeId]!['items'][productName] = 0;
        }
        storeStats[storeId]!['items'][productName] +=
            (item['quantity'] as num?) ?? 0;
      }
    }

    return storeStats;
  }

  // Méthode pour obtenir les statistiques de ventes par vendeur
  static Map<String, Map<String, dynamic>> getSalesBySeller() {
    Map<String, Map<String, dynamic>> sellerStats = {};

    for (var sale in sales) {
      final userId = sale['userId'];
      if (!sellerStats.containsKey(userId)) {
        sellerStats[userId] = {
          'totalSales': 0.0,
          'numberOfSales': 0,
          'items': {},
        };
      }

      sellerStats[userId]!['totalSales'] +=
          (sale['finalAmount'] as num?) ?? 0.0;
      sellerStats[userId]!['numberOfSales']++;

      // Compter les produits vendus
      for (var item in sale['items']) {
        final productName = item['productName'];
        if (!sellerStats[userId]!['items'].containsKey(productName)) {
          sellerStats[userId]!['items'][productName] = 0;
        }
        sellerStats[userId]!['items'][productName] +=
            (item['quantity'] as num?) ?? 0;
      }
    }

    return sellerStats;
  }
}

import 'stock.dart';

class SupplierOrder {
  static List<Map<String, dynamic>> orders = [];

  static const String STATUS_DRAFT = 'draft'; // Brouillon
  static const String STATUS_PENDING = 'pending'; // En attente
  static const String STATUS_APPROVED = 'approved';
  static const String STATUS_REJECTED = 'rejected';
  static const String STATUS_COMPLETED = 'completed';
  static const String STATUS_CANCELLED = 'cancelled'; // Annulée

  static Map<String, dynamic> createOrder({
    required String supplierId,
    required List<Map<String, dynamic>> products,
    String? reference,
    DateTime? deliveryDate,
  }) {
    final order = {
      'id': DateTime.now().toString(),
      'reference': reference ?? 'CMD${DateTime.now().millisecondsSinceEpoch}',
      'supplierId': supplierId,
      'products': products,
      'date': DateTime.now().toIso8601String(),
      'status': STATUS_DRAFT,
      'total': products.fold(
          0.0,
          (sum, product) =>
              sum +
              ((product['quantity'] as num? ?? 0) *
                  ((product['price'] as num?)?.toDouble() ?? 0.0))),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'lastUpdate': DateTime.now().toIso8601String(),
    };
    orders.add(order);
    return order;
  }

  static void updateOrderStatus(String orderId, String newStatus) {
    final index = orders.indexWhere((order) => order['id'] == orderId);
    if (index != -1) {
      orders[index]['status'] = newStatus;
      orders[index]['lastUpdate'] = DateTime.now().toIso8601String();

      // Si la commande est reçue, mettre à jour les stocks
      if (newStatus == STATUS_COMPLETED) {
        final products =
            orders[index]['products'] as List<Map<String, dynamic>>;
        for (var product in products) {
          // Mettre à jour le stock
          final stockIndex = Stock.stockMovements.indexWhere(
            (stock) => stock['productName'] == product['productName'],
          );
          if (stockIndex != -1) {
            Stock.stockMovements[stockIndex]['quantity'] =
                ((Stock.stockMovements[stockIndex]['quantity'] as num?) ?? 0) +
                    ((product['quantity'] as num?) ?? 0);
            Stock.stockMovements[stockIndex]['lastUpdate'] =
                DateTime.now().toIso8601String();
          }
        }
      }
    }
  }

  static void addReceivedStock(String orderId) {
    final order = orders.firstWhere((o) => o['id'] == orderId);
    if (order['status'] == STATUS_COMPLETED) {
      for (var product
          in (order['products'] as List).cast<Map<String, dynamic>>()) {
        // Assurez-vous que la quantité est un nombre et non nulle
        final quantityToAdd = (product['quantity'] as num? ?? 0).toInt();

        // Logique pour ajouter le stock au magasin approprié (à implémenter si ce n'est pas déjà fait)
        // Par exemple, vous devrez trouver le magasin destinataire et mettre à jour son stock
      }
    }
  }
}

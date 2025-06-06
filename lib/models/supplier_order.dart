import 'stock.dart';

class SupplierOrder {
  static List<Map<String, dynamic>> orders = [];

  static const String STATUS_DRAFT = 'draft'; // Brouillon
  static const String STATUS_PENDING = 'pending'; // En attente
  static const String STATUS_RECEIVED = 'received'; // Reçue
  static const String STATUS_CANCELLED = 'cancelled'; // Annulée

  static Map<String, dynamic> createOrder({
    required String reference,
    required String supplierId,
    required List<Map<String, dynamic>> products,
    required double total,
    String? deliveryDate,
  }) {
    final order = {
      'id': DateTime.now().toString(),
      'reference': reference,
      'supplierId': supplierId,
      'date': DateTime.now().toIso8601String(),
      'status': STATUS_DRAFT,
      'products': products,
      'total': total,
      'deliveryDate': deliveryDate,
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
      if (newStatus == STATUS_RECEIVED) {
        final products =
            orders[index]['products'] as List<Map<String, dynamic>>;
        for (var product in products) {
          // Mettre à jour le stock
          final stockIndex = Stock.stockMovements.indexWhere(
            (stock) => stock['productName'] == product['productName'],
          );
          if (stockIndex != -1) {
            Stock.stockMovements[stockIndex]['quantity'] +=
                product['quantity'] as int;
            Stock.stockMovements[stockIndex]['lastUpdate'] =
                DateTime.now().toIso8601String();
          }
        }
      }
    }
  }
}

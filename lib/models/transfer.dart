import 'stock.dart';
import 'notification.dart';
import 'user_account.dart';

class Transfer {
  static List<Map<String, dynamic>> transfers = [];

  static const String STATUS_PENDING = 'pending'; // En attente de validation
  static const String STATUS_APPROVED = 'approved'; // Validé par l'admin
  static const String STATUS_REJECTED = 'rejected'; // Refusé par l'admin
  static const String STATUS_COMPLETED = 'completed'; // Transfert effectué
  static const String STATUS_CANCELLED = 'cancelled'; // Annulé

  static Map<String, dynamic> createTransfer({
    required String fromStoreId,
    required String toStoreId,
    required List<Map<String, dynamic>> items,
    required String userId,
    String? reason,
  }) {
    final transfer = {
      'id': DateTime.now().toString(),
      'fromStoreId': fromStoreId,
      'toStoreId': toStoreId,
      'items': items,
      'userId': userId,
      'reason': reason,
      'date': DateTime.now().toIso8601String(),
      'status': STATUS_PENDING,
      'approvedBy': null,
      'approvedAt': null,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
    transfers.add(transfer);

    // Notifier les administrateurs
    final admins = UserAccount.users
        .where((user) => user['role'] == UserAccount.ROLE_ADMIN)
        .toList();
    for (var admin in admins) {
      SystemNotification.createNotification(
        type: SystemNotification.TYPE_TRANSFER,
        title: 'Nouvelle demande de transfert',
        message:
            'Une nouvelle demande de transfert a été créée par ${_getUserName(userId)}',
        userId: admin['id'] as String,
        relatedId: transfer['id'] as String,
      );
    }

    return transfer;
  }

  static void updateTransferStatus(String transferId, String newStatus,
      {String? approvedBy}) {
    final index =
        transfers.indexWhere((transfer) => transfer['id'] == transferId);
    if (index != -1) {
      final transfer = transfers[index];
      final oldStatus = transfer['status'];
      transfers[index]['status'] = newStatus;
      transfers[index]['lastUpdate'] = DateTime.now().toIso8601String();

      if (newStatus == STATUS_APPROVED) {
        transfers[index]['approvedBy'] = approvedBy;
        transfers[index]['approvedAt'] = DateTime.now().toIso8601String();
      }

      // Notifier le gestionnaire qui a créé la demande
      String notificationTitle;
      String notificationMessage;

      switch (newStatus) {
        case STATUS_APPROVED:
          notificationTitle = 'Transfert approuvé';
          notificationMessage =
              'Votre demande de transfert a été approuvée par ${_getUserName(approvedBy ?? 'un administrateur inconnu')}';
          break;
        case STATUS_REJECTED:
          notificationTitle = 'Transfert refusé';
          notificationMessage =
              'Votre demande de transfert a été refusée par ${_getUserName(approvedBy ?? 'un administrateur inconnu')}';
          break;
        case STATUS_COMPLETED:
          notificationTitle = 'Transfert complété';
          notificationMessage = 'Le transfert a été effectué avec succès';
          break;
        default:
          return;
      }

      SystemNotification.createNotification(
        type: SystemNotification.TYPE_TRANSFER,
        title: notificationTitle,
        message: notificationMessage,
        userId: transfer['userId'] as String,
        relatedId: transferId,
      );

      // Si le transfert est approuvé, effectuer le transfert de stock
      if (newStatus == STATUS_APPROVED) {
        final items = transfer['items'] as List<Map<String, dynamic>>;
        // Effectuer le transfert de stock sans modifier l'état de l'utilisateur
        for (var item in items) {
          // Vérifier le stock disponible dans le magasin source
          final fromStockIndex = Stock.stockMovements.indexWhere(
            (stock) =>
                stock['storeId'] == transfer['fromStoreId'] &&
                stock['productName'] == (item['productName'] as String?),
          );

          if (fromStockIndex != -1) {
            final currentQuantity =
                (Stock.stockMovements[fromStockIndex]['quantity'] as num?) ?? 0;
            final transferQuantity = (item['quantity'] as num?) ?? 0;

            if (currentQuantity >= transferQuantity) {
              // Diminuer le stock du magasin source
              Stock.stockMovements[fromStockIndex]['quantity'] =
                  currentQuantity - transferQuantity;
              Stock.stockMovements[fromStockIndex]['lastUpdate'] =
                  DateTime.now().toIso8601String();

              // Augmenter le stock du magasin destinataire
              final toStockIndex = Stock.stockMovements.indexWhere(
                (stock) =>
                    stock['storeId'] == transfer['toStoreId'] &&
                    stock['productName'] == (item['productName'] as String?),
              );

              if (toStockIndex != -1) {
                Stock.stockMovements[toStockIndex]['quantity'] =
                    ((Stock.stockMovements[toStockIndex]['quantity'] as num?) ??
                            0) +
                        transferQuantity;
                Stock.stockMovements[toStockIndex]['lastUpdate'] =
                    DateTime.now().toIso8601String();
              } else {
                // Si le produit n'existe pas dans le magasin destinataire, l'ajouter
                Stock.stockMovements.add({
                  'id': DateTime.now().toString(),
                  'storeId': transfer['toStoreId'],
                  'productName': item['productName'] as String? ?? 'N/A',
                  'quantity': transferQuantity,
                  'threshold': 0, // Valeur par défaut
                  'unit': item['unit'] as String? ?? 'N/A',
                  'lastUpdate': DateTime.now().toIso8601String(),
                });
              }

              // Ajouter les mouvements de stock à l'historique
              Stock.movements.add({
                'id': DateTime.now().toString(),
                'storeId': transfer['fromStoreId'],
                'productName': item['productName'] as String? ?? 'N/A',
                'type': StockMovementType.transfer.name,
                'quantity': transferQuantity,
                'date': DateTime.now().toIso8601String(),
                'reason': 'Transfert sortant',
              });
              Stock.movements.add({
                'id': DateTime.now().toString(),
                'storeId': transfer['toStoreId'],
                'productName': item['productName'] as String? ?? 'N/A',
                'type': StockMovementType.transfer.name,
                'quantity': transferQuantity,
                'date': DateTime.now().toIso8601String(),
                'reason': 'Transfert entrant',
              });
            } else {
              // Gérer le cas où le stock est insuffisant
              print(
                  'Stock insuffisant pour le produit ${item['productName']} dans le magasin source.');
            }
          } else {
            // Gérer le cas où le produit n'est pas trouvé dans le stock du magasin source
            print(
                'Produit ${item['productName']} non trouvé dans le stock du magasin source.');
          }
        }

        // Marquer le transfert comme complété
        transfers[index]['status'] = STATUS_COMPLETED;
      }
    }
  }

  static String _getUserName(String userId) {
    print('DEBUG: _getUserName called with userId: $userId');
    final user = UserAccount.users.firstWhere(
      (u) => u['id'] == userId,
      orElse: () => {},
    );
    // Safely access properties, provide default empty string if user map is empty or properties are null
    final firstName = user['firstName'] as String? ?? '';
    final lastName = user['lastName'] as String? ?? '';

    print('DEBUG: User found - firstName: $firstName, lastName: $lastName');

    if (firstName.isEmpty && lastName.isEmpty) {
      return 'Utilisateur Inconnu'; // Return a default name if no user or name found
    }
    return '$firstName $lastName';
  }
}

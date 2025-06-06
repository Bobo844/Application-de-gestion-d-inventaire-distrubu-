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
              'Votre demande de transfert a été approuvée par ${_getUserName(approvedBy!)}';
          break;
        case STATUS_REJECTED:
          notificationTitle = 'Transfert refusé';
          notificationMessage =
              'Votre demande de transfert a été refusée par ${_getUserName(approvedBy!)}';
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

        for (var item in items) {
          // Vérifier le stock disponible dans le magasin source
          final sourceStockIndex = Stock.stockMovements.indexWhere(
            (stock) =>
                stock['storeId'] == transfer['fromStoreId'] &&
                stock['productName'] == item['productName'],
          );

          if (sourceStockIndex != -1 &&
              Stock.stockMovements[sourceStockIndex]['quantity'] >=
                  item['quantity']) {
            // Déduire le stock du magasin source
            Stock.stockMovements[sourceStockIndex]['quantity'] -=
                item['quantity'];
            Stock.stockMovements[sourceStockIndex]['lastUpdate'] =
                DateTime.now().toIso8601String();

            // Ajouter le stock au magasin destination
            final destStockIndex = Stock.stockMovements.indexWhere(
              (stock) =>
                  stock['storeId'] == transfer['toStoreId'] &&
                  stock['productName'] == item['productName'],
            );

            if (destStockIndex != -1) {
              Stock.stockMovements[destStockIndex]['quantity'] +=
                  item['quantity'];
              Stock.stockMovements[destStockIndex]['lastUpdate'] =
                  DateTime.now().toIso8601String();
            } else {
              // Créer un nouveau mouvement de stock pour le magasin destination
              Stock.stockMovements.add({
                'storeId': transfer['toStoreId'],
                'productName': item['productName'],
                'quantity': item['quantity'],
                'unit': item['unit'],
                'lastUpdate': DateTime.now().toIso8601String(),
              });
            }
          }
        }

        // Marquer le transfert comme complété
        transfers[index]['status'] = STATUS_COMPLETED;
      }
    }
  }

  static String _getUserName(String userId) {
    final user = UserAccount.users.firstWhere(
      (u) => u['id'] == userId,
      orElse: () => {'firstName': 'Utilisateur', 'lastName': 'Inconnu'},
    );
    return '${user['firstName']} ${user['lastName']}';
  }
}

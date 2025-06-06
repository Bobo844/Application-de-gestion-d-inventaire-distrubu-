import 'package:flutter/material.dart';
import '../../models/transfer.dart';
import '../../models/user_account.dart';
import '../../models/notification.dart';
import '../../widgets/custom_drawer.dart';

class TransferHistoryPage extends StatefulWidget {
  const TransferHistoryPage({Key? key}) : super(key: key);

  @override
  _TransferHistoryPageState createState() => _TransferHistoryPageState();
}

class _TransferHistoryPageState extends State<TransferHistoryPage> {
  String _selectedStatus = 'all';

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

    final isAdmin = currentUser['role'] == UserAccount.ROLE_ADMIN;
    final userStoreId = currentUser['storeId'] as String;

    // Filtrer les transferts selon le rôle de l'utilisateur et le statut sélectionné
    final transfers = Transfer.transfers.where((transfer) {
      final matchesStatus =
          _selectedStatus == 'all' || transfer['status'] == _selectedStatus;

      if (isAdmin) {
        return matchesStatus;
      } else {
        return matchesStatus &&
            (transfer['fromStoreId'] == userStoreId ||
                transfer['toStoreId'] == userStoreId);
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des transferts'),
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Filtrer par statut',
                border: OutlineInputBorder(),
              ),
              value: _selectedStatus,
              items: [
                const DropdownMenuItem(value: 'all', child: Text('Tous')),
                DropdownMenuItem(
                    value: Transfer.STATUS_PENDING, child: Text('En attente')),
                DropdownMenuItem(
                    value: Transfer.STATUS_APPROVED, child: Text('Approuvé')),
                DropdownMenuItem(
                    value: Transfer.STATUS_REJECTED, child: Text('Refusé')),
                DropdownMenuItem(
                    value: Transfer.STATUS_COMPLETED, child: Text('Complété')),
                DropdownMenuItem(
                    value: Transfer.STATUS_CANCELLED, child: Text('Annulé')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final transfer = transfers[index];
                final items = transfer['items'] as List<Map<String, dynamic>>;
                final status = transfer['status'] as String;
                final date = DateTime.parse(transfer['date'] as String);
                final formattedDate = '${date.day}/${date.month}/${date.year}';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: Text('Transfert du $formattedDate'),
                    subtitle: Text('Statut: ${_getStatusText(status)}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('De: Magasin ${transfer['fromStoreId']}'),
                            Text('Vers: Magasin ${transfer['toStoreId']}'),
                            if (transfer['reason'] != null)
                              Text('Raison: ${transfer['reason']}'),
                            const SizedBox(height: 8),
                            const Text(
                              'Produits:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  '${item['productName']}: ${item['quantity']} ${item['unit']}',
                                ),
                              );
                            }).toList(),
                            if (isAdmin && status == Transfer.STATUS_PENDING)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Transfer.updateTransferStatus(
                                          transfer['id'],
                                          Transfer.STATUS_REJECTED,
                                          approvedBy:
                                              currentUser['id'] as String,
                                        );
                                        setState(() {});
                                      },
                                      child: const Text('Refuser'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        Transfer.updateTransferStatus(
                                          transfer['id'],
                                          Transfer.STATUS_APPROVED,
                                          approvedBy:
                                              currentUser['id'] as String,
                                        );
                                        setState(() {});
                                      },
                                      child: const Text('Approuver'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case Transfer.STATUS_PENDING:
        return 'En attente';
      case Transfer.STATUS_APPROVED:
        return 'Approuvé';
      case Transfer.STATUS_REJECTED:
        return 'Refusé';
      case Transfer.STATUS_COMPLETED:
        return 'Complété';
      case Transfer.STATUS_CANCELLED:
        return 'Annulé';
      default:
        return status;
    }
  }
}

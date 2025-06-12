import 'package:flutter/material.dart';
import '../../models/transfer.dart';
import '../../models/user_account.dart';
import '../../models/notification.dart';
import '../../widgets/custom_drawer.dart';

class TransferHistoryPage extends StatefulWidget {
  final String? transferIdToHighlight;
  const TransferHistoryPage({Key? key, this.transferIdToHighlight})
      : super(key: key);

  @override
  _TransferHistoryPageState createState() => _TransferHistoryPageState();
}

class _TransferHistoryPageState extends State<TransferHistoryPage> {
  String _selectedStatus = 'all';
  final Map<String, GlobalKey> _expansionTileKeys = {};

  // Couleurs personnalisées
  final Color _primaryColor = const Color(0xFF2196F3);
  final Color _accentColor = const Color(0xFF64B5F6);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToHighlightTransfer();
    });
  }

  void _scrollToHighlightTransfer() {
    if (widget.transferIdToHighlight != null) {
      final String targetId = widget.transferIdToHighlight!;
      _expansionTileKeys.putIfAbsent(targetId, () => GlobalKey());

      final GlobalKey? targetKey = _expansionTileKeys[targetId];
      if (targetKey != null && targetKey.currentContext != null) {
        Scrollable.ensureVisible(
          targetKey.currentContext!,
          alignment: 0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UserAccount.currentUser;
    final isAdmin = currentUser?['role'] == UserAccount.ROLE_ADMIN;
    final isManager = currentUser?['role'] == UserAccount.ROLE_MANAGER;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Historique des Transferts'),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Filtrer par statut',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
              padding: const EdgeInsets.all(16),
              itemCount: Transfer.transfers.length,
              itemBuilder: (context, index) {
                final transfer = Transfer.transfers[index];
                final status = transfer['status'] as String? ?? '';

                if (_selectedStatus != 'all' && status != _selectedStatus) {
                  return const SizedBox.shrink();
                }

                final String transferId = transfer['id'] as String? ?? '';
                _expansionTileKeys.putIfAbsent(transferId, () => GlobalKey());

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shadowColor: Colors.black.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    key: _expansionTileKeys[transferId],
                    title: Text(
                      'Transfert #${transfer['id']}',
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
                          'De: ${_getStoreName(transfer['fromStoreId'] as String? ?? '')}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Vers: ${_getStoreName(transfer['toStoreId'] as String? ?? '')}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Date: ${_formatDate(transfer['date'] as String? ?? '')}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusText(status),
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Produits transférés',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...(transfer['items'] as List<Map<String, dynamic>>)
                                .map((item) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.inventory,
                                            color: _primaryColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['name'] as String? ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  'Quantité: ${item['quantity']}',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            if (transfer['reason'] != null) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Raison',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF2196F3),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  transfer['reason'] as String? ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                            if (isAdmin &&
                                status == Transfer.STATUS_PENDING) ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Transfer.updateTransferStatus(
                                        (transfer['id'] as String? ?? ''),
                                        Transfer.STATUS_REJECTED,
                                        approvedBy:
                                            currentUser?['id'] as String?,
                                      );

                                      SystemNotification.createNotification(
                                        type: SystemNotification.TYPE_TRANSFER,
                                        title: 'Transfert refusé',
                                        message:
                                            'Votre demande de transfert a été refusée.',
                                        userId: transfer['userId'] as String,
                                        relatedId: transfer['id'] as String,
                                      );

                                      setState(() {});

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Demande de transfert refusée avec succès.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Refuser'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      Transfer.updateTransferStatus(
                                        (transfer['id'] as String? ?? ''),
                                        Transfer.STATUS_APPROVED,
                                        approvedBy:
                                            currentUser?['id'] as String?,
                                      );

                                      SystemNotification.createNotification(
                                        type: SystemNotification.TYPE_TRANSFER,
                                        title: 'Transfert approuvé',
                                        message:
                                            'Votre demande de transfert a été approuvée. Vous pouvez maintenant procéder au transfert des produits.',
                                        userId: transfer['userId'] as String,
                                        relatedId: transfer['id'] as String,
                                      );

                                      setState(() {});

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Demande de transfert approuvée avec succès.'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Approuver'),
                                  ),
                                ],
                              ),
                            ],
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

  String _getStoreName(String storeId) {
    return 'Magasin $storeId';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return 'Date invalide';
    }
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
        return 'Statut inconnu';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case Transfer.STATUS_PENDING:
        return Colors.orange;
      case Transfer.STATUS_APPROVED:
        return Colors.blue;
      case Transfer.STATUS_REJECTED:
        return Colors.red;
      case Transfer.STATUS_COMPLETED:
        return Colors.green;
      case Transfer.STATUS_CANCELLED:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}

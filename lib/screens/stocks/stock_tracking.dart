import 'package:flutter/material.dart';

class StoreStockPage extends StatefulWidget {
  final String storeId;

  const StoreStockPage({super.key, required this.storeId});

  @override
  State<StoreStockPage> createState() => _StoreStockPageState();
}

class _StoreStockPageState extends State<StoreStockPage> {
  // Implémentation à venir
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des Stocks'),
      ),
      body: const Center(
        child: Text('Page de suivi des stocks à implémenter'),
      ),
    );
  }
}

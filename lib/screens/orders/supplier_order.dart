import 'package:flutter/material.dart';

class SupplierOrderPage extends StatefulWidget {
  const SupplierOrderPage({super.key});

  @override
  State<SupplierOrderPage> createState() => _SupplierOrderPageState();
}

class _SupplierOrderPageState extends State<SupplierOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes Fournisseurs'),
      ),
      body: const Center(
        child: Text('Page des commandes à implémenter'),
      ),
    );
  }
}

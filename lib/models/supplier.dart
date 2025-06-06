class Supplier {
  static List<Map<String, dynamic>> suppliers = [
    {
      'id': '1',
      'name': 'Fournisseur A',
      'contact': 'contact@fournisseurA.com',
      'phone': '0123456789',
      'address': 'Adresse du fournisseur A',
      'status': 'active'
    }
  ];

  static const String STATUS_ACTIVE = 'active';
  static const String STATUS_INACTIVE = 'inactive';

  static Map<String, dynamic> addSupplier({
    required String name,
    required String contact,
    required String phone,
    required String address,
  }) {
    final supplier = {
      'id': DateTime.now().toString(),
      'name': name,
      'contact': contact,
      'phone': phone,
      'address': address,
      'status': STATUS_ACTIVE,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
    suppliers.add(supplier);
    return supplier;
  }

  static void updateSupplier(String id, Map<String, dynamic> data) {
    final index = suppliers.indexWhere((supplier) => supplier['id'] == id);
    if (index != -1) {
      suppliers[index] = {
        ...suppliers[index],
        ...data,
        'lastUpdate': DateTime.now().toIso8601String(),
      };
    }
  }

  static void deleteSupplier(String id) {
    suppliers.removeWhere((supplier) => supplier['id'] == id);
  }
}

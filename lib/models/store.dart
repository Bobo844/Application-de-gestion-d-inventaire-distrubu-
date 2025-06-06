class Store {
  static List<Map<String, dynamic>> stores = [];
  static const String STATUS_ACTIVE = 'actif';
  static const String STATUS_INACTIVE = 'inactif';

  static void addStore(Map<String, dynamic> store) {
    stores.add(store);
  }

  static void updateStore(int index, Map<String, dynamic> store) {
    if (index >= 0 && index < stores.length) {
      stores[index] = store;
    }
  }

  static void deleteStore(int index) {
    if (index >= 0 && index < stores.length) {
      stores.removeAt(index);
    }
  }

  static Map<String, dynamic>? getStoreById(String id) {
    try {
      return stores.firstWhere((store) => store['id'] == id);
    } catch (e) {
      return null;
    }
  }
}

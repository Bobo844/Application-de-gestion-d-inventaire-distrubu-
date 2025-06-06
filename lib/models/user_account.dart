class UserAccount {
  static const String ROLE_ADMIN = 'admin';
  static const String ROLE_MANAGER = 'manager';
  static const String ROLE_EMPLOYEE = 'employee';
  static const String ROLE_SELLER = 'seller';
  static const String STATUS_ACTIVE = 'active';
  static const String STATUS_INACTIVE = 'inactive';

  static List<Map<String, dynamic>> users = [
    {
      'id': '1',
      'username': 'admin',
      'firstName': 'Admin',
      'lastName': 'User',
      'email': 'admin@example.com',
      'password': 'admin123',
      'role': ROLE_ADMIN,
      'status': STATUS_ACTIVE,
      'storeId': '1',
    },
    {
      'id': '2',
      'username': 'manager',
      'firstName': 'Manager',
      'lastName': 'User',
      'email': 'manager@example.com',
      'password': 'manager123',
      'role': ROLE_MANAGER,
      'status': STATUS_ACTIVE,
      'storeId': '1',
    },
    {
      'id': '3',
      'username': 'seller1',
      'firstName': 'John',
      'lastName': 'Doe',
      'email': 'seller1@example.com',
      'password': 'seller123',
      'role': ROLE_SELLER,
      'status': STATUS_ACTIVE,
      'storeId': '1',
    },
  ];

  static Map<String, dynamic>? currentUser;

  static bool login(String username, String password) {
    final user = users.firstWhere(
      (user) =>
          user['username'] == username &&
          user['password'] == password &&
          user['status'] == STATUS_ACTIVE,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      currentUser = user;
      return true;
    }
    return false;
  }

  static void logout() {
    currentUser = null;
  }

  static bool isLoggedIn() {
    return currentUser != null;
  }

  static bool isAdmin() {
    return currentUser?['role'] == ROLE_ADMIN;
  }

  static bool isManager() {
    return currentUser?['role'] == ROLE_MANAGER;
  }

  static bool isEmployee() {
    return currentUser?['role'] == ROLE_EMPLOYEE;
  }

  static bool authenticate(String username, String password) {
    final user = users.firstWhere(
      (u) =>
          u['username'] == username &&
          u['password'] == password &&
          u['status'] == STATUS_ACTIVE,
      orElse: () => {},
    );
    return user.isNotEmpty;
  }

  static Map<String, dynamic> getUserByUsername(String username) {
    return users.firstWhere(
      (u) => u['username'] == username,
      orElse: () => {},
    );
  }

  static bool isUserAdmin(String username) {
    final user = getUserByUsername(username);
    return user['role'] == ROLE_ADMIN;
  }
}

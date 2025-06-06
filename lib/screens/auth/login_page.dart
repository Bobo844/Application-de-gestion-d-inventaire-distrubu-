import 'package:flutter/material.dart';
import '../../models/user_account.dart';
import '../dashboard/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLogin = true;
  String _selectedRole = UserAccount.ROLE_EMPLOYEE;

  // Couleurs personnalisées
  final Color _primaryColor = const Color(0xFF2196F3);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    // Créer l'admin par défaut s'il n'existe pas
    if (!UserAccount.users.any((u) => u['username'] == 'admin')) {
      UserAccount.users.add({
        'id': 'default_admin',
        'username': 'admin',
        'email': 'admin@admin.com',
        'password': 'admin123',
        'role': UserAccount.ROLE_ADMIN,
        'status': UserAccount.STATUS_ACTIVE,
      });
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case UserAccount.ROLE_ADMIN:
        return 'Administrateur';
      case UserAccount.ROLE_MANAGER:
        return 'Gestionnaire';
      case UserAccount.ROLE_EMPLOYEE:
        return 'Employé';
      default:
        return role;
    }
  }

  DropdownMenuItem<String> _buildRoleItem(String role, IconData icon) {
    return DropdownMenuItem<String>(
      value: role,
      child: Row(
        children: [
          Icon(icon, color: _primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            _getRoleLabel(role),
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_isLogin) {
      // Logique de connexion
      print('Tentative de connexion avec: ${_usernameController.text}');
      final success = UserAccount.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (success) {
        print('Connexion réussie pour: ${_usernameController.text}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
        );
      } else {
        print('Échec de la connexion pour: ${_usernameController.text}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nom d\'utilisateur ou mot de passe incorrect'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Logique d'inscription
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les mots de passe ne correspondent pas'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (UserAccount.users
          .any((u) => u['username'] == _usernameController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ce nom d\'utilisateur existe déjà'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Créer le nouvel utilisateur
      final newUser = {
        'id': DateTime.now().toString(),
        'username': _usernameController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': _selectedRole,
        'status': UserAccount.STATUS_ACTIVE,
      };

      print('Création d\'un nouvel utilisateur: ${newUser['username']}');

      // Ajouter l'utilisateur à la liste
      UserAccount.users.add(newUser);

      // Afficher un message de succès et pré-remplir les champs de connexion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Compte créé avec succès ! Vous pouvez maintenant vous connecter.'),
          backgroundColor: Colors.green,
        ),
      );

      // Pré-remplir les champs de connexion
      setState(() {
        _isLogin = true;
        _usernameController.text = newUser['username'] ?? '';
        _passwordController.text = newUser['password'] ?? '';
        _emailController.clear();
        _confirmPasswordController.clear();
        _firstNameController.clear();
        _lastNameController.clear();
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: TextStyle(
          color: Colors.grey[800],
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: _primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _primaryColor.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          _isLogin ? 'Connexion' : 'Création de compte',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_primaryColor.withOpacity(0.1), _backgroundColor],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.inventory,
                  size: 80,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 40),
              if (_isLogin) ...[
                _buildTextField(
                  controller: _usernameController,
                  label: 'Nom d\'utilisateur',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  icon: Icons.lock,
                  isPassword: true,
                ),
              ] else ...[
                _buildTextField(
                  controller: _usernameController,
                  label: 'Nom d\'utilisateur',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _firstNameController,
                  label: 'Prénom',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _lastNameController,
                  label: 'Nom',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  icon: Icons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmer le mot de passe',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Rôle',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.work, color: _primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: _primaryColor.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _primaryColor, width: 2),
                      ),
                    ),
                    items: [
                      _buildRoleItem(
                          UserAccount.ROLE_ADMIN, Icons.admin_panel_settings),
                      _buildRoleItem(
                          UserAccount.ROLE_MANAGER, Icons.manage_accounts),
                      _buildRoleItem(UserAccount.ROLE_EMPLOYEE, Icons.person),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value;
                        });
                      }
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isLogin ? 'Se connecter' : 'Créer un compte',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _usernameController.clear();
                    _emailController.clear();
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                    _firstNameController.clear();
                    _lastNameController.clear();
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Créer un nouveau compte'
                      : 'Déjà un compte ? Se connecter',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}

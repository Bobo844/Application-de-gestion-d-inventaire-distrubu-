import 'package:flutter/material.dart';
import '../../models/user_account.dart';

class UserFormPage extends StatefulWidget {
  final Map<String, dynamic>? user;

  const UserFormPage({super.key, this.user});

  @override
  _UserFormPageState createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _selectedRole = UserAccount.ROLE_MANAGER;
  bool _isActive = true;

  // Couleurs personnalisées
  final Color _primaryColor = const Color(0xFF2196F3);
  //final Color _accentColor = const Color(0xFF64B5F6);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _usernameController.text = widget.user!['username'];
      _emailController.text = widget.user!['email'];
      _firstNameController.text = widget.user!['firstName'] ?? '';
      _lastNameController.text = widget.user!['lastName'] ?? '';
      _selectedRole = widget.user!['role'];
      _isActive = widget.user!['status'] == UserAccount.STATUS_ACTIVE;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final userData = {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'role': _selectedRole,
        'status':
            _isActive ? UserAccount.STATUS_ACTIVE : UserAccount.STATUS_INACTIVE,
      };

      if (_passwordController.text.isNotEmpty) {
        userData['password'] = _passwordController.text;
      }

      if (widget.user == null) {
        // Nouvel utilisateur
        userData['id'] = DateTime.now().toString();
        UserAccount.users.add(userData);
      } else {
        // Mise à jour
        final index = UserAccount.users.indexWhere(
          (u) => u['id'] == widget.user!['id'],
        );
        if (index != -1) {
          userData['id'] = widget.user!['id'];
          if (_passwordController.text.isEmpty) {
            userData['password'] = widget.user!['password'];
          }
          UserAccount.users[index] = userData;
        }
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.user == null
              ? 'Nouvel Utilisateur'
              : 'Modifier l\'Utilisateur',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
          child: Form(
            key: _formKey,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nom d\'utilisateur',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.person, color: _primaryColor),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom d\'utilisateur';
                      }
                      if (widget.user == null &&
                          UserAccount.users
                              .any((u) => u['username'] == value)) {
                        return 'Ce nom d\'utilisateur existe déjà';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon:
                          Icon(Icons.person_outline, color: _primaryColor),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un prénom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon:
                          Icon(Icons.person_outline, color: _primaryColor),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.email, color: _primaryColor),
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
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un email';
                      }
                      if (!value.contains('@')) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: widget.user == null
                          ? 'Mot de passe'
                          : 'Nouveau mot de passe (optionnel)',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.lock, color: _primaryColor),
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
                    obscureText: true,
                    validator: (value) {
                      if (widget.user == null &&
                          (value == null || value.isEmpty)) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value != null &&
                          value.isNotEmpty &&
                          value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Rôle',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.admin_panel_settings,
                          color: _primaryColor),
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
                      DropdownMenuItem(
                        value: UserAccount.ROLE_ADMIN,
                        child: Text(
                          _getRoleLabel(UserAccount.ROLE_ADMIN),
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      ),
                      DropdownMenuItem(
                        value: UserAccount.ROLE_MANAGER,
                        child: Text(
                          _getRoleLabel(UserAccount.ROLE_MANAGER),
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Utilisateur actif',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      value: _isActive,
                      activeColor: _primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.user == null
                                  ? Colors.green
                                  : _primaryColor)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            widget.user == null ? Colors.green : _primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.user == null ? 'Ajouter' : 'Modifier',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case UserAccount.ROLE_ADMIN:
        return 'Administrateur';
      case UserAccount.ROLE_MANAGER:
        return 'Gestionnaire';
      default:
        return role;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}

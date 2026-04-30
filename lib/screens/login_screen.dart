import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginPasswordVisible = false;

  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  String _selectedRole = 'Donor';
  bool _regPasswordVisible = false;

  final List<String> _roles = ['Donor', 'Receiver', 'Volunteer'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B6D11),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.restaurant,
                    size: 45, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Community Food Rescue',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27500A)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rescue Food. Feed Lives.',
                style: TextStyle(
                    fontSize: 14, color: Color(0xFF3B6D11)),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF3B6D11),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF3B6D11),
                      tabs: const [
                        Tab(text: 'Login'),
                        Tab(text: 'Register'),
                      ],
                    ),
                    SizedBox(
                      height: 420,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLoginTab(),
                          _buildRegisterTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => _showSnack(
                    'Google Sign-In will work after Firebase setup!'),
                icon: const Icon(Icons.login,
                    color: Color(0xFF3B6D11)),
                label: const Text(
                  'Continue with Google',
                  style: TextStyle(color: Color(0xFF3B6D11)),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Color(0xFF3B6D11)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          TextField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration:
                _inputDecoration('Email', Icons.email_outlined),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _loginPasswordController,
            obscureText: !_loginPasswordVisible,
            decoration:
                _inputDecoration('Password', Icons.lock_outline)
                    .copyWith(
              suffixIcon: IconButton(
                icon: Icon(_loginPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () => setState(() =>
                    _loginPasswordVisible = !_loginPasswordVisible),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showSnack(
                  'Password reset email will be sent!'),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: Color(0xFF3B6D11)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (_loginEmailController.text.isEmpty ||
                  _loginPasswordController.text.isEmpty) {
                _showSnack('Please enter Email and Password!');
                return;
              }
              _showSnack(
                  'Login will work after Firebase setup!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B6D11),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          TextField(
            controller: _regNameController,
            decoration: _inputDecoration(
                'Full Name', Icons.person_outline),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _regEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration:
                _inputDecoration('Email', Icons.email_outlined),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _regPasswordController,
            obscureText: !_regPasswordVisible,
            decoration:
                _inputDecoration('Password', Icons.lock_outline)
                    .copyWith(
              suffixIcon: IconButton(
                icon: Icon(_regPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () => setState(() =>
                    _regPasswordVisible = !_regPasswordVisible),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRole,
                isExpanded: true,
                items: _roles
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Row(children: [
                            Icon(_roleIcon(role),
                                color: const Color(0xFF3B6D11),
                                size: 20),
                            const SizedBox(width: 8),
                            Text(role),
                          ]),
                        ))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedRole = val!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_regNameController.text.isEmpty ||
                  _regEmailController.text.isEmpty ||
                  _regPasswordController.text.isEmpty) {
                _showSnack('Please fill all fields!');
                return;
              }
              _showSnack(
                  'Register will work after Firebase setup!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B6D11),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Create Account',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF3B6D11)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Color(0xFF3B6D11), width: 2),
      ),
    );
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'Donor':
        return Icons.volunteer_activism;
      case 'Receiver':
        return Icons.food_bank;
      case 'Volunteer':
        return Icons.directions_bike;
      default:
        return Icons.person;
    }
  }
}
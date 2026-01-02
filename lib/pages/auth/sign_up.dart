import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skyporters/utils/api_constants.dart';
import 'dart:convert';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _serverError;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _serverError = null;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          're_password': _confirmPasswordController.text, // Required by Djoser
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          // Extracts first error message if available
          _serverError = data.values.first is List ? data.values.first[0] : "Registration failed";
        });
      }
    } catch (e) {
      setState(() => _serverError = "Connection error. Is the server running?");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Account Created"),
        content: const Text("Your account is ready! Please log in to continue."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to Login Page
            },
            child: const Text("GO TO LOGIN"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.indigo[900]),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.indigo[900]
                  ),
                ),
                const Text("Join our community of global porters", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 30),

                if (_serverError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(_serverError!, style: const TextStyle(color: Colors.red)),
                  ),

                // Username
                _buildField(_usernameController, "Username", Icons.person_outline),
                const SizedBox(height: 15),

                // Email
                _buildField(_emailController, "Email Address", Icons.email_outlined, isEmail: true),
                const SizedBox(height: 15),

                // Password
                _buildField(_passwordController, "Password", Icons.lock_outline, isPassword: true),
                const SizedBox(height: 15),

                // Confirm Password
                _buildField(_confirmPasswordController, "Confirm Password", Icons.lock_reset, isPassword: true, isConfirm: true),
                
                const SizedBox(height: 40),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SIGN UP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, 
      {bool isPassword = false, bool isEmail = false, bool isConfirm = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ) : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Required field";
        if (isEmail && !value.contains('@')) return "Enter a valid email";
        if (isPassword && value.length < 8) return "Min 8 characters";
        if (isConfirm && value != _passwordController.text) return "Passwords do not match";
        return null;
      },
    );
  }
}
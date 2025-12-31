import 'package:flutter/material.dart';
import '../navigation/main_navigation_page.dart';

class RegistrationPage extends StatefulWidget {
  final bool isTraveler;
  const RegistrationPage({super.key, required this.isTraveler});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isTraveler ? "Traveler Signup" : "Customer Signup"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create your Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
              ),
              const SizedBox(height: 30),
              _buildTextField("Full Name", Icons.person),
              const SizedBox(height: 15),
              _buildTextField("Email Address", Icons.email),
              const SizedBox(height: 15),
              _buildTextField("Phone Number", Icons.phone),
              const SizedBox(height: 15),
              _buildTextField("Password", Icons.lock, isPassword: true),

              if (widget.isTraveler) ...[
                const SizedBox(height: 15),
                _buildTextField("Passport Number (Optional for now)", Icons.badge),
              ],

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Logic to save user would go here
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavigationPage()),
                          (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isTraveler ? Colors.indigo : Colors.green[700],
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Complete Registration", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTextField(String label, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v!.isEmpty ? "Required field" : null,
    );
  }
}
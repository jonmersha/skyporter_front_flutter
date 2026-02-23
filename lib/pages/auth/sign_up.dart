// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:skyporters/utils/api_constants.dart';
// import 'dart:convert';

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});

//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final _formKey = GlobalKey<FormState>();

//   final _usernameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   String? _serverError;

//   // Skyport Brand Palette
//   final Color primaryDark = const Color(0xFF1A1A1A);
//   final Color accentGold = const Color(0xFFECAE0B);
//   final Color brandGreen = const Color(0xFF089348);

//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//       _serverError = null;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse(ApiConstants.register),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': _usernameController.text.trim(),
//           'email': _emailController.text.trim(),
//           'password': _passwordController.text,
//           're_password': _confirmPasswordController.text,
//         }),
//       );

//       if (response.statusCode == 201) {
//         if (mounted) {
//           _showSuccessDialog();
//         }
//       } else {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _serverError = data.values.first is List ? data.values.first[0] : "Registration failed";
//         });
//       }
//     } catch (e) {
//       setState(() => _serverError = "Connection error. Is the server running?");
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Icon(Icons.check_circle, color: brandGreen),
//             const SizedBox(width: 10),
//             const Text("Account Created", style: TextStyle(fontWeight: FontWeight.w900)),
//           ],
//         ),
//         content: const Text("Your Skyport account is ready! Please log in to start carrying or shipping."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: Text("GO TO LOGIN", style: TextStyle(color: brandGreen, fontWeight: FontWeight.w900)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryDark, size: 22),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 30),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "SKYPORT",
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w900,
//                     letterSpacing: 4,
//                     color: accentGold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Create Account",
//                   style: TextStyle(
//                     fontSize: 36,
//                     fontWeight: FontWeight.w900,
//                     color: primaryDark,
//                     letterSpacing: -1,
//                   ),
//                 ),
//                 const Text(
//                     "Join our global community of trusted porters.",
//                     style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500)
//                 ),
//                 const SizedBox(height: 30),

//                 if (_serverError != null)
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     margin: const EdgeInsets.only(bottom: 20),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
//                         const SizedBox(width: 10),
//                         Expanded(child: Text(_serverError!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600))),
//                       ],
//                     ),
//                   ),

//                 _buildField(_usernameController, "Username", Icons.person_outline_rounded),
//                 const SizedBox(height: 15),

//                 _buildField(_emailController, "Email Address", Icons.email_outlined, isEmail: true),
//                 const SizedBox(height: 15),

//                 _buildField(_passwordController, "Password", Icons.lock_outline_rounded, isPassword: true),
//                 const SizedBox(height: 15),

//                 _buildField(_confirmPasswordController, "Confirm Password", Icons.lock_reset_rounded, isPassword: true, isConfirm: true),

//                 const SizedBox(height: 40),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 60,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _register,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryDark,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//                     ),
//                     child: _isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text(
//                         "SIGN UP",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w900,
//                             letterSpacing: 1.5
//                         )
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildField(TextEditingController controller, String label, IconData icon,
//       {bool isPassword = false, bool isEmail = false, bool isConfirm = false}) {
//     return TextFormField(
//       controller: controller,
//       obscureText: isPassword && _obscurePassword,
//       style: const TextStyle(fontWeight: FontWeight.w600),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
//         prefixIcon: Icon(icon, color: primaryDark),
//         filled: true,
//         fillColor: Colors.grey.shade50,
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(18),
//           borderSide: BorderSide(color: Colors.grey.shade200),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(18),
//           borderSide: BorderSide(color: accentGold, width: 2),
//         ),
//         suffixIcon: isPassword ? IconButton(
//           icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.grey),
//           onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//         ) : null,
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) return "Required field";
//         if (isEmail && !value.contains('@')) return "Enter a valid email";
//         if (isPassword && value.length < 8) return "Min 8 characters";
//         if (isConfirm && value != _passwordController.text) return "Passwords do not match";
//         return null;
//       },
//     );
//   }
// }
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

  // Updated Controllers to match your API requirements
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _serverError;

  // Skyport Brand Palette
  final Color primaryDark = const Color(0xFF1A1A1A);
  final Color accentGold = const Color(0xFFECAE0B);
  final Color brandGreen = const Color(0xFF089348);

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
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'password': _passwordController.text,
          're_password': _confirmPasswordController
              .text, // Ensure your API uses re_password or password
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          // Grabs the first error message from the response map
          _serverError = data.values.first is List
              ? data.values.first[0].toString()
              : "Registration failed";
        });
      }
    } catch (e) {
      setState(
          () => _serverError = "Connection error. Please check your internet.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: brandGreen),
            const SizedBox(width: 10),
            const Text("Account Created",
                style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: const Text(
            "Your Skyport account is ready! Please log in to start carrying or shipping."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("GO TO LOGIN",
                style:
                    TextStyle(color: brandGreen, fontWeight: FontWeight.w900)),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: primaryDark, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("SKYPORT",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: accentGold)),
                const SizedBox(height: 8),
                Text("Create Account",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: primaryDark,
                        letterSpacing: -1)),
                const Text("Enter your details to join the network.",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 25),

                if (_serverError != null) _buildErrorBox(),

                // Row for Names
                Row(
                  children: [
                    Expanded(
                        child: _buildField(_firstNameController, "First Name",
                            Icons.badge_outlined)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _buildField(_lastNameController, "Last Name",
                            Icons.badge_outlined)),
                  ],
                ),
                const SizedBox(height: 15),

                _buildField(
                    _usernameController, "Username", Icons.alternate_email),
                const SizedBox(height: 15),

                _buildField(
                    _emailController, "Email Address", Icons.email_outlined,
                    isEmail: true),
                const SizedBox(height: 15),

                _buildField(_phoneController, "Phone Number",
                    Icons.phone_android_outlined,
                    isPhone: true),
                const SizedBox(height: 15),

                _buildField(
                    _passwordController, "Password", Icons.lock_outline_rounded,
                    isPassword: true),
                const SizedBox(height: 15),

                _buildField(_confirmPasswordController, "Confirm Password",
                    Icons.lock_reset_rounded,
                    isPassword: true, isConfirm: true),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("SIGN UP",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(_serverError!,
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller, String label, IconData icon,
      {bool isPassword = false,
      bool isEmail = false,
      bool isConfirm = false,
      bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : (isPhone ? TextInputType.phone : TextInputType.text),
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: primaryDark, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: accentGold, width: 2),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: Colors.grey,
                    size: 20),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Required";
        if (isEmail && !value.contains('@')) return "Invalid email";
        if (isPassword && value.length < 8) return "Min 8 chars";
        if (isConfirm && value != _passwordController.text) return "No match";
        return null;
      },
    );
  }
}

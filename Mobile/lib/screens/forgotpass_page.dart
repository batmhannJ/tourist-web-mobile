import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/login_page.dart';
import 'package:flutter_application_2/services/auth_services.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotpassPage extends StatefulWidget {
  const ForgotpassPage({Key? key}) : super(key: key);

  @override
  State<ForgotpassPage> createState() => _ForgotpassPageState();
}

class _ForgotpassPageState extends State<ForgotpassPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final AuthService authService = AuthService();
  bool otpSent = false;
  bool otpVerified = false;

  // Method to request OTP
  // Method to request OTP
void requestOtp() async {
  if (_formKey.currentState?.validate() ?? false) {
    String email = emailController.text;

    // Generate OTP
    String otp = generateOtp();

    // Store OTP locally
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('generatedOtp', otp);

    // Send OTP for the email
    await authService.sendOtpEmail(email, otp);

    setState(() {
      otpSent = true; // Update UI to show OTP input field
    });

    print('OTP: $otp'); // For debugging, print the OTP to the console
  }
}

  // Method to generate OTP
  String generateOtp() {
    var random = Random();
    int otp = random.nextInt(900000) + 100000; // Generates a 6-digit OTP
    return otp.toString();
  }

  // Method to verify OTP
  // Method to verify OTP
void verifyOtp() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? storedOtp = prefs.getString('generatedOtp');
  String enteredOtp = otpController.text;

  if (enteredOtp == storedOtp) {
    setState(() {
      otpVerified = true;
    });
  } else {
    print('Failed OTP Verification.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid OTP')),
    );
  }
}

  // Method to reset password
  void resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      String newPassword = newPasswordController.text;
      await authService.resetPassword(emailController.text, newPassword);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5B247A), Color(0xFF1BCEDF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Text(
                  'Please enter your email to search for your account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!otpSent) ...[
                        // Email Input Field
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Submit Button to Send OTP
                        ElevatedButton(
                          onPressed: requestOtp,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('Submit'),
                        ),
                      ] else if (!otpVerified) ...[
                        // OTP Input Field
                        TextFormField(
                          controller: otpController,
                          decoration: const InputDecoration(
                            labelText: 'Enter OTP',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the OTP';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Verify OTP Button
                        ElevatedButton(
                          onPressed: verifyOtp,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('Verify OTP'),
                        ),
                      ] else ...[
                        // New Password Input Field
                        TextFormField(
                          controller: newPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'New Password',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Change Password Button
                        ElevatedButton(
                          onPressed: resetPassword,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('Change Password'),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

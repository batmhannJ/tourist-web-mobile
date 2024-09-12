import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/login_page.dart';
import 'package:flutter_application_2/services/auth_services.dart';
import 'dart:math';

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

  void requestOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      String email = emailController.text;

      // Generate OTP
      String otp = generateOtp(); // Call OTP generation function

      // Send OTP for the email
      await authService.sendOtpEmail(email, otp); // Send the OTP via email

      setState(() {
        otpSent = true; // Update UI to show OTP input field
      });

      // You can also print the OTP for debugging purposes (optional)
      print('OTP: $otp');
    }
  }

    // Function to generate OTP
  String generateOtp() {
    var random = Random();
    int otp = random.nextInt(900000) + 100000; // Generates a 6-digit OTP
    return otp.toString();
  }

void verifyOtp() async {
  String otp = otpController.text;

  // Verify OTP
  bool success = await authService.verifyOtp(emailController.text, otp);
  
  if (success) {
    setState(() {
      otpVerified = true;
    });
  } else {
    // Display server's response for debugging
    print('Failed OTP Verification. Check the server response.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid OTP')),
    );
  }
}

  void resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      String newPassword = newPasswordController.text;
      await authService.resetPassword(emailController.text, newPassword); // Implement resetPassword method
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
                        ElevatedButton(
                          onPressed: requestOtp,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('Submit'),
                        ),
                      ] else if (!otpVerified) ...[
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
                        ElevatedButton(
                          onPressed: verifyOtp,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('Verify OTP'),
                        ),
                      ] else ...[
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
                        ElevatedButton(
                          onPressed: resetPassword,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
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

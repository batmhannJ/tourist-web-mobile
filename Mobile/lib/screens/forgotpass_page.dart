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

void requestOtp() async {
  if (_formKey.currentState?.validate() ?? false) {
    String email = emailController.text;

    String otp = generateOtp();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('generatedOtp', otp);

    await authService.sendOtpEmail(email, otp);

    setState(() {
      otpSent = true; 
    });

  }
}

  String generateOtp() {
    var random = Random();
    int otp = random.nextInt(900000) + 100000;
    return otp.toString();
  }

void verifyOtp() async {

  String enteredOtp = otpController.text;
  String email = emailController.text;

  bool isValid = await authService.verifyOtp(email, enteredOtp);

  if (isValid) {
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
  return GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Enter your email to retrieve your account.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
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
                            decoration: InputDecoration(
                              labelText: 'Email',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.email, color: Colors.orange),
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
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            child: const Text('Submit'),
                          ),
                        ] else if (!otpVerified) ...[
                          // OTP Input Field
                          TextFormField(
                            controller: otpController,
                            decoration: InputDecoration(
                              labelText: 'Enter OTP',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock, color: Colors.orange),
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
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            child: const Text('Verify OTP'),
                          ),
                        ] else ...[
                          // New Password Input Field
                          TextFormField(
                            controller: newPasswordController,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock, color: Colors.orange),
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
                              backgroundColor: Colors.orange,
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
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
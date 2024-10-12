import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/signup_page.dart';
import 'package:flutter_application_2/services/auth_services.dart';
import 'package:flutter_application_2/screens/forgotpass_page.dart';
import 'package:flutter_application_2/utilities/utils.dart';
import 'package:flutter_application_2/screens/Home/home_screen.dart';
import 'dart:async'; // Import Timer

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController(); // OTP Controller
  final AuthService authService = AuthService();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _otpSent = false;
  bool _isCooldownActive = false;
  int _countdown = 60;
  Timer? _timer;

  void sendOtp() async {
    if (_isCooldownActive) {
      showSnackBar(context, 'Please wait before requesting a new OTP.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await authService.sendOtp(emailController.text);
    setState(() {
      _isLoading = false;
      _otpSent = success;
    });

    if (success) {
      showSnackBar(context, 'OTP sent to your email.');
      startCountdown();
    } else {
      showSnackBar(context, 'Failed to send OTP. Please try again.');
    }
  }

  void startCountdown() {
    setState(() {
      _isCooldownActive = true;
      _countdown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isCooldownActive = false;
        });
      }
    });
  }

  void loginUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      bool isLoggedIn = await authService.signInUser(
        context: context,
        email: emailController.text,
        password: passwordController.text,
        otp: otpController.text,
      );

      if (!isLoggedIn) {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, 'Invalid email, password, or OTP. Please try again.');
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    _timer?.cancel();
    super.dispose();
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
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[200],
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
                          TextFormField(
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[200],
                              prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.orange,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: otpController, // OTP Input Field
                                    decoration: InputDecoration(
                                      labelText: 'OTP',
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter the OTP';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Send OTP Button
                                ElevatedButton(
                                  onPressed: _isCooldownActive || _isLoading ? null : sendOtp, // Disable if cooldown is active or loading
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    textStyle: const TextStyle(fontSize: 14),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                          _isCooldownActive
                                              ? 'Resend OTP ($_countdown)' // Show countdown
                                              : 'Send OTP',
                                        ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ForgotpassPage()),
                              );
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _otpSent ? (_isLoading ? null : loginUser) : null, // Disable if OTP not sent
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Login'),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupPage()),
                        );
                      },
                      child: const Text(
                        'Don\'t have an account? Sign Up',
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
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

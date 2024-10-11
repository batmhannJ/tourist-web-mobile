import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth_services.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final AuthService authService = AuthService();

  bool isOTPSent = false;
  bool isOTPVerified = false;
  bool isButtonDisabled = false;
  int cooldownTime = 30;

  void sendOTP() async {
    String email = emailController.text;
    if (email.isNotEmpty) {
      bool result = await authService.sendOtp(email);
      if (result) {
        setState(() {
          isOTPSent = true;
          isButtonDisabled = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent to $email')),
        );

        for (int i = cooldownTime; i > 0; i--) {
          await Future.delayed(Duration(seconds: 1));
          setState(() {
            cooldownTime = i;
          });
        }

        setState(() {
          isButtonDisabled = false;
          cooldownTime = 30;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email')),
      );
    }
  }

  void verifyOTP() async {
    String otp = otpController.text;
    String email = emailController.text;
    if (otp.isNotEmpty) {
      bool isValid = await authService.verifyOtp(email, otp);
      if (isValid) {
        setState(() {
          isOTPVerified = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email verified! You can now sign up.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid OTP, please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the OTP')),
      );
    }
  }

  void signupUser() {
    if (isOTPVerified) {
      authService.signUpUser(
        context: context, 
        email: emailController.text, 
        password: passwordController.text, 
        name: nameController.text
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
                      'SIGN UP',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
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
                                  enabled: !isOTPVerified,
                                ),
                              ),
                              const SizedBox(width: 10),

                              if (!isOTPVerified)
                                ElevatedButton(
                                  onPressed: isButtonDisabled ? null : sendOTP,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    textStyle: const TextStyle(fontSize: 14),
                                  ),
                                  child: const Text('Send OTP'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          if (isOTPSent && !isOTPVerified) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: otpController,
                                    decoration: InputDecoration(
                                      labelText: 'Enter OTP',
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter the OTP sent to your email';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: verifyOTP,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    textStyle: const TextStyle(fontSize: 14),
                                  ),
                                  child: const Text('Submit'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (isButtonDisabled) 
                              Text('Resend OTP in $cooldownTime seconds', style: TextStyle(color: Colors.red)),
                          ],

                          if (isOTPVerified) ...[
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey[200],
                                prefixIcon: const Icon(Icons.person, color: Colors.orange),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey[200],
                                prefixIcon: const Icon(Icons.lock, color: Colors.orange),
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
                            Align(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                onPressed: signupUser,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                                child: const Text('Sign Up'),
                              ),
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
                      child: const Text(
                        'Already have an account? Login',
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

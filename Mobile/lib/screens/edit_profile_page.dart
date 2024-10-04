import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/providers/user_provider.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({Key? key}) : super(key: key);

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  final AuthService authService = AuthService();
  bool _isLoading = false;
  bool _showConfirmPassword = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    nameController = TextEditingController(text: user.name);
    emailController = TextEditingController(text: user.email);
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateAccount() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final success = await authService.updateUserDetails(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text.isNotEmpty ? passwordController.text : null,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.updateUserDetails(nameController.text, emailController.text);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Account updated successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update account')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 234, 219, 181), Color.fromARGB(255, 237, 234, 170)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: passwordController,
                            decoration: const InputDecoration(
                              labelText: 'New Password (leave blank to keep current)',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                                  return 'Password must contain at least one uppercase letter';
                                }
                                if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
                                  return 'Password must contain at least one lowercase letter';
                                }
                                if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
                                  return 'Password must contain at least one number';
                                }
                                if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(value)) {
                                  return 'Password must contain at least one special character';
                                }
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _showConfirmPassword = value.isNotEmpty;
                              });
                            },
                          ),
                          if (_showConfirmPassword) ...[
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: confirmPasswordController,
                              decoration: const InputDecoration(
                                labelText: 'Confirm New Password',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value != passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _updateAccount,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            child: const Text('Update'),
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

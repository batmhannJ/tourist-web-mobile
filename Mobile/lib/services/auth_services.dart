import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/user.dart';
import 'package:flutter_application_2/providers/user_provider.dart';
import 'package:flutter_application_2/utilities/constants.dart';
import 'package:flutter_application_2/utilities/utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/screens/Home/home_screen.dart';
import 'package:flutter_application_2/screens/login_page.dart';

class AuthService {
    void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

    if (!passwordRegex.hasMatch(password)) {
      showSnackBar(
        context,
        'Password must be at least 6 characters long, contain at least one uppercase letter, one number, and one special character.',
      );
      return;
    }

    try {
      User user = User(
        id: '',
        name: name,
        email: email,
        password: password,
        role: 'tourist',
        token: '',
      );

      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            'Account created! Please verify your email.',
          );
          sendOtp(email);
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<bool> signInUser({
    required BuildContext context,
    required String email,
    required String password,
    required String otp,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context);

      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/login'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        final responseBody = jsonDecode(res.body);
        final token = responseBody['token'];

        bool isOtpValid = await verifyOtp(email, otp);

        if (isOtpValid && token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          userProvider.setUser(res.body);

          await prefs.setString('x-auth-token', token);
          await prefs.setString('loginTime', DateTime.now().toIso8601String());
          await prefs.setString('email', email);

          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
          return true;
        } else {
          showSnackBar(context, 'Invalid OTP. Please try again.');
          return false;
        }
      } else {
        showSnackBar(context, 'Login failed. Please check your credentials.');
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return false;
  }

  Future<bool> sendOtp(String email) async {
    try {
      String otp = generateOtp();
      await sendOtpEmail(email, otp);
      return true;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.uri}/api/verify-otp'),
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['success'];
      } else {
        throw Exception('Failed to verify OTP');
      }
    } catch (e) {
      print('OTP verification error: $e');
      return false;
    }
  }

  Future<void> sendOtpEmail(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.uri}/send-email'),
        body: jsonEncode({
          'to': email,
          'subject': 'Your OTP Code',
          'text': 'Your OTP code is $otp',
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send OTP email: ${response.body}');
      }
    } catch (e) {
      print('Error in sendOtpEmail: $e');
      throw Exception('Failed to send OTP email');
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.uri}/api/reset-password'),
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Password reset error: $e');
      return false;
    }
  }

  Future<Duration> getSessionDuration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loginTimeString = prefs.getString('loginTime');

    if (loginTimeString != null) {
      DateTime loginTime = DateTime.parse(loginTimeString);
      Duration sessionDuration = DateTime.now().difference(loginTime);
      return sessionDuration;
    } else {
      return Duration.zero;
    }
  }

Future<bool> updateUserDetails({
  required String name,
  required String email,
  String? password,
}) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-auth-token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final body = {
      'name': name,
      'email': email,
    };

    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    http.Response res = await http.put(
      Uri.parse('${Constants.uri}/api/update-user'),
      body: jsonEncode(body),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      await prefs.setString('name', name);
      await prefs.setString('email', email);
      print('User details updated locally and on server');
      return true;
    } else {
      final responseBody = jsonDecode(res.body);
      throw Exception('Failed to update user: ${responseBody['message']}');
    }
  } catch (e) {
    print('Failed to update user details: $e');
    return false;
  }
}


  String generateOtp() {
    return '123456';
  }

  Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('x-auth-token');
      await prefs.remove('name');
      await prefs.remove('email');
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<String?> getCurrentUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }
}

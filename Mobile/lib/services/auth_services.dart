import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/user.dart';
import 'package:flutter_application_2/providers/user_provider.dart';
import 'package:flutter_application_2/screens/Home/home_screen.dart';
import 'package:flutter_application_2/utilities/constants.dart';
import 'package:flutter_application_2/utilities/utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // SIGN UP USER
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
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
            'Account created! Login with the same credentials',
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // SIGN IN USER
  Future<void> signInUser({
    required BuildContext context,
    required String email,
    required String password,
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

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          userProvider.setUser(res.body);

          // Store token and login time in SharedPreferences
          await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);
          await prefs.setString('loginTime', DateTime.now().toIso8601String());

          navigator.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (route) => false,
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

Future<void> logout() async {
  try {
    // Clear the user data from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('x-auth-token'); // Remove the token
    await prefs.remove('name'); // Remove the name if you are storing it
    await prefs.remove('email'); // Remove the email if you are storing it
    // Add any other user-specific data you want to clear
  } catch (e) {
    print('Logout error: $e');
    // Handle any errors if necessary
  }
}


//Future<void> resetPassword(String email, String newPassword) async {
  // VERIFY OTP
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

  // SEND OTP EMAIL
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

  // RESET PASSWORD
  Future<void> resetPassword(String email, String newPassword) async {
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

      if (response.statusCode != 200) {
        throw Exception('Failed to reset password');
      }
    } catch (e) {
      print('Password reset error: $e');
    }
  }

  // GET SESSION DURATION
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

  // UPDATE USER DETAILS LOCALLY AND ON SERVER
  Future<bool> updateUserDetails({
    required String name,
    required String email,
    String? password,
  }) async {
    try {
      // Retrieve the token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Prepare the request body
      final body = {
        'name': name,
        'email': email,
      };

      // Add password if it's not null
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      // Make the HTTP PUT request to update user details on the server
      http.Response res = await http.put(
        Uri.parse('${Constants.uri}/api/update-user'),
        body: jsonEncode(body),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      // Check for successful status code (200 OK)
      if (res.statusCode == 200) {
        // Success - also update user details locally
        await prefs.setString('name', name);
        await prefs.setString('email', email);

        // Update password locally if provided
        if (password != null && password.isNotEmpty) {
          await prefs.setString('password', password);
        }

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
}

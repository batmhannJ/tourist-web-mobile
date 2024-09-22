import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: '', 
    name: '', 
    email: '', 
    password: '', 
    role: '', 
    token: ''
  );

  User get user => _user;

  void setUser(String userJson) {
    _user = User.fromJson(userJson);
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

  void updateUserDetails(String name, String email, {String? password}) {
    _user = _user.copyWith(name: name, email: email);
    if (password != null && password.isNotEmpty) {
      _user = _user.copyWith(password: password);
    }
    notifyListeners();
  }

  Future<void> fetchUserDetails() async {
    // Method to fetch user details from the server
    // This can be useful to refresh user data after login or profile update
    try {
      // Implement your logic to fetch user details
      // For example, make an HTTP request to fetch user details and update state
      // Assume you have a method to get user details from the server
      // final response = await http.get('your-api-endpoint');
      // if (response.statusCode == 200) {
      //   final user = User.fromJson(response.body);
      //   setUserFromModel(user);
      // } else {
      //   throw Exception('Failed to load user details');
      // }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  void clearUser() {
    _user = User(
      id: '', 
      name: '', 
      email: '', 
      password: '', 
      role: '', 
      token: ''
    );
    notifyListeners();
  }
}

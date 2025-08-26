import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'PasswordResetPage.dart';
import 'main.dart';
import 'package:testing_flutter/SignupPage.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    final response = await http.post(
      Uri.parse('http://192.168.1.66:3000/login'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Login successful, navigate to the next page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TestRoboServe()),
      );
    } else {
      // Login failed, show error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Invalid username or password.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _goToSignupPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupPage()),
    );
  }

  void _goToForgotPasswordPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordResetPage(context)), // Pass context to PasswordResetPage constructor
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.restaurant_menu,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to Robot-Serve',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _login(context),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => _goToSignupPage(context),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
              TextButton(
                onPressed: () => _goToForgotPasswordPage(context),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  Future<void> _signUp() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    // Add validation logic here if needed
    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Password Mismatch'),
            content: const Text('The passwords do not match.'),
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
      return;
    }

    final response = await http.post(
      Uri.parse('http://192.168.1.66:3000/signup'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Sign up successful, show success message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign Up Successful'),
            content: const Text('Your account has been created successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Close the sign-up page and go back to the login page
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Sign up failed, show error message
      final dynamic responseData = jsonDecode(response.body);
      final String errorMessage =
          responseData['error'] ?? 'Failed to sign up. Please try again.';
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign Up Failed'),
            content: Text(errorMessage),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
        backgroundColor: Colors.black45,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordResetPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  final BuildContext context; // Declare context as a field

  PasswordResetPage(this.context); // Constructor to receive context

  Future<void> _resetPassword(BuildContext context) async {
    final String username = _usernameController.text;
    final String newPassword = _newPasswordController.text;

    final response = await http.post(
      Uri.parse('http://192.168.1.66:3000/reset-password'),
      body: jsonEncode({'username': username, 'newPassword': newPassword}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Password Reset'),
            content: Text('Password reset successfully!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Password reset failed, show error message
      final dynamic responseData = jsonDecode(response.body);
      final String errorMessage =
          responseData['error'] ?? 'Failed to reset password. Please try again.';
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Password Reset Failed'),
            content: Text(errorMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
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
        title: Text('Forgot Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _resetPassword(context), // Pass context to _resetPassword
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Reset Password',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

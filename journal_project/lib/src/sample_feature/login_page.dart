import 'package:flutter/material.dart';
import 'package:journal_project/src/sample_feature/landing_page.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Handle login logic
              },
              child: Text('Login'),
            ),
            SizedBox(height: 16.0), // Space between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, LandingPage.routeName);
              },
              child: Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
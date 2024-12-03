import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});

  static const routeName = '/account_settings_view';

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: Center(
        child: isLoggedIn
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Settings',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(user.email ?? 'No email'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Add functionality to edit username
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Change Password'),
                      onTap: () {
                        // Add functionality to change password
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      },
                    ),
                  ],
                ),
              )
            : const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 100, color: Colors.red),
                    SizedBox(height: 20),
                    Text(
                      'You are not logged in.',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Please log in to view account settings.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                      // trailing: IconButton(
                      //   icon: const Icon(Icons.edit),
                      //   onPressed: () {
                      //     // Add functionality to edit username
                      //   },
                      // ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Change Password'),
                      onTap: () {
                        _changePassword(context);
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
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text('Delete Account'),
                      onTap: () {
                        _deleteAccount(context);
                      },
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 100, color: Colors.red),
                    const SizedBox(height: 20),
                    const Text(
                      'You are not logged in.',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please log in to view account settings.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _changePassword(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(hintText: 'Enter new password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await user.updatePassword(passwordController.text);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password changed successfully')),
                      );
                      Navigator.of(context).pop();
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to change password: $e')),
                    );
                  }
                }
              },
              child: const Text('Change'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Delete user record from Firestore
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                    // Delete user from Firebase Auth
                    await user.delete();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account deleted successfully')),
                      );
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete account: $e')),
                    );
                  }
                }
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
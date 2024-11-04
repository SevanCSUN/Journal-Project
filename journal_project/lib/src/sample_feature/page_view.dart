import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView({
    super.key,
    required this.pageTitle, // Add this line
  });

  final String pageTitle; // Add this line

  static const routeName = '/sample_item';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle), // Use the pageTitle here
      ),
      body: const Center(
        child: Text('More Information Here'),
      ),
    );
  }
}

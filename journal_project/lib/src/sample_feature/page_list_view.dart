import 'package:flutter/material.dart';
import 'sample_item_details_view.dart'; // Import the details view

/// Displays a list of pages for a given journal.
class PageListView extends StatelessWidget {
  final String journalName;
  final List<String> pages;

  const PageListView({
    super.key,
    required this.journalName,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('$journalName Pages'),
      ),
      body: ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];

          return ListTile(
            tileColor: isDarkTheme ? Colors.grey.shade800 : Colors.white,
            title: Text(page),
            onTap: () {
              // Navigate to SampleItemDetailsView when a page is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SampleItemDetailsView(pageTitle: page),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

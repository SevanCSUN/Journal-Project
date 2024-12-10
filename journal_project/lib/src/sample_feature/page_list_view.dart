import 'package:flutter/material.dart';
import 'indiv_page_view.dart'; // Import the details view

/// Displays a list of pages for a given journal.
class PageListView extends StatelessWidget {
  final String journalName;
  final String journalId; // Added journalId for context
  final List<Map<String, String>> pages; // List of maps containing pageId and title

  const PageListView({
    super.key,
    required this.journalName,
    required this.journalId,
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
      body: pages.isEmpty
          ? const Center(
              child: Text(
                'No pages found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final page = pages[index];
                final pageId = page['id']!;
                final pageTitle = page['title']!;

                return ListTile(
                  tileColor: isDarkTheme ? Colors.grey.shade800 : Colors.white,
                  title: Text(pageTitle),
                  onTap: () {
                    // Navigate to IndivPageView when a page is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IndivPageView(
                          pageId: pageId,
                          journalId: journalId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

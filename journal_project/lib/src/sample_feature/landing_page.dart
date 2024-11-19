import 'package:flutter/material.dart';
import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'page_list_view.dart';
import 'indiv_page_view.dart'; // Import the PageView

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
  });

  static const routeName = '/';
  final List<SampleItem> items;

  @override
  State<LandingPage> createState() => _LandingPage();
}

class _LandingPage extends State<LandingPage> {
  int focusedJournalIndex = 0; // Set initial focused journal to the first one
  bool showPageList = false; // variable for toggling the vertical page list

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal App Home-Page'),
        automaticallyImplyLeading: false, // Remove the back arrow
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container holds the 7 columns (days of the week)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 230, // Height for the container
                decoration: BoxDecoration(
                  color: isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade200, // background color
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // Add padding inside the container
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align the columns to the start and end
                        children: List.generate(7, (index) {
                          final days = ['MON', 'TUES', 'WED', 'THUR', 'FRI', 'SAT', 'SUN'];
                          return SizedBox(
                            width: 45, // width for each container
                            child: Column(
                              children: [
                                Text(
                                  days[index], // text for each day
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 8), // Space between label and rectangle
                                Container(
                                  height: 180, // Height of each rectangle
                                  decoration: BoxDecoration(
                                    color: isDarkTheme ? Colors.blue.shade700 : Colors.blue.shade100, // Placeholder color for the rectangles
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50), // Just adds space between weekly view and journals view
            // Horizontal journal list
            SizedBox(
              height: 150, // The height of the horizontal list
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.35, initialPage: focusedJournalIndex), // viewportFraction for scaling
                itemCount: widget.items.length + 1, // Add one more item for the placeholder
                onPageChanged: (index) {
                  setState(() {
                    focusedJournalIndex = index;
                    showPageList = false; // Close the vertical list when swiping to a new journal
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  if (index == widget.items.length) {
                    // Placeholder for creating a new journal
                    return Transform.scale(
                      scale: 0.85, // scaling for the placeholder
                      child: GestureDetector(
                        onTap: () {
                          // Action for creating a new journal
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8.0), // spacing between cards
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add, size: 60), // Placeholder icon
                                SizedBox(height: 10), // Space between icon and text
                                Text(
                                  'Create Journal',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final item = widget.items[index];

                  // Scale effect to show that a journal is focused
                  bool isFocused = focusedJournalIndex == index;

                  return Transform.scale(
                    scale: isFocused ? 1.0 : 0.85, // scaling for focused journal
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isFocused) {
                            if (showPageList) {
                              // If page list is already open, navigate to full list
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PageListView(
                                    journalName: 'Journal ${item.id}',
                                    pages: const ['Page 1', 'Page 2', 'Page 3'],
                                  ),
                                ),
                              );
                            } else {
                              // Toggle the vertical page list
                              showPageList = true;
                            }
                          }
                        });
                      },
                      // The container around the journal cards
                      child: Container(
                        margin: const EdgeInsets.all(8.0), // spacing between cards
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/placeholder_img.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10), // Space between image and text
                              Text(
                                'Journal ${item.id}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Show the vertical list of pages if showPageList is true and journal is focused
            if (showPageList && focusedJournalIndex != -1)
              Column(
                children: [
                  const SizedBox(height: 10), // just adds space between journal cards and page list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0), // Add padding inside the container
                        child: ListView.builder(
                          shrinkWrap: true, // takes only as much space as needed
                          physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this list
                          itemCount: 3 + 1, // Number of pages + 1 for the placeholder
                          itemBuilder: (context, index) {
                            if (index == 3) {
                              // Placeholder + button
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Action for adding a new page
                                  },
                                  child: const Text('+'),
                                ),
                              );
                            }
                            return ListTile(
                              title: Text('Page ${index + 1}'),
                              onTap: () {
                                // Navigate to the selected page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IndivPageView(
                                      pageTitle: 'Page ${index + 1}',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

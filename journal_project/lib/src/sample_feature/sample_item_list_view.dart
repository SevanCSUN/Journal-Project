import 'package:flutter/material.dart';
import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'page_list_view.dart';

class SampleItemListView extends StatefulWidget {
  const SampleItemListView({
    super.key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
  });

  static const routeName = '/';
  final List<SampleItem> items;

  @override
  State<SampleItemListView> createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  int focusedJournalIndex = -1; // variable for the focused journal
  bool showPageList = false; // variable for toggling the vertical page list

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal App Home-Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Container holds the 7 columns (days of the week)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 200, // Height for the container
              decoration: BoxDecoration(
                color: Colors.grey.shade200, // background color
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Even spacing between rectangles
                  children: List.generate(7, (index) {
                    return Container(
                      width: 45, //  width for each rectangle
                      height: 180, // Height of each rectangle
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100, // Placeholder color for the rectangles
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'Day ${index + 1}', // Placeholder text for the day
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // Push content to the bottom w/ a Spacer
          const Spacer(),
          
          // Horizontal journal list
          SizedBox(
            height: 150, // The height of the horizontal list
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.35), // viewportFraction for scaling
              itemCount: widget.items.length,
              onPageChanged: (index) {
                // Close the vertical list when swiping to a new journal
                if (focusedJournalIndex != index) {
                  setState(() {
                    showPageList = false;
                    focusedJournalIndex = index;
                  });
                }
              },
              itemBuilder: (BuildContext context, int index) {
                final item = widget.items[index];

                // Scale effect to indicate focused journal
                bool isFocused = focusedJournalIndex == index;

                return Transform.scale(
                  scale: isFocused ? 1.0 : 0.85, // Adjusted scaling
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (focusedJournalIndex == index) {
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
                        } else {
                          // Set the focused journal and show the page list
                          focusedJournalIndex = index;
                          showPageList = true;
                        }
                      });
                    },
                    // The explicit container around the card
                    child: Container(
                      margin: const EdgeInsets.all(8.0), // Add margin for spacing between cards
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60, // Ensured square size for the image
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
                              style: const TextStyle(fontSize: 14), // Adjusted font size
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
                const SizedBox(height: 10), // Add some spacing below the journal
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                    child: ListView.builder(
                      shrinkWrap: true, // take only as much space as needed
                      physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this list
                      itemCount: 3, // Number of pages
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Page ${index + 1}'),
                          onTap: () {
                            // Navigate to the selected page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PageListView(
                                  journalName: 'Journal ${focusedJournalIndex + 1}',
                                  pages: ['Page ${index + 1}'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

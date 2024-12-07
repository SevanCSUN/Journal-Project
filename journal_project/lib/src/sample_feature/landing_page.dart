import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'indiv_page_view.dart';
import 'journal_page_view.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
  });

  static const routeName = '/landing';
  final List<SampleItem> items;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int focusedJournalIndex = 0; // Initial focused journal
  bool showPageList = false; // Toggle for showing the vertical page list
  List<Map<String, dynamic>> pages = []; // Store pages for the focused journal
  bool isLoadingPages = false;
  List<Map<String, dynamic>> journals = []; // List of journals fetched from Firestore
  bool isLoadingJournals = true; // Loading indicator for journals

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    setState(() {
      isLoadingJournals = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .get();

      setState(() {
        journals = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading journals: $e')),
      );
    } finally {
      setState(() {
        isLoadingJournals = false;
      });
    }
  }

  Future<void> _fetchPages(String journalId) async {
    setState(() {
      isLoadingPages = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .doc(journalId)
          .collection('pages')
          .get();

      setState(() {
        pages = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pages: $e')),
      );
    } finally {
      setState(() {
        isLoadingPages = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal App Home-Page'),
        automaticallyImplyLeading: false,
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
            const SizedBox(height: 50), // Space between weekly view and journal list

            // Horizontal journal list
            SizedBox(
              height: 150, // Height of the horizontal list
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.35, initialPage: 0),
                itemCount: journals.length + 1, // Journals + the fixed leftmost +
                onPageChanged: (index) {
                  setState(() {
                    focusedJournalIndex = index;
                    showPageList = false; // Close the vertical page list when swiping
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  bool isFocused = focusedJournalIndex == index;

                  if (index == 0) {
                    // Fixed + button for creating a new journal
                    return Transform.scale(
                      scale: isFocused ? 1.0 : 0.85, // Scaling effect for focus
                      child: GestureDetector(
                        onTap: () async {
                          // Action for creating a new journal
                          final newJournalTitle = await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              String journalTitle = '';
                              return AlertDialog(
                                title: const Text('Create New Journal'),
                                content: TextField(
                                  onChanged: (value) {
                                    journalTitle = value;
                                  },
                                  decoration: const InputDecoration(hintText: 'Enter journal title'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Cancel
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, journalTitle); // Return entered title
                                    },
                                    child: const Text('Create'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (newJournalTitle != null && newJournalTitle.trim().isNotEmpty) {
                            try {
                              await _createJournal(newJournalTitle.trim());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Journal "$newJournalTitle" created successfully.')),
                              );
                              setState(() {
                                // Optionally update UI if local state is used
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error creating journal: $e')),
                              );
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8.0), // Spacing between cards
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 60), // + Icon
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

                  final journal = journals[index - 1]; // Adjust index to skip the + button

                  // Scale effect to show focus
                  return Transform.scale(
                    scale: isFocused ? 1.0 : 0.85,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isFocused) {
                            if (showPageList) {
                              // Navigate to full list of pages
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JournalPage(
                                    journalName: journal['title'],
                                    journalId: journal['id'],
                                  ),
                                ),
                              );
                            } else {
                              // Toggle vertical page list
                              showPageList = true;
                              _fetchPages(journal['id']);
                            }
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8.0), // Spacing between cards
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
                                journal['title'] ?? 'Untitled Journal', // Use journal title
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
                  const SizedBox(height: 10), // Space between journal cards and page list
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
                          shrinkWrap: true, // Takes only as much space as needed
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pages.length + 1, // Add one for the + button
                          itemBuilder: (context, index) {
                            if (index == pages.length) {
                              // + Button
                              return ElevatedButton(
                                onPressed: () async {
                                  final newPageTitle = await showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      String pageTitle = '';
                                      return AlertDialog(
                                        title: const Text('Create New Page'),
                                        content: TextField(
                                          onChanged: (value) {
                                            pageTitle = value;
                                          },
                                          decoration: const InputDecoration(hintText: 'Enter page title'),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, pageTitle);
                                            },
                                            child: const Text('Create'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (newPageTitle != null && newPageTitle.trim().isNotEmpty) {
                                    final journalId = journals[focusedJournalIndex - 1]['id'];
                                    await _addPageToJournal(journalId, newPageTitle.trim());
                                  }
                                },
                                child: const Text('+ Add Page'),
                              );
                            }

                            final page = pages[index];
                            return ListTile(
                              title: Text(page['title']),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IndivPageView(pageTitle: page['title']),
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

  Future<void> _createJournal(String journalTitle) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final journalId = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .doc()
        .id;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .doc(journalId)
        .set({
      'title': journalTitle,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      journals.add({'id': journalId, 'title': journalTitle});
    });
  }

  Future<void> _addPageToJournal(String journalId, String pageTitle) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final pageId = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .doc(journalId)
        .collection('pages')
        .doc()
        .id;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .doc(journalId)
        .collection('pages')
        .doc(pageId)
        .set({
      'title': pageTitle,
      'content': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add to the local pages list
    setState(() {
      pages.add({'id': pageId, 'title': pageTitle});
    });
  }
}

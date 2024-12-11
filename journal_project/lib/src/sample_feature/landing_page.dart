import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../settings/settings_view.dart';
import 'journal_page_view.dart';
import 'journal_manager.dart';
import 'indiv_page_view.dart';
import 'task.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
  });

  static const routeName = '/landing';

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
  Map<DateTime, List<Task>> weeklyTasks = {}; // Weekly tasks from all journals
  final JournalManager _journalManager = JournalManager();

  @override
  void initState() {
    super.initState();
    _loadJournals();
    _fetchWeeklyTasks();
  }

  /// Fetch tasks from all journals
  void _fetchWeeklyTasks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .snapshots()
        .listen((journalSnapshot) {
      final Map<DateTime, List<Task>> groupedTasks = {};

      for (final journal in journalSnapshot.docs) {
        final journalId = journal.id;

        // Add a real-time listener for each journal's tasks
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('journals')
            .doc(journalId)
            .collection('tasks')
            .snapshots()
            .listen((taskSnapshot) {
          for (final taskDoc in taskSnapshot.docs) {
            final taskData = taskDoc.data();
            final task = Task.fromMap({...taskData, 'id': taskDoc.id});

            if (task.dueDate != null) {
              // Normalize the date to midnight
              final normalizedDate = DateTime(
                task.dueDate!.year,
                task.dueDate!.month,
                task.dueDate!.day,
              );

              // Add tasks to the grouped map
              if (!groupedTasks.containsKey(normalizedDate)) {
                groupedTasks[normalizedDate] = [];
              }

              // Update or replace existing tasks for the day
              groupedTasks[normalizedDate]!.removeWhere((t) => t.id == task.id);
              groupedTasks[normalizedDate]!.add(task);
            }
          }

          // Update state for real-time changes
          setState(() {
            weeklyTasks = groupedTasks;
          });
        });
      }
    });
  }





  /// Display all the tasks from all journals in a given day
  void _showTasksForDay(DateTime day) {
    final tasks = weeklyTasks[day] ?? [];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Tasks for ${DateFormat('EEE, MMM d').format(day)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: tasks.isEmpty
              ? const Text('No tasks for this day.')
              : SizedBox(
            height: 300, // Fixed height for content
            width: double.maxFinite, // Ensure it takes full width
            child: ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade300,
                thickness: 1,
              ), // Add a divider between tasks
              itemBuilder: (context, index) {
                final task = tasks[index];
                return FutureBuilder<String>(
                  future: _getJournalIdForTask(task.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final journalId = snapshot.data ?? 'Unknown Journal';

                    // Map predefined color names to Flutter `Color` objects
                    const predefinedColors = {
                      'None': Colors.transparent,
                      'Red': Colors.red,
                      'Green': Colors.green,
                      'Blue': Colors.blue,
                      'Orange': Colors.orange,
                      'Yellow': Colors.yellow,
                    };

                    // Resolve color for the task
                    final resolvedColor = predefinedColors[task.color] ?? Colors.grey;

                    return Container(
                      decoration: BoxDecoration(
                        color: task.completed
                            ? Colors.lightGreen.shade100 // Light green for completed tasks
                            : Colors.transparent, // Default for non-completed tasks
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: resolvedColor,
                          radius: 8, // Small circle to indicate task color
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: task.completed
                                ? TextDecoration.lineThrough // Strike-through for completed tasks
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.description.isNotEmpty)
                              Text(task.description),
                            if (task.dueDate != null)
                              Text(
                                'Due: ${DateFormat('EEE, MMM d, yyyy h:mm a').format(task.dueDate!)}',
                              ),
                            if (task.priority.isNotEmpty)
                              Text('Priority: ${task.priority}'),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JournalPage(
                                journalName: 'Journal for ${task.title}',
                                journalId: journalId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }


  /// Fetch journalId for a given taskId (if journalId is not stored in `Task`).
  Future<String> _getJournalIdForTask(String taskId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Unknown';

    final journalsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .get();

    for (final journal in journalsSnapshot.docs) {
      final journalId = journal.id;
      final taskSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .doc(journalId)
          .collection('tasks')
          .doc(taskId)
          .get();

      if (taskSnapshot.exists) {
        return journalId;
      }
    }
    return 'Unknown';
  }





  /// Add a new page to the focused journal
  Future<void> _addPageToJournal(String journalId, String pageTitle) async {
    try {
      // Generate a unique page ID
      final pageId = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('journals')
          .doc(journalId)
          .collection('pages')
          .doc()
          .id;

      // Add the page to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('journals')
          .doc(journalId)
          .collection('pages')
          .doc(pageId)
          .set({
        'id': pageId,
        'title': pageTitle,
        'content': [], // Default empty content
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update the local state
      setState(() {
        pages.add({'id': pageId, 'title': pageTitle});
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding page: $e')),
      );
    }
  }


  Future<void> _loadPages(String journalId) async {
    try {
      // Get the current authenticated user
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      // Fetch pages from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .doc(journalId)
          .collection('pages')
          .orderBy('createdAt', descending: true) // Optional: Order by creation time
          .get();

      // Map the fetched data into a list of pages
      final fetchedPages = snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Page ID
          'title': doc['title'] ?? 'Untitled Page', // Page Title
          'createdAt': doc['createdAt'], // Include timestamp for display or sorting
        };
      }).toList();

      // Update the state with the fetched pages
      setState(() {
        pages = fetchedPages;
      });
    } catch (e) {
      // Handle errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch pages: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journaled',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontFamily: 'SFPro',
            letterSpacing: 1.5,
          ),
        ),
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
            // Weekly view container
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 230,
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
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      final days = ['MON', 'TUES', 'WED', 'THUR', 'FRI', 'SAT', 'SUN'];
                      final today = DateTime.now();
                      final currentDay = DateTime(
                        today.year,
                        today.month,
                        today.day,
                      ).subtract(Duration(days: today.weekday - 1 - index)); // Normalize to midnight
                      final tasks = weeklyTasks[currentDay] ?? [];
                      const maxVisibleTasks = 10; // Maximum number of visible blocks

                      return GestureDetector(
                        onTap: () => _showTasksForDay(currentDay),
                        child: Column(
                          children: [
                            Text(
                              days[index],
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Container(
                                width: 45,
                                decoration: BoxDecoration(
                                  color: isDarkTheme ? Colors.blue.shade700 : Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: tasks.isEmpty
                                      ? const SizedBox.shrink()
                                      : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      tasks.length > maxVisibleTasks
                                          ? maxVisibleTasks
                                          : tasks.length,
                                          (taskIndex) {
                                        if (taskIndex == maxVisibleTasks - 1 &&
                                            tasks.length > maxVisibleTasks) {
                                          // Overflow indicator
                                          return const Text(
                                            '+',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          );
                                        }
                                        final taskColor = tasks[taskIndex].color;
                                        Color resolvedColor;

                                            // Map predefined color names to Flutter colors
                                            const predefinedColors = {
                                              'Red': Colors.red,
                                              'Blue': Colors.blue,
                                              'Green': Colors.green,
                                              'Yellow': Colors.yellow,
                                              'Purple': Colors.purple,
                                              'Orange': Colors.orange,
                                            };

                                            // Resolve color
                                            if (predefinedColors.containsKey(taskColor)) {
                                              resolvedColor = predefinedColors[taskColor]!;
                                            } else {
                                              // Attempt to parse as hexadecimal, fallback to grey if invalid
                                              try {
                                                resolvedColor = Color(int.parse(taskColor, radix: 16)).withOpacity(1.0);
                                              } catch (_) {
                                                resolvedColor = Colors.grey; // Default color
                                              }
                                            }

                                            return Container(
                                              margin: const EdgeInsets.symmetric(vertical: 2),
                                              width: 35,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: resolvedColor,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            );

                                          },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35), // Space between weekly view and journal list

            // Horizontal journal list
            SizedBox(
              height: 150, // Height of the horizontal list
              child: isLoadingJournals
                  ? const Center(child: CircularProgressIndicator())
                  : PageView.builder(
                controller: PageController(viewportFraction: 0.35, initialPage: 0),
                itemCount: journals.length + 1, // Journals + the fixed leftmost +
                onPageChanged: (index) async {
                  setState(() {
                    focusedJournalIndex = index;
                    showPageList = false; // Close the vertical page list when swiping journals
                  });
                  if (index > 0) {
                    final journalId = journals[index - 1]['id'];
                    await _loadPages(journalId); // Load pages for the focused journal
                  }
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
                              // If page list is already visible, navigate to the JournalPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JournalPage(
                                    journalName: journal['title'] ?? 'Untitled Journal',
                                    journalId: journal['id'],
                                  ),
                                ),
                              );
                            } else {
                              // Toggle the vertical page list visibility
                              showPageList = true;
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
                                    final journalId = journals[focusedJournalIndex - 1]['id']; // Get the correct journal ID
                                    await _addPageToJournal(journalId, newPageTitle.trim());
                                  }
                                },
                                child: const Text('+ Add Page'),
                              );
                            }

                            final page = pages[index];
                            return ListTile(
                              title: Text(page['title']),
                              onTap: () async {
                                final journalId = journals[focusedJournalIndex - 1]['id'];
                                final pageId = page['id'];

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IndivPageView(
                                      journalId: journalId,
                                      pageId: pageId,
                                    ),
                                  ),
                                ).then((_) async {
                                  await _loadPages(journalId); // Refresh page list after returning
                                  setState(() {
                                    focusedJournalIndex = focusedJournalIndex;
                                    showPageList = true; // Show page list again
                                  });
                                });
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

  /// Fetch journals from Firestore
  Future<void> _loadJournals() async {
    setState(() {
      isLoadingJournals = true;
    });

    try {
      final fetchedJournals = await _journalManager.fetchJournals();
      setState(() {
        journals = fetchedJournals;
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

  /// Add a new journal to Firestore
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

}
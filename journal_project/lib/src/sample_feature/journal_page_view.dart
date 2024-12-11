import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'indiv_page_view.dart';
import 'task_creation_screen.dart';
import 'task_options_modal.dart';
import 'task.dart';

class JournalPage extends StatefulWidget {
  final String journalName;
  final String journalId;

  const JournalPage({
    super.key,
    required this.journalName,
    required this.journalId,
  });

  @override
  JournalPageState createState() => JournalPageState();
}

class JournalPageState extends State<JournalPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isListView = true; // Toggle between list view and calendar view
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<DateTime, List<Task>> tasksByDate = {};
  List<Map<String, dynamic>> pages = [];
  final DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTasks(); // Fetch tasks from Firestore
    _fetchPages(); // Fetch pages from Firestore
  }

  Future<void> _fetchTasks() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .doc(widget.journalId)
          .collection('tasks')
          .get();

      final tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        return Task.fromMap({
          ...data,
          'id': doc.id, // Add the task ID to the map
        });
      }).toList();

      // Group tasks by date
      final groupedTasks = <DateTime, List<Task>>{};
      for (final task in tasks) {
        final dueDate = task.dueDate ?? DateTime.now();
        final dateKey = DateTime(dueDate.year, dueDate.month, dueDate.day); // Normalize the date
        groupedTasks[dateKey] = (groupedTasks[dateKey] ?? [])..add(task);
      }

      setState(() {
        tasksByDate = groupedTasks;
      });
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  Future<void> _toggleTaskCompletion(Task task, {VoidCallback? onTaskUpdated}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        time: task.time,
        reminder: task.reminder,
        priority: task.priority,
        color: task.color,
        completed: !task.completed, // Toggle completion
      );

      // Update Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .doc(widget.journalId)
          .collection('tasks')
          .doc(task.id)
          .update(updatedTask.toMap());

      // Trigger the callback to update the local state in the popup
      if (onTaskUpdated != null) {
        onTaskUpdated();
      }

      // Update global UI state
      final dateKey = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      setState(() {
        tasksByDate[dateKey] = tasksByDate[dateKey]!
            .map((t) => t.id == task.id ? updatedTask : t)
            .toList();
      });
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }



  void _showTasksForDay(DateTime day) {
    final originalTasks = tasksByDate[day] ?? [];
    final tasks = List<Task>.from(originalTasks); // Create a mutable copy

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(DateFormat('EEE, MMM d, yyyy').format(day)),
          content: tasks.isNotEmpty
              ? StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return ListTile(
                            tileColor: task.completed ? Colors.green.shade100 : Colors.white,
                            leading: CircleAvatar(
                              backgroundColor: _getColor(task.color),
                              child: Text(
                                task.priority[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(task.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (task.dueDate != null)
                                  Text('Due: ${DateFormat('h:mm a').format(task.dueDate!)}'),
                                if (task.description != null && task.description!.isNotEmpty)
                                  Text(task.description!, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                task.completed
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                color: task.completed ? Colors.green : null,
                              ),
                              onPressed: () async {
                                await _toggleTaskCompletion(
                                  task,
                                  onTaskUpdated: () {
                                    setState(() {
                                      // Update the specific task in the local tasks list
                                      tasks[index] = task.copyWith(
                                        completed: !task.completed,
                                      );
                                    });
                                  },
                                );
                              },
                            ),
                            onTap: () {
                              Navigator.pop(context); // Close the dialog
                              _showTaskModal(task);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          )
              : const Center(child: Text('No tasks for this day.')),
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






  void _showTaskModal(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskModalScreen(
        task: task,
        journalId: widget.journalId,
      ),
    ).whenComplete(() => _fetchTasks()); // Refresh tasks after modal is closed
  }

  Future<void> _fetchPages() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .doc(widget.journalId)
          .collection('pages')
          .orderBy('createdAt', descending: true)
          .get();

      final fetchedPages = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['title'] ?? 'Untitled Page',
        };
      }).toList();

      setState(() {
        pages = fetchedPages;
      });
    } catch (e) {
      print('Error fetching pages: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.journalName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tasks'),
            Tab(text: 'Pages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTasksTab(),
          _buildPagesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_tabController.index == 0) {
            // Task creation for the Tasks tab
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskCreationScreen(journalId: widget.journalId),
              ),
            );
            if (result == true) {
              _fetchTasks(); // Refresh tasks after creating a new one
            }
          } else if (_tabController.index == 1) {
            // Page creation for the Pages tab
            final newPageTitle = await showDialog<String>(
              context: context,
              builder: (context) {
                final TextEditingController controller = TextEditingController();
                return AlertDialog(
                  title: const Text('New Page'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Enter page title'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, controller.text.trim()),
                      child: const Text('Create'),
                    ),
                  ],
                );
              },
            );

            if (newPageTitle != null && newPageTitle.isNotEmpty) {
              final user = _auth.currentUser;
              if (user != null) {
                await _firestore
                    .collection('users')
                    .doc(user.uid)
                    .collection('journals')
                    .doc(widget.journalId)
                    .collection('pages')
                    .add({
                  'title': newPageTitle,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                _fetchPages(); // Refresh pages after adding a new one
              }
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTasksTab() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: isListView ? _buildListView() : _buildCalendarView(),
        ),
      ],
    );
  }

  Widget _buildPagesTab() {
    if (pages.isEmpty) {
      return const Center(
        child: Text('No pages found. Add one to get started!'),
      );
    }

    return ListView.builder(
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final page = pages[index];
        final pageTitle = page['title'] ?? 'Untitled Page'; // Ensure non-null
        final pageId = page['id'] ?? ''; // Ensure non-null

        return ListTile(
          title: Text(pageTitle),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IndivPageView(
                  pageId: pageId, // Pass non-null pageId
                  journalId: widget.journalId,
                ),
              ),
            ).then((_) => _fetchPages()); // Refresh pages after returning
          },
        );
      },
    );
  }



  Widget _buildHeader() {
    return Container(
      color: Theme.of(context).dividerColor.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(isListView ? Icons.calendar_today : Icons.list),
            onPressed: () {
              setState(() {
                isListView = !isListView;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    final sortedDates = tasksByDate.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final tasks = tasksByDate[date] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('EEEE — MMM dd').format(date),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...tasks.map((task) => ListTile(
              tileColor: task.completed ? Colors.green.shade100 : Colors.white,
              leading: CircleAvatar(
                backgroundColor: _getColor(task.color),
                child: Text(
                  task.priority[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(task.title),
              subtitle: task.dueDate != null
                  ? Text('Due: ${DateFormat('h:mm a').format(task.dueDate!)}')
                  : null,
              trailing: IconButton(
                icon: Icon(
                  task.completed
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: task.completed ? Colors.green : null,
                ),
                onPressed: () => _toggleTaskCompletion(task),
              ),
              onTap: () => _showTaskModal(task),
            )),
          ],
        );
      },
    );
  }

  Widget _buildCalendarView() {
    // Get the range of dates based on tasks
    final allDates = tasksByDate.keys.toList();
    if (allDates.isEmpty) return const Center(child: Text("No tasks available"));

    final minDate = allDates.reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDate = allDates.reduce((a, b) => a.isAfter(b) ? a : b);

    final startMonth = DateTime(minDate.year, minDate.month);
    final endMonth = DateTime(maxDate.year, maxDate.month);

    // Generate months to display
    List<DateTime> months = [];
    DateTime currentMonth = startMonth;
    while (!currentMonth.isAfter(endMonth)) {
      months.add(currentMonth);
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    }

    return ListView.builder(
      itemCount: months.length,
      itemBuilder: (context, index) {
        final month = months[index];
        final daysInMonth = List.generate(
          DateTime(month.year, month.month + 1, 0).day,
              (dayIndex) => DateTime(month.year, month.month, dayIndex + 1),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('MMMM yyyy').format(month),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: daysInMonth.length,
              itemBuilder: (context, dayIndex) {
                final day = daysInMonth[dayIndex];
                final tasks = tasksByDate[day] ?? [];

                return GestureDetector(
                  onTap: () => _showTasksForDay(day),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (tasks.isNotEmpty)
                          Text(
                            '${tasks.length} tasks',
                            style: const TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }


  Color _getColor(String colorName) {
    switch (colorName) {
      case 'Red':
        return Colors.red;
      case 'Green':
        return Colors.green;
      case 'Blue':
        return Colors.blue;
      case 'Orange':
        return Colors.orange;
      case 'Yellow':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}

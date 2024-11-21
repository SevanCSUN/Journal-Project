import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JournalPage extends StatefulWidget {
  final String journalName;

  const JournalPage({super.key, required this.journalName});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isListView = true; // Toggle between list view and calendar view
  late ScrollController _scrollController;
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDay; // Store the selected day for the popup

  // Example task data for each day
  final Map<DateTime, List<String>> tasksByDate = {
    DateTime(2024, 11, 20): ['Task 1', 'Task 2'],
    DateTime(2024, 11, 21): ['Task 3'],
    DateTime(2024, 11, 22): ['Task 4', 'Task 5'],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      const rowHeight = 100.0; // Approximate row height for weeks
      final weeksScrolled = (offset / rowHeight).floor();
      final newMonth = DateTime.now().add(Duration(days: weeksScrolled * 7));
      final monthStart = DateTime(newMonth.year, newMonth.month);
      if (_currentMonth != monthStart) {
        setState(() {
          _currentMonth = monthStart;
        });
      }
    }
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDay = day; // Set selected day
    });
  }

  void _closePopup() {
    setState(() {
      _selectedDay = null; // Close the popup by setting selected day to null
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
              // Tasks Tab
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: isListView ? _buildListView() : _buildCalendarView(),
                  ),
                ],
              ),
              // Pages Tab
              Center(
                child: Text(
                  'Pages for ${widget.journalName}', // Placeholder for Pages Tab
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        // Popup for selected day
        if (_selectedDay != null) _buildPopup(context),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
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
            icon: Icon(isListView ? Icons.calendar_month : Icons.list),
            onPressed: () {
              setState(() {
                isListView = !isListView; // Toggle view
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeekHeader() {
    final daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: daysOfWeek
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        _buildDaysOfWeekHeader(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemBuilder: (context, weekIndex) {
              return _buildWeekRow(weekIndex);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekRow(int weekIndex) {
    final now = DateTime.now();
    final startOfWeek = now.add(Duration(days: weekIndex * 7 - now.weekday + 1));
    final daysOfWeek = List.generate(
      7,
      (i) => startOfWeek.add(Duration(days: i)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: daysOfWeek.map((day) {
          final isCurrentMonth = day.month == _currentMonth.month;
          final tasks = tasksByDate[day] ?? [];

          return Expanded(
            child: GestureDetector(
              onTap: () => _selectDay(day), // Select day on tap
              child: Container(
                height: 100,
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: isCurrentMonth ? Colors.white : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date at the top
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrentMonth ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    // Task list below
                    Expanded(
                      child: ListView.builder(
                        itemCount: tasks.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              tasks[index],
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPopup(BuildContext context) {
    final tasks = tasksByDate[_selectedDay!] ?? [];
    return GestureDetector(
      onTap: _closePopup, // Close popup when clicking outside
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping inside the popup
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEE, MMM d, yyyy').format(_selectedDay!),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _closePopup,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: tasks.isNotEmpty
                        ? ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  tasks[index],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              'No tasks for this day',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    final Map<String, List<String>> groupedTasks = {
      'Wednesday — Nov 20': ['Task 1', 'Task 2'],
      'Thursday — Nov 21': ['Task 3', 'Task 4'],
      'Friday — Nov 22': ['Task 5'],
    };

    return CustomScrollView(
      slivers: groupedTasks.entries.map((entry) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                // Sticky header
                return Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              } else {
                // Task item
                final task = entry.value[index - 1];
                return ListTile(
                  title: Text(task),
                  subtitle: const Text('7:00 AM'),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () {
                      // Mark task complete
                    },
                  ),
                );
              }
            },
            childCount: entry.value.length + 1, // Header + tasks
          ),
        );
      }).toList(),
    );
  }
}

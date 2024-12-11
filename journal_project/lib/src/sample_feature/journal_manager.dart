import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task.dart';

class JournalManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Create a new journal
  Future<void> createJournal(String journalTitle) async {
    if (_userId == null) throw Exception('User not authenticated');

    final journalId = _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc()
        .id;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc(journalId)
        .set({
      'title': journalTitle,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch all journals for the current user
  Future<List<Map<String, dynamic>>> fetchJournals() async {
    if (_userId == null) throw Exception('User not authenticated');

    final querySnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .get();

    return querySnapshot.docs.map((doc) => {
      ...doc.data(),
      'id': doc.id,
    }).toList();
  }

  /// Add a task to a specific journal
  Future<void> addTask(String journalId, Task task) async {
    if (_userId == null) throw Exception('User not authenticated');

    final taskId = _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc(journalId)
        .collection('tasks')
        .doc()
        .id;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc(journalId)
        .collection('tasks')
        .doc(taskId)
        .set({
      'id': taskId, // Ensure the ID is saved
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate != null ? Timestamp.fromDate(task.dueDate!) : null,
      'time': task.time != null ? '${task.time!.hour}:${task.time!.minute}' : null,
      'reminder': task.reminder,
      'priority': task.priority,
      'color': task.color,
      'completed': task.completed,
    });
  }

  /// Fetch all tasks for a specific journal
  Future<List<Task>> fetchTasks(String journalId) async {
    if (_userId == null) throw Exception('User not authenticated');

    final querySnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc(journalId)
        .collection('tasks')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Task.fromMap({
        ...data,
        'id': doc.id,
        'dueDate': (data['dueDate'] as Timestamp?)?.toDate(),
      });
    }).toList();
  }

  /// Update a task for a specific journal
  Future<void> updateTask(String journalId, Task task) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc(journalId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  /// Update specific fields of a task (e.g., for completion)
  Future<void> updateTaskFields(String journalId, String taskId, Map<String, dynamic> fields) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc(journalId)
        .collection('tasks')
        .doc(taskId)
        .update(fields);
  }

  /// Delete a task
  Future<void> deleteTask(String journalId, String taskId) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc(journalId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  /// Add a page to a specific journal
  Future<void> addPage(String journalId, String pageTitle, String content) async {
    if (_userId == null) throw Exception('User not authenticated');

    final pageId = _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc(journalId)
        .collection('pages')
        .doc()
        .id;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc(journalId)
        .collection('pages')
        .doc(pageId)
        .set({
      'title': pageTitle,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch all pages for a specific journal
  Future<List<Map<String, dynamic>>> fetchPages(String journalId) async {
    if (_userId == null) throw Exception('User not authenticated');

    final querySnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc(journalId)
        .collection('pages')
        .get();

    return querySnapshot.docs.map((doc) => {
      ...doc.data(),
      'id': doc.id,
    }).toList();
  }
}

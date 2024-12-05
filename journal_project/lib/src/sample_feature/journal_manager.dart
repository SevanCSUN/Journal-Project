import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  Future<void> addTask(String journalId, String taskTitle, String description) async {
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
      'title': taskTitle,
      'description': description,
      'completed': false,
      'dueDate': null, // Optional
    });
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

  /// Fetch all tasks for a specific journal
  Future<List<Map<String, dynamic>>> fetchTasks(String journalId) async {
    if (_userId == null) throw Exception('User not authenticated');

    final querySnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc(journalId)
        .collection('tasks')
        .get();

    return querySnapshot.docs.map((doc) => {
          ...doc.data(),
          'id': doc.id,
        }).toList();
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

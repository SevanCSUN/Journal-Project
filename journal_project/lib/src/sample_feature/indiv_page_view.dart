import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';

class IndivPageView extends StatefulWidget {
  const IndivPageView({
    super.key,
    required this.pageTitle,
  });

  final String pageTitle;

  static const routeName = '/indiv_page_view';

  @override
  _IndivPageViewState createState() => _IndivPageViewState();
}

class _IndivPageViewState extends State<IndivPageView> {
  late ParchmentDocument document;
  late FleatherController controller;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    document = ParchmentDocument();
    controller = FleatherController(document: document);
    _loadDocument();
  }

  Future<void> _loadDocument() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User not authenticated')),
    );
    return;
  }

  try {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('markdownFiles')
        .doc(widget.pageTitle);

    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null && data['content'] != null) {
        // Convert the JSON back into a ParchmentDocument
        setState(() {
          document = ParchmentDocument.fromJson(data['content']);
          controller = FleatherController(document: document);
        });
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load document: $e')),
    );
  }
}

  // Save the document to Firestore
  Future<void> _saveDocument() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User not authenticated')),
    );
    return;
  }

  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('markdownFiles')
      .doc(widget.pageTitle);

  try {
    // Check if the document exists
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      // Document exists - update it
      await docRef.update({
        'content': document.toJson(), // Save JSON content
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document updated successfully!')),
      );
    } else {
      // Document does not exist - create it
      await docRef.set({
        'content': document.toJson(), // Save JSON content
        'updatedAt': FieldValue.serverTimestamp(),
        'title': widget.pageTitle,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document created successfully!')),
      );
    }
  } catch (e) {
    // Handle errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save document: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveDocument, // Save document when save button is pressed
          ),
        ],
      ),
      body: Column(
        children: [
          FleatherToolbar.basic(controller: controller),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FleatherEditor(controller: controller),
            ),
          ),
        ],
      ),
    );
  }
}

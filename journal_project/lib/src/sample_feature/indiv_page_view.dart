import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';

class IndivPageView extends StatefulWidget {
  const IndivPageView({
    super.key,
    required this.pageTitle,
    required this.journalId, // Add journalId
  });

  final String pageTitle;
  final String journalId; // Journal ID to determine where to save the page

  static const routeName = '/indiv_page_view';

  @override
  IndivPageViewState createState() => IndivPageViewState();
}

class IndivPageViewState extends State<IndivPageView> {
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
    final user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    try {
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .doc(widget.journalId)
          .collection('pages')
          .doc(widget.pageTitle);

      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['content'] != null) {
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

  Future<void> _saveDocument() async {
    final user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .doc(widget.journalId)
        .collection('pages')
        .doc(widget.pageTitle);

    try {
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        // Update existing document
        await docRef.update({
          'content': document.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document updated successfully!')),
        );
      } else {
        // Create a new document
        await docRef.set({
          'content': document.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
          'title': widget.pageTitle,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document created successfully!')),
        );
      }
    } catch (e) {
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
            icon: const Icon(Icons.save),
            onPressed: _saveDocument,
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

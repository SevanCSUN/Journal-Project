import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';

class IndivPageView extends StatefulWidget {
  const IndivPageView({
    super.key,
    required this.pageId,
    required this.journalId,
  });

  final String pageId;
  final String journalId;

  static const routeName = '/indiv_page_view';

  @override
  IndivPageViewState createState() => IndivPageViewState();
}

class IndivPageViewState extends State<IndivPageView> {
  late ParchmentDocument document;
  late FleatherController controller;
  String pageTitle = 'Loading...';

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
          .doc(widget.pageId);

      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Page not found')),
        );
        return;
      }

      final data = snapshot.data();
      if (data == null) {
        // No data - initialize empty
        setState(() {
          document = ParchmentDocument();
          controller = FleatherController(document: document);
          pageTitle = 'Untitled Page';
        });
        return;
      }

      final content = data['content'];
      final title = data['title'] ?? widget.pageId;

      if (content == null || (content is List && content.isEmpty)) {
        // If content is null or an empty list, initialize empty
        setState(() {
          document = ParchmentDocument();
          controller = FleatherController(document: document);
          pageTitle = title;
        });
      } else if (content is List) {
        // Content is a List of maps
        setState(() {
          document = ParchmentDocument.fromJson(
            content.cast<Map<String, dynamic>>(),
          );
          controller = FleatherController(document: document);
          pageTitle = title;
        });
      } else {
        // If content is not a List, show an error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid content format in Firestore')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load document: $e')),
      );
    }
  }

  Future<void> _confirmDeletePage() async {
  final userConfirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Page'),
        content: const Text('Are you sure you want to delete this page? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false); // User cancels the deletion
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // User confirms the deletion
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (userConfirmed == true) {
    _deletePage();
  }
}

Future<void> _deletePage() async {
  final user = _auth.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not authenticated')),
    );
    return;
  }

  try {
    // Reference to the page document
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .doc(widget.journalId)
        .collection('pages')
        .doc(widget.pageId);

    // Delete the document
    await docRef.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Page deleted successfully.')),
    );

    // Navigate back to the previous screen
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete page: $e')),
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
      .doc(widget.pageId);

  try {
    // Get the delta from the document
    final delta = document.toDelta();
    final ops = delta.toList();

    // Manually convert each operation to a map of primitives
    final List<Map<String, dynamic>> contentAsJson = ops.map((op) {
      // op.data should be text or a Map representing inserts like embeds
      // op.attributes is a Map<String, dynamic> or null
      return {
        'insert': op.data, // Usually a String or a Map for embedded objects
        if (op.attributes != null) 'attributes': op.attributes,
      };
    }).toList();

    final snapshot = await docRef.get();
    final dataToSave = {
      'content': contentAsJson,
      'updatedAt': FieldValue.serverTimestamp(),
      'title': pageTitle,
    };

    if (snapshot.exists) {
      await docRef.update(dataToSave);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document updated successfully!')),
      );
    } else {
      await docRef.set(dataToSave);
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
        title: Text(pageTitle),
        actions: [
          IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _confirmDeletePage, // Call the delete confirmation method
          ),
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



//import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    // Initialize with empty document or define a valid JSON map
    document = ParchmentDocument();
    controller = FleatherController(document: document);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageTitle),
      ),
      body: Column(
        children: [
          FleatherToolbar.basic(controller: controller),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Add padding as needed
              child: FleatherEditor(controller: controller),
            ),
          ),
          // Alternatively, use FleatherField if needed
          // FleatherField(controller: controller)
        ],
      ),
    );
  }
}

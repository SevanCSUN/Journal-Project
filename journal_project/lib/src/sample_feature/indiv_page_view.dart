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
  TextEditingController _controller = TextEditingController();
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateText() {
    setState(() {}); // Update the UI whenever the text changes
  }

  TextStyle getCurrentStyle() {
    return TextStyle(
      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
      decoration:
          _isUnderline ? TextDecoration.underline : TextDecoration.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageTitle),
        actions: [
          IconButton(
            icon: Icon(
              Icons.format_bold,
              color: _isBold ? Colors.blue : Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isBold = !_isBold;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.format_italic,
              color: _isItalic ? Colors.blue : Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isItalic = !_isItalic;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.format_underline,
              color: _isUnderline ? Colors.blue : Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isUnderline = !_isUnderline;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            if (_controller.text.isEmpty) // Display hint text when input is empty
              Positioned(
                top: 0,
                left: 0,
                child: Text(
                  'Start your journal here...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            EditableText(
              controller: _controller,
              focusNode: FocusNode(),
              style: getCurrentStyle(),
              cursorColor: Colors.blue,
              backgroundCursorColor: Colors.grey,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              selectionControls: MaterialTextSelectionControls(),
              textAlign: TextAlign.start,
              selectionColor: Colors.blue.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}

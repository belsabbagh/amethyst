import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor({Key? key}) : super(key: key);

  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  bool _isEditing = true;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
      children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              ),
            ],
        ),
        Expanded(
          child: _isEditing ? _buildEditingMode() : _buildReadingMode()
        ),
      ],
    ),
    );
  }

  Widget _buildEditingMode() {
    return TextField(
      controller: _controller,
      maxLines: null,
      expands: true,
      decoration: const InputDecoration(
        isCollapsed: true,
        contentPadding: EdgeInsets.all(16.0),
      ),
    );
  }

  Widget _buildReadingMode() {
    return Markdown(
          data: _controller.text,
      );
  }
}

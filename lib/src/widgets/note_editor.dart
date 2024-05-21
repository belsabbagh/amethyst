import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NoteEditor extends StatefulWidget {
  final TextEditingController noteController;

  final TextEditingController fileNameController;

  const NoteEditor({super.key, required this.noteController, required this.fileNameController});

  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  bool _isEditing = false;

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
            children: [
              Expanded(
                child: TextField(
                  controller: widget.fileNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter file name',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ),
              ),
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
            child: _isEditing ? _buildEditingMode() : _buildReadingMode(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditingMode() {
    return TextField(
      controller: widget.noteController,
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
      data: widget.noteController.text,
    );
  }
}

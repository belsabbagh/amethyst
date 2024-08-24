import 'package:amethyst/src/core/models/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NoteEditor extends StatefulWidget {
  final TextEditingController fileNameController;
  final QuillController noteController;
  final Function(Note) onChange;

    const NoteEditor(
      {super.key,
      required this.fileNameController,
      required this.noteController,
      required this.onChange});

  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  bool _isEditing = false;

  void _runOnChange(String text) {
    widget.onChange(Note.fromString(text));
  }

  @override
  void initState() {
    super.initState();
    widget.noteController.document.changes.listen((change) {
      _runOnChange(widget.noteController.document.toPlainText());
    });
  }

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
            child: _isEditing
                ? _buildEditingMode(_runOnChange)
                : _buildReadingMode(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditingMode(Function(String) onChange) {
    return QuillEditor.basic(
      configurations: QuillEditorConfigurations(
        controller: widget.noteController,
        padding: const EdgeInsets.all(16.0),
      ),
    );
  }

  Widget _buildReadingMode() {
    return Markdown(
      data: widget.noteController.document.toPlainText(),
    );
  }
}

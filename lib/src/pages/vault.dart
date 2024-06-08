import 'dart:io';

import 'package:amethyst/src/core/indexer.dart';
import 'package:amethyst/src/core/models/note.dart';
import 'package:amethyst/src/core/models/vault.dart';
import 'package:amethyst/src/widgets/drawers/left_drawer.dart';
import 'package:amethyst/src/widgets/drawers/right_drawer.dart';
import 'package:amethyst/src/widgets/note_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class VaultPage extends StatefulWidget {
  final Vault vault;
  const VaultPage({super.key, required this.vault});

  @override
  _VaultPageState createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  late final IndexService indexService;
  late Future<IndexService> _indexingFuture;
  final TextEditingController _fileNameController = TextEditingController();
  final QuillController _noteController = QuillController.basic();
  Note _selectedNote = Note();

  @override
  void initState() {
    super.initState();
    indexService = IndexService(vault: widget.vault);
    _indexingFuture = Future<IndexService>(() => indexService.index());
  }

  void onChanged(Note note) {
    print(note.toString());
    setState(() {
      _selectedNote = note;
      _fileNameController.text =
          indexService.id2Path[note.id] ?? '';
      _noteController.document = Document.fromJson([{'insert':'${note.toString()}\n'}]);
    });
  }

  void saveNote(Note note) {
    String path = _fileNameController.text;
    String text = _noteController.document.toPlainText();
    print(text);
    note = Note.fromString(text);
    indexService.updateNote(note.id, path, text);
    String fullPath = widget.vault.absolutePath(path);
    if (!File(fullPath).existsSync()) {
      File(fullPath).createSync();
    }
    File(fullPath).writeAsStringSync(text);
  }

  void deleteNote(Note note) {
    indexService.removeNote(note.id);
    setState(() {
      _selectedNote = Note();
      _noteController.document = Document();
      _fileNameController.text = '';
    });
  }

  void renameNote(Note note) {
    indexService.updateNote(note.id, _fileNameController.text, _noteController.document.toPlainText());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vault.path),
      ),
      drawer: LeftDrawer(
          indexService: indexService, onNoteSelected: onChanged),
      endDrawer: RightDrawer(
          note: _selectedNote,
          indexService: indexService,
          onNoteSelected: onChanged,
          saveNote: saveNote,
          deleteNote: deleteNote,
          renameNote: renameNote,),
      body: FutureBuilder<IndexService>(
        future: _indexingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(
              child: NoteEditor(
                fileNameController: _fileNameController,
                noteController: _noteController,
                onChange: onChanged,
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

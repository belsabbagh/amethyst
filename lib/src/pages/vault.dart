import 'package:amethyst/src/core/indexer.dart';
import 'package:amethyst/src/core/models/note.dart';
import 'package:amethyst/src/core/models/vault.dart';
import 'package:amethyst/src/widgets/drawers.dart';
import 'package:amethyst/src/widgets/note_editor.dart';
import 'package:flutter/material.dart';

class VaultPage extends StatefulWidget {
  final String directoryPath;
  late final IndexService indexService;

  VaultPage({Key? key, required this.directoryPath}) : super(key: key) {
    indexService = IndexService(vault: Vault(path: directoryPath));
    indexService.index();
  }

  @override
  _VaultPageState createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();

  Note? _selectedNote;

  void onChanged(Note note) {
    setState(() {
      _noteController.text = note.toString();
      _selectedNote = note;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.directoryPath),
      ),
      drawer: LeftDrawer(indexService: widget.indexService, onNoteSelected: onChanged),
      endDrawer: RightDrawer(note: _selectedNote ?? Note()),
      body: Center(
          child: NoteEditor(
        noteController: _noteController,
        fileNameController: _fileNameController,
      )),
    );
  }
}

import 'package:amethyst/src/core/indexer.dart';
import 'package:amethyst/src/core/models/note.dart';
import 'package:amethyst/src/core/models/vault.dart';
import 'package:amethyst/src/widgets/drawers.dart';
import 'package:amethyst/src/widgets/note_editor.dart';
import 'package:flutter/material.dart';

class VaultPage extends StatefulWidget {
  late final IndexService indexService;

  VaultPage({Key? key, required directoryPath}) : super(key: key) {
    indexService = IndexService(vault: Vault(path: directoryPath));
    indexService.index();
  }

  @override
  _VaultPageState createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();

  String? _selectedNoteId;

  void onChanged(Note note) {
    setState(() {
      _noteController.text = note.toString();
      _selectedNoteId = note.id;
      if (note.id == '') {
        _fileNameController.text = '';
        return;
      }
      _fileNameController.text =
          widget.indexService.id2Path[note.id]!.split('/').last;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.indexService.vault.path),
      ),
      drawer: LeftDrawer(
          indexService: widget.indexService, onNoteSelected: onChanged),
      endDrawer: RightDrawer(
          note: widget.indexService.getNoteById(_selectedNoteId ?? '') ?? Note()),
      body: Center(
        child: NoteEditor(
          noteController: _noteController,
          fileNameController: _fileNameController,
        ),
      ),
    );
  }
}

import 'package:amethyst/src/core/indexer.dart';
import 'package:amethyst/src/core/models/note.dart';
import 'package:amethyst/src/core/models/vault.dart';
import 'package:amethyst/src/widgets/drawers.dart';
import 'package:amethyst/src/widgets/note_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class VaultPage extends StatefulWidget {
  late final IndexService indexService;

  VaultPage({super.key, required directoryPath}) {
    indexService = IndexService(vault: Vault(path: directoryPath));
    indexService.index();
  }

  @override
  _VaultPageState createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final TextEditingController _fileNameController = TextEditingController();
final QuillController _noteController = QuillController.basic();
  Note _selectedNote = Note();

  void onChanged(Note note) {
    print(note.toString());
    setState(() {
      _selectedNote = note;
      if (note.id == '') {
        _fileNameController.text = '';
        _noteController.document = Document();
        return;
      }
      _fileNameController.text =
          widget.indexService.id2Path[note.id]!;
      _noteController.document = Document.fromJson([{'insert':'${note.toString()}\n'}]);
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
          note: _selectedNote,
          indexService: widget.indexService,
          onNoteSelected: onChanged),
      body: Center(
        child: NoteEditor(
          fileNameController: _fileNameController,
          noteController: _noteController,
          onChange: onChanged,
        ),
      ),
    );
  }
}

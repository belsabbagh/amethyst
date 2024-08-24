import 'package:amethyst/src/core/indexer.dart';
import 'package:amethyst/src/core/models/note.dart';
import 'package:flutter/material.dart';

import 'package:amethyst/src/core/models/link.dart';


class MapVisualizer extends StatelessWidget {
  final Map<String, dynamic> data;

  MapVisualizer({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8.0),
      children: data.entries.map((entry) => _buildEntry(entry)).toList(),
    );
  }

  Widget _buildEntry(MapEntry<String, dynamic> entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.key,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          _buildValue(entry.value),
        ],
      ),
    );
  }

  Widget _buildValue(dynamic value) {
    if (value is String) {
      return Text(value);
    } else if (value is num) {
      return Text(value.toString());
    } else if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value.map<Widget>((item) => _buildValue(item)).toList(),
      );
    } else {
      return Text('Unsupported type');
    }
  }
}

class RightDrawer extends StatelessWidget {
  final Note note;
  final IndexService indexService;
  final Function(Note) onNoteSelected;
  final Function(Note) saveNote;
  final Function(Note) deleteNote;
  final Function(Note) renameNote;
  const RightDrawer(
      {super.key,
      required this.note,
      required this.indexService,
      required this.onNoteSelected,
      required this.saveNote,
      required this.deleteNote,
      required this.renameNote});

  List<String> getOutlinks() {
    return indexService.outlinks[note.id] ?? [];
  }

  List<String> getBacklinks() {
    return indexService.inlinks[note.id] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    List<NoteLink> outlinks = note.links.toList();
    List<String> backlinks = getBacklinks();
    return Drawer(
      child: DefaultTabController(
        length: 4, // Number of tabs
        child: Column(
          children: <Widget>[
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.list), text: 'Props'),
                Tab(icon: Icon(Icons.link), text: 'Outlinks'),
                Tab(icon: Icon(Icons.loop), text: 'Backlinks'),
                Tab(icon: Icon(Icons.note), text: 'Control'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Center(child: note.props.isEmpty ? const Text('Empty') : MapVisualizer(data: note.props)),
                  outlinks.isEmpty
                      ? const Center(child: Text('No outlinks'))
                      : ListView.builder(
                          itemCount: outlinks.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(outlinks[index].alias),
                              subtitle: Text(outlinks[index].path),
                              onTap: () {
                                Note note = indexService.getNoteByPath(
                                        "${outlinks[index].path}.md") ??
                                    Note();
                                onNoteSelected(note);
                              },
                            );
                          },
                        ),
                  backlinks.isEmpty
                      ? const Center(child: Text('No backlinks'))
                      : ListView.builder(
                          itemCount: backlinks.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                  indexService.id2Path[backlinks[index]] ??
                                      'bad'),
                              onTap: () {
                                Note note = indexService
                                        .getNoteById(backlinks[index]) ??
                                    Note();
                                onNoteSelected(note);
                              },
                            );
                          }),
                  Center(
                    child: Column(
                      children: [
                        TextButton(
                            onPressed: () {
                              saveNote(note);
                            },
                            child: const Text('Save')),
                        TextButton(
                            onPressed: () {
                              renameNote(note);
                            },
                            child: const Text('Rename')),
                        TextButton(
                            onPressed: () {
                              deleteNote(note);
                            },
                            child: const Text('Delete')),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

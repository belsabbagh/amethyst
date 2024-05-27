import 'package:amethyst/src/core/indexer.dart';
import 'package:amethyst/src/core/models/note.dart';
import 'package:amethyst/src/widgets/drawers/file_tree.dart';
import 'package:amethyst/src/widgets/drawers/search.dart';
import 'package:flutter/material.dart';

class TagView extends StatelessWidget {
  final IndexService indexService;

  const TagView({super.key, required this.indexService});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: indexService.tags.length,
      itemBuilder: (context, index) {
        String key = indexService.tags.keys.elementAt(index);
        return ListTile(
          title: Text(key),
          subtitle: Text("Count ${indexService.tags[key]!.length}"),
        );
      },
    );
  }
}

class LeftDrawer extends StatelessWidget {
  final IndexService indexService;
  final Function(Note) onNoteSelected;

  const LeftDrawer(
      {super.key, required this.indexService, required this.onNoteSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: DefaultTabController(
        length: 3, // Number of tabs
        child: Column(
          children: <Widget>[
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.folder), text: 'Files'),
                Tab(icon: Icon(Icons.search), text: 'Search'),
                Tab(icon: Icon(Icons.tag), text: 'Tags'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Center(
                      child: FilesView(
                          indexService: indexService,
                          onNoteSelected: onNoteSelected)),
                  Center(
                      child: SearchView(
                          indexService: indexService,
                          onNoteSelected: onNoteSelected)),
                  Center(child: TagView(indexService: indexService)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

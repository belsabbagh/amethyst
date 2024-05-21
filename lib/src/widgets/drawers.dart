import 'package:amethyst/src/core/indexer.dart';
import 'package:amethyst/src/core/models/note.dart';
import 'package:flutter/material.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _controller = TextEditingController();
  List<String> _results = [];

  void _performSearch(String query) {
    // Simulate a search by generating some dummy results
    setState(() {
      _results =
          List.generate(10, (index) => 'Result ${index + 1} for "$query"');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Enter search query',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _performSearch(_controller.text);
              },
            ),
          ),
          onChanged: (query) {
            _performSearch(query);
          },
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _controller.text.isEmpty || _results.isEmpty
              ? const Center(child: Text('No results'))
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_results[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class FilesView extends StatelessWidget {
  final IndexService indexService;
  final void Function(Note note) onNoteSelected;
  const FilesView({Key? key, required this.indexService, required this.onNoteSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: indexService.path2Id.length,
      itemBuilder: (context, index) {
        String key = indexService.path2Id.keys.elementAt(index);
        // get note name
        String noteName = key.split('/').last;
        String directory = key.replaceAll(noteName, '');
        return ListTile(
          title: Text(noteName),
          subtitle: Text(directory),
          onTap: () {
            String noteId = indexService.path2Id[key]!;
            Note note = indexService.getNoteById(noteId) ?? Note();
            note.id = noteId;
            onNoteSelected(note);
          },
        );
      },
    );
  }
}

class TagView extends StatelessWidget {
  final IndexService indexService;

  const TagView({Key? key, required this.indexService}) : super(key: key);

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
  const LeftDrawer({Key? key, required this.indexService, required this.onNoteSelected}) : super(key: key);

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
                  Center(child: FilesView(indexService: indexService, onNoteSelected: onNoteSelected)),
                  const Center(child: SearchView()),
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

class RightDrawer extends StatelessWidget {
  final Note note;
  const RightDrawer({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: DefaultTabController(
        length: 3, // Number of tabs
        child: Column(
          children: <Widget>[
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.list), text: 'Props'),
                Tab(icon: Icon(Icons.link), text: 'Outlinks'),
                Tab(icon: Icon(Icons.loop), text: 'Backlinks'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text(note.props.toString())),
                  const Center(child: Text('Outlinks')),
                  const Center(child: Text('Backlinks')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

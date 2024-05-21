import 'package:amethyst/src/core/indexer.dart';
import 'package:amethyst/src/core/models/note.dart';
import 'package:amethyst/src/core/models/vault.dart';
import 'package:amethyst/src/widgets/note_editor.dart';
import 'package:amethyst/src/widgets/tree_view.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
  const LeftDrawer({Key? key, required this.indexService}) : super(key: key);

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
                  Center(child: Text("FIle Tree here")),
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
  RightDrawer({Key? key, required this.note}) : super(key: key);

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
                  Center(child: Text('Backlinks')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  final TextEditingController _controller = TextEditingController();
  
  void onChanged(String value) {
    setState(() {
      _controller.text = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.directoryPath),
      ),
      drawer: LeftDrawer(indexService: widget.indexService),
      endDrawer: RightDrawer(note: Note()),
      body: Center(
          child: NoteEditor()
    ),
    );
  }
}

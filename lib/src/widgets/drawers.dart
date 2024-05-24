import 'package:amethyst/src/core/indexer.dart';
import 'package:amethyst/src/core/models/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'tree_view.dart'; // Import the MyTreeView and MyNode classes


class SearchView extends StatefulWidget {
  const SearchView({super.key});

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

class FilesView extends StatefulWidget {
  final IndexService indexService;
  final void Function(Note note) onNoteSelected;

  const FilesView({Key? key, required this.indexService, required this.onNoteSelected}) : super(key: key);

  @override
  _FilesViewState createState() => _FilesViewState();
}

class _FilesViewState extends State<FilesView> {
  late final TreeController<MyNode> treeController;

  @override
  void initState() {
    super.initState();
    treeController = TreeController<MyNode>(
      roots: _buildTreeNodes(),
      childrenProvider: (MyNode node) => node.children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyTreeView(
      treeController: treeController,
      nodeBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
        return MyTreeTile(
          key: ValueKey(entry.node),
          entry: entry,
          onTap: () => _onNodeTap(entry.node)
        );
      },
    );
  }

  List<MyNode> _buildTreeNodes() {
    Map<String, MyNode> nodeMap = {};

    // Helper function to get or create a node
    MyNode _getNode(String path) {
      if (!nodeMap.containsKey(path)) {
        nodeMap[path] = MyNode(title: path.split('/').last);
      }
      return nodeMap[path]!;
    }
    print(widget.indexService.vault.path);

    for (String path in widget.indexService.path2Id.keys) {
      // first, delete the vault path from the start of the path if it exists
      path = path.replaceFirst('${widget.indexService.vault.path}/', '');
      List<String> parts = path.split('/');
      String fullPath = '';
      MyNode? parentNode;

      for (int i = 0; i < parts.length; i++) {
        String part = parts[i];
        fullPath = fullPath.isEmpty ? part : '$fullPath/$part';

        if (i == parts.length - 1) {
          // This is a file node, add it as a child of its parent directory
          MyNode fileNode = _getNode(part);
          parentNode?.addChild(fileNode);
        } else {
          // This is a directory node, get or create it
          if (parentNode == null) {
            parentNode = _getNode(part);
          } else {
            parentNode = parentNode.children.firstWhere((node) => node.title == part, orElse: () {
              MyNode dirNode = _getNode(part);
              parentNode!.addChild(dirNode);
              return dirNode;
            });
          }
        }
      }
    }

    // Find root nodes (nodes with no parents)
    List<MyNode> roots = [];
    Set<MyNode> allNodes = nodeMap.values.toSet();
    Set<MyNode> childNodes = {};


    // Identify all child nodes
    for (MyNode node in allNodes) {
      childNodes.addAll(node.children);
    }

    // Root nodes are those that are not child nodes
    for (MyNode node in allNodes) {
      if (!childNodes.contains(node)) {
        roots.add(node);
      }
    }

    return roots;
  }

  String _getFullPath(String nodeName) {
    for (String path in widget.indexService.path2Id.keys) {
      if (path.endsWith(nodeName)) {
        return path;
      }
    }
    return '';
  }

  void _onNodeTap(MyNode node) {
    if (node.children.isNotEmpty) {
      treeController.toggleExpansion(node);
    } else {
      String fullPath = _getFullPath(node.title);
      String? noteId = widget.indexService.path2Id[fullPath];
      if (noteId != null) {
        Note note = widget.indexService.getNoteById(noteId) ?? Note();
        note.id = noteId;
        widget.onNoteSelected(note);
      }
    }
  }
}



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
  const LeftDrawer({super.key, required this.indexService, required this.onNoteSelected});

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
  const RightDrawer({super.key, required this.note});

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

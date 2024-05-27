import 'package:amethyst/src/core/indexer.dart';
import 'package:amethyst/src/core/models/note.dart';
import 'package:amethyst/src/widgets/tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class FilesView extends StatefulWidget {
  final IndexService indexService;
  final void Function(Note note) onNoteSelected;

  const FilesView(
      {super.key, required this.indexService, required this.onNoteSelected});

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
            onTap: () => _onNodeTap(entry.node));
      },
    );
  }

  List<MyNode> _buildTreeNodes() {
    Map<String, MyNode> nodeMap = {};

    // Helper function to get or create a node
    MyNode getNode(String path) {
      return nodeMap.putIfAbsent(
          path, () => MyNode(title: path.split('/').last));
    }

    print(widget.indexService.vault.path);

    for (String id in widget.indexService.id2Path.keys) {
      // first, delete the vault path from the start of the path if it exists
      String path = widget.indexService.id2Path[id]!;
      List<String> parts = path.split('/');
      MyNode? parentNode;

      for (int i = 0; i < parts.length; i++) {
        String part = parts[i];

        if (i == parts.length - 1) {
          // This is a file node, add it as a child of its parent directory
          MyNode fileNode = getNode(part);
          fileNode.key = id;
          parentNode?.addChild(fileNode);
          continue;
        }
        // This is a directory node, get or create it
        if (parentNode == null) {
          parentNode = getNode(part);
          continue;
        }
        parentNode = parentNode.children
            .firstWhere((node) => node.title == part, orElse: () {
          MyNode dirNode = getNode(part);
          parentNode!.addChild(dirNode);
          return dirNode;
        });
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
      return;
    }
    String? noteId = node.key;
    if (noteId != null) {
      Note note = widget.indexService.getNoteById(noteId) ?? Note();
      note.id = noteId;
      widget.onNoteSelected(note);
    }
  }
}
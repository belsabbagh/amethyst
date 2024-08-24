import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class MyNode {
  MyNode({
    required this.title,
    this.key,
    this.children = const <MyNode>[],
  });

  final String title;
  String? key;
  List<MyNode> children;

  // Ensure children list is modifiable
  void addChild(MyNode child) {
    children = List.from(children)..add(child);
  }
}

class MyTreeView extends StatefulWidget {
  const MyTreeView({
    Key? key,
    required this.treeController,
    required this.nodeBuilder,
  }) : super(key: key);

  final TreeController<MyNode> treeController;
  final Widget Function(BuildContext, TreeEntry<MyNode>) nodeBuilder;

  @override
  State<MyTreeView> createState() => _MyTreeViewState();
}

class _MyTreeViewState extends State<MyTreeView> {
  late final TreeController<MyNode> treeController;

  @override
  void initState() {
    super.initState();
    treeController = widget.treeController;
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TreeView<MyNode>(
      treeController: treeController,
      nodeBuilder: widget.nodeBuilder,
    );
  }
}

class MyTreeTile extends StatelessWidget {
  const MyTreeTile({
    Key? key,
    required this.entry,
    required this.onTap,
  }) : super(key: key);

  final TreeEntry<MyNode> entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: TreeIndentation(
        entry: entry,
        guide: const IndentGuide.connectingLines(indent: 48),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
          child: Row(
            children: [
              FolderButton(
                isOpen: entry.hasChildren ? entry.isExpanded : null,
                onPressed: entry.hasChildren ? onTap : null,
              ),
              Text(entry.node.title),
            ],
          ),
        ),
      ),
    );
  }
}

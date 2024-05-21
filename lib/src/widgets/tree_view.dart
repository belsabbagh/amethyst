import 'package:amethyst/src/core/indexer.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
// import 'package:flutter/material.dart';

// Map<String, dynamic> buildTree(List<String> paths) {
//   Map<String, dynamic> tree = {};

//   for (String path in paths) {
//     List<String> parts = path.split('/'); // Split path into parts
//     Map<String, dynamic> currentNode = tree;

//     for (int i = 0; i < parts.length; i++) {
//       String part = parts[i];
//       if (part.isNotEmpty) {
//         if (!currentNode.containsKey(part)) {
//           // If the part doesn't exist, create a new directory or file
//           if (i == parts.length - 1 || parts[i + 1].isEmpty) {
//             currentNode[part] = ''; // File
//           } else {
//             currentNode[part] = {}; // Directory
//           }
//         }
//         // Move to the next node
//         currentNode = currentNode[part];
//       }
//     }
//   }

//   return tree;
// }

TreeNode<String> buildTreeFromPath(String path) {
  TreeNode<String> root = TreeNode<String>();
  List<String> parts = path.split('/');
  if (parts[0] == path) {
    return TreeNode(key: parts[0], data: parts[0]);
  }
  dynamic currentNode = root;
  for (int i = 0; i < parts.length; i++) {
    String part = parts[i];
    if (part.isNotEmpty) {
      if (currentNode.children.containsKey(part)) {
        currentNode = currentNode.children[part]!;
        continue;
      }
      if (i == parts.length - 1 || parts[i + 1].isEmpty) {
        currentNode.children[part] =
            TreeNode(key: parts[0], data: parts[0]); // File
      } else {
        currentNode.children[part] =
            buildTreeFromPath(parts.sublist(i).join('/'));
      }
    }
  }
  return currentNode;
}

TreeNode<String> buildTree(IndexService indexService) {
  TreeNode<String> tree = TreeNode<String>();
  // for (String id in indexService.id2Path.keys) {
  //   String path = indexService.id2Path[id]!;
  //   tree.children[path] = buildTreeFromPath(path);
  // }
  return tree;
}

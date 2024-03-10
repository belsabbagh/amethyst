import 'dart:io';

import 'package:amethyst/src/core/dir_iter.dart';

import 'note.dart';

class Vault {
  final String path;
  Map<String, List<String>> tagsIndex = {};

  Vault({required this.path});

  void indexTags() {
    for (String notePath in DirectoryIterator.notesPathIter(path)) {
      Note note = Note.fromString(File(notePath).readAsStringSync());
      for (String tag in note.tags) {
        if (!tagsIndex.containsKey(tag)) {
          tagsIndex[tag] = [notePath];
          continue;
        }
        tagsIndex[tag]!.add(notePath);
      }
    }
  }
}

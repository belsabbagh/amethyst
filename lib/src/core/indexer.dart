import 'dart:io';

import 'package:amethyst/src/core/models/link.dart';
import 'package:amethyst/src/core/models/note.dart';
import 'package:amethyst/src/core/models/vault.dart';
import 'package:uuid/uuid.dart';

class IndexService {
  final Vault vault;
  Map<String, String> id2Path = {};
  Map<String, String> path2Id = {};
  Map<String, List<String>> outlinks = {};
  Map<String, List<String>> inlinks = {};
  Map<String, Set<String>> tags = {};
  IndexService({required this.vault});

  IndexService index() {
    id2Path = {};
    path2Id = {};
    outlinks = {};
    inlinks = {};

    for (String path in vault.notes) {
      String id = const Uuid().v8();
      id2Path[id] = path.replaceFirst(vault.path + Platform.pathSeparator, '');
      path2Id[id2Path[id]!] = id;
    }

    for (String id in List.from(id2Path.keys)) {
      String path = id2Path[id]!;
      String text = File(vault.absolutePath(path)).readAsStringSync();
      Note note = Note.fromString(text);
      for (String tag in note.tags) {
        tags.putIfAbsent(tag, () => {}).add(id);
      }
      for (NoteLink link in note.links.toList()) {
        String linkPath = link.path + '.md';
        String linkId = path2Id.putIfAbsent(linkPath, () 
        { print("isAbsent: $linkPath");
          return const Uuid().v8();});
        outlinks.putIfAbsent(id, () => []).add(linkId);
        inlinks.putIfAbsent(linkId, () => []).add(id);
      }
    }
    return this;
  }

  void updateNote(String id, String path, String text) {
    // remove outlinks and inlinks
    outlinks.remove(id);
    inlinks.remove(id);
    String oldPath = id2Path[id] ?? '';
    id2Path.remove(id);
    path2Id.remove(oldPath);

    id2Path[id] = path.replaceFirst(vault.path + Platform.pathSeparator, '');
    path2Id[id2Path[id]!] = id;
    Note note = Note.fromString(text);
    for (String tag in note.tags) {
      tags.putIfAbsent(tag, () => {}).add(id);
    }
    for (NoteLink link in note.links.toList()) {
      String linkPath = "${link.path}.md";
      String linkId = path2Id.putIfAbsent(linkPath, () => const Uuid().v8());
      outlinks.putIfAbsent(id, () => []).add(linkId);
      inlinks.putIfAbsent(linkId, () => []).add(id);
    }
  }

  int countNotes() {
    return id2Path.length;
  }

  Note? getNoteById(String id) {
    String? path = id2Path[id];
    if (path == null) {
      return null;
    }
    String fullPath = vault.absolutePath(path);
    Note n = Note.fromString(File(fullPath).readAsStringSync());
    n.id = id;
    return n;
  }

  Note? getNoteByPath(String path) {
    String? id = path2Id[path];
    if (id == null) {
      return null;
    }
    return getNoteById(id);
  }

  String getRootDirectory() {
    return vault.path;
  }
}

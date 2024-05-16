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

  IndexService({required this.vault});

  IndexService index() {
    id2Path = {};
    path2Id = {};
    outlinks = {};
    inlinks = {};

    for (String path in vault.notes) {
      String id = const Uuid().v8();
      id2Path[id] = path;
      path2Id[path] = id;
    }
    
    for (String id in id2Path.keys) {
      String path = id2Path[id]!;
      String text = File(path).readAsStringSync();
      Note note = Note.fromString(text);

      for (NoteLink link in note.links.toList()) {
        String linkPath = vault.absolutePath(link.path);
        String linkId = path2Id.putIfAbsent(linkPath, () => const Uuid().v8());
        outlinks.putIfAbsent(id, () => []).add(linkId);
        inlinks.putIfAbsent(linkId, () => []).add(id);
      }
    }
    return this;
  }

  int countNotes() {
    return id2Path.length;
  }
}

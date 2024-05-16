import 'dart:io';

import 'package:amethyst/src/core/models/note.dart';
import 'package:amethyst/src/core/models/vault.dart';
import 'package:uuid/uuid.dart';

class IndexService {
  final Vault vault;
  Map<Uuid, String> id2Path = {};
  Map<String, Uuid> path2Id = {};
  Map<Uuid, List<Uuid>> outlinks = {};
  Map<Uuid, List<Uuid>> inlinks = {};

  IndexService({required this.vault});

  Future<void> index() async {
    id2Path = {};
    path2Id = {};
    outlinks = {};
    inlinks = {};

    for (String path in vault.notes) {
      Uuid id = const Uuid();
      id2Path[id] = path;
      path2Id[path] = id;
    }

    for (Uuid id in id2Path.keys) {
      String path = id2Path[id]!;
      String text = File(path).readAsStringSync();
      Note note = Note.fromString(text);

      for (Link link in note.links.toList() as List<Link>) {
        String linkPath = vault.absolutePath(link.path);
        Uuid linkId = path2Id.putIfAbsent(linkPath, () => const Uuid());
        outlinks.putIfAbsent(id, () => []).add(linkId);
        inlinks.putIfAbsent(linkId, () => []).add(id);
      }
    }
  }
}

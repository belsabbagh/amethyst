import 'dart:io';

import 'package:amethyst/src/core/models/link.dart';
import 'package:amethyst/src/core/models/note.dart';
import 'package:amethyst/src/core/models/vault.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';

class FileForSql { 
  final String path; 
  final String text;
  final String tags;
  final String props; 

  final String indexerServiceId; 
  FileForSql({required this.indexerServiceId, required this.path, required this.text, this.tags = '', this.props = ''});
  
  Map<String, Object?> toMap() {
    return {
      'path': path,
      'text': text,
      'indexerServiceId': indexerServiceId,
      'tags': tags,
      'props': props,
    };
  }
}


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
        String linkPath = '${link.path}.md';
        String linkId = path2Id.putIfAbsent(linkPath, () 
        { print("isAbsent: $linkPath");
          return const Uuid().v8();});
        outlinks.putIfAbsent(id, () => []).add(linkId);
        inlinks.putIfAbsent(linkId, () => []).add(id);
      }
    }

    indexSql();
    return this;
  }

  void updateNote(String id, String path, String text) {
    // remove outlinks and inlinks
    outlinks.remove(id);
    inlinks.remove(id);
    String oldPath = id2Path[id] ?? '';
    id2Path.remove(id);
    path2Id.remove(oldPath);
    File(vault.absolutePath(oldPath)).rename(vault.absolutePath(path));
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

  void removeNote(String id) {
    String? path = id2Path[id];
    if (path == null) {
      return;
    }
    String fullPath = vault.absolutePath(path);
    File(fullPath).deleteSync();
    id2Path.remove(id);
    path2Id.remove(path);
  }

  Future<void> checkSqlFile() async {
    final db = await openDatabase('amethyst.db', version: 2, onCreate: (db, version) async {
      await db.execute('CREATE TABLE files(id INTEGER PRIMARY KEY, path TEXT, text TEXT, indexerServiceId TEXT, tags TEXT, props TEXT)');
    });
    await db.close();
  }

  Future<void> indexSql() async {
    await checkSqlFile();
    final db = await openDatabase('amethyst.db');
    await db.transaction((txn) async {
      await txn.execute('DELETE FROM files');
      for (String id in id2Path.keys) {
        Note note = getNoteById(id) ?? Note();
        FileForSql file = FileForSql(path: id2Path[id]!, text: note.body, indexerServiceId: id, tags: note.tags.join(','), props: note.props.toString());
        await txn.insert('files', file.toMap());
      }
    });
    await db.close();
    print('Indexed ${id2Path.length} notes');
  }

  Future<void> updateSql(String path, String text, String tags, String props) async {
    final db = await openDatabase('amethyst.db');
    await db.update('files', {'text': text, 'tags': tags, 'props': props}, where: 'path = ?', whereArgs: [path]);
    await db.close();
  }

  Future<void> updateSqlById(String id, String text, String tags, String props) async {
    final db = await openDatabase('amethyst.db');
    await db.update('files', {'text': text, 'tags': tags, 'props': props}, where: 'indexerServiceId = ?', whereArgs: [id]);
    await db.close();
  }

  Future<void> deleteSql(String path) async {
    final db = await openDatabase('amethyst.db');
    await db.delete('files', where: 'path = ?', whereArgs: [path]);
    await db.close();
  }

  Future<void> deleteSqlById(String id) async {
    final db = await openDatabase('amethyst.db');
    await db.delete('files', where: 'indexerServiceId = ?', whereArgs: [id]);
    await db.close();
  }

  Future<void> insertSql(String path, String text, String indexerServiceId, String tags, String props) async {
    final db = await openDatabase('amethyst.db');
    FileForSql file = FileForSql(path: path, text: text, indexerServiceId: indexerServiceId, tags: tags, props: props);
    await db.insert('files', file.toMap());
    await db.close();
  }

  Future<List<Note>> searchSql(String query) async {
    final db = await openDatabase('amethyst.db');
    List<Map<String, Object?>> results = await db.query('files', where: 'UPPER(text) LIKE UPPER(?) OR UPPER(tags) LIKE UPPER(?) OR UPPER(props) LIKE UPPER(?)', whereArgs: ['%$query%', '%$query%', '%$query%']);
    await db.close();
    return results.map((result) {
      Note note = getNoteById(result['indexerServiceId'] as String) ?? Note();
      return note;
    }).toList();
  }
}

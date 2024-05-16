import 'dart:io';

class DirectoryIterator {
  static Iterable<String> notesPathIter(path) sync* {
    for (FileSystemEntity entity in Directory(path).listSync(recursive: true)) {
      var parts = entity.path.split(Platform.pathSeparator);
      if (parts.map((e) => e.startsWith('.')).contains(true)) continue;
      if (entity is File && entity.path.endsWith('.md')) {
        yield entity.path;
      }
    }
  }
}

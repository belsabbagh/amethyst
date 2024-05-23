import 'dart:io';

class DirectoryIterator {
  static Iterable<String> notesPathIter(String path) sync* {
    for (FileSystemEntity entity in Directory(path).listSync(recursive: true)) {
      List<String> parts = entity.path.split(Platform.pathSeparator);
      if (parts.any((e) => e.startsWith('.'))) continue;
      if (entity is File && entity.path.endsWith('.md')) {
        yield entity.path;
      }
    }
  }
}

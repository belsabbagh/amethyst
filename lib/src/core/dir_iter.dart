import 'dart:io';

class DirectoryIterator {
  static Iterable<String> notesPathIter(path) sync* {
    for (FileSystemEntity entity in Directory(path).listSync(recursive: true)) {
      String basename = entity.path.split('/').last;
      if (basename.startsWith('.')) {
        continue;
      }
      if (entity is File) {
        yield entity.path;
      }
    }
  }
}

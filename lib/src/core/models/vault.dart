import 'package:amethyst/src/core/dir_iter.dart';

class Vault {
  final String path;
  Vault({required this.path});

  Iterable<String> get notes => DirectoryIterator.notesPathIter(path);

  String absolutePath(String filepath) => '$path/$filepath';

}

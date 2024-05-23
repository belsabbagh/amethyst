import 'package:amethyst/src/core/models/link.dart';
import 'package:yaml/yaml.dart';

class Parser {
  final RegExp frontMatterExp = RegExp(r'---\n([\s\S]+?)---\n(.+)');
  final RegExp tagsExp = RegExp(r'\#([a-zA-Z_\-\/]+\b)(?!;)');
  final RegExp linksExp = RegExp(r'\[\[(\w+)\]\]');

  Set<NoteLink> parseLinks(String body) {
    return linksExp.allMatches(body).map((m) {
      String str = m.group(1) ?? '';
      List<String> parts = str.split('|');
      return NoteLink(
          path: parts[0], alias: parts.length > 1 ? parts[1] : parts[0]);
    }).toSet();
  }

  Set<String> parseTags(String frontMatter) {
    return tagsExp.allMatches(frontMatter).map((m) => (m.group(1) ?? '').trim()).toSet();
  }

  Map<String, dynamic> parseProps(String frontMatter) {
    try {
    YamlMap yaml = loadYaml(frontMatter) ?? YamlMap();
    return Map.from(yaml);
    } catch (e) {
      return {};
    }
  }
}

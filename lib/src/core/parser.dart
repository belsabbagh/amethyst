import 'package:amethyst/src/core/models/link.dart';
import 'package:yaml/yaml.dart';

class Parser {
  final RegExp frontMatterExp = RegExp(r'---\n([\s\S]+?)---\n(.+)');
  final RegExp tagsExp = RegExp(r'#(\w+)');
  final RegExp linksExp = RegExp(r'\[\[(\w+)\]\]');

  Set<Link> parseLinks(String body) {
    return linksExp.allMatches(body).map((m) {
      String str = m.group(1) ?? '';
      List<String> parts = str.split('|');
      return Link(
          path: parts[0], alias: parts.length > 1 ? parts[1] : parts[0]);
    }).toSet();
  }

  Set<String> parseTags(String frontMatter) {
    return tagsExp.allMatches(frontMatter).map((m) => m.group(1) ?? '').toSet();
  }

  Map<String, dynamic> parseProps(String frontMatter) {
    YamlMap yaml = loadYaml(frontMatter);
    return Map.from(yaml);
  }
}

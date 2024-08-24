import 'package:amethyst/src/core/models/link.dart';
import 'package:yaml/yaml.dart';

class Parser {
  final RegExp frontMatterExp = RegExp(r'---\n([\s\S]+?)---\n(.+)', dotAll: true);
  final RegExp tagsExp = RegExp(r'\#([a-zA-Z_\-\/]+\b)(?!;)');
  final RegExp linksExp = RegExp(r'\[\[([^|]+?)(?:\|(.*?))*\]\]');

  Set<NoteLink> parseLinks(String body) {
    return linksExp.allMatches(body).map((m) {
      
      String path = m.group(1)!;

      String alias = '';
      try {
        alias = m.group(2)!;
      } catch (e) {
        alias = path;
      }
      return NoteLink(path: path, alias: alias);
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

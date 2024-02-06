import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

class Link {
  String path;
  String alias;

  Link({required this.path, required this.alias});
}

class Parser {
  static final RegExp frontMatterExp = RegExp(r'---\n([\s\S]+?)---\n(.+)');
  static final RegExp tagsExp = RegExp(r'#(\w+)');
  static final RegExp linksExp = RegExp(r'\[\[(\w+)\]\]');

  static Set<Link> parseLinks(String body) {
    return linksExp.allMatches(body).map((m) {
      // split by | to get alias
      String str = m.group(1) ?? '';
      List<String> parts = str.split('|');
      return Link(
          path: parts[0], alias: parts.length > 1 ? parts[1] : parts[0]);
    }).toSet();
  }

  static Set<String> parseTags(String frontMatter) {
    return tagsExp.allMatches(frontMatter).map((m) => m.group(1) ?? '').toSet();
  }

  static Map<String, dynamic> parseProps(String frontMatter) {
    YamlMap yaml = loadYaml(frontMatter);
    return Map.from(yaml);
  }
}

class Note {
  static final YamlWriter writer = YamlWriter(
    allowUnquotedStrings: true,
    indentSize: 2,
  );
  static Note fromString(String note) {
    Set<String> tags = Parser.parseTags(note);
    Set<Link> links = Parser.parseLinks(note);
    Match? match = Parser.frontMatterExp.firstMatch(note);
    String frontMatter = match?.group(1) ?? '';
    String body = match?.group(2) ?? note;
    Map<String, dynamic> props = Parser.parseProps(frontMatter);
    // add tags from props
    if (props.containsKey('tags')) {
      tags.addAll(Set.from(props['tags']));
      props.remove('tags');
    }
    return Note(
      tags: tags,
      body: body,
      props: props,
      links: links,
    );
  }

  Set<String> tags;
  String body;
  Map<String, dynamic> props;
  Set<Link> links;

  Note({
    this.tags = const {},
    this.body = '',
    this.props = const {},
    this.links = const {},
  });

  Note copyWith({
    Set<String>? tags,
    String? body,
    Map<String, dynamic>? props,
    Set<Link>? links,
  }) {
    return Note(
      tags: tags ?? this.tags,
      body: body ?? this.body,
      props: props ?? this.props,
      links: links ?? this.links,
    );
  }

  @override
  String toString() {
    Map<String, dynamic> p = Map.from(props);
    p['tags'] = tags.toList();
    String note = '---\n${writer.write(p)}---\n$body';
    return note;
  }
}

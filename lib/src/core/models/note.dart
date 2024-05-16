import 'package:amethyst/src/core/models/link.dart';
import 'package:amethyst/src/core/parser.dart';
import 'package:yaml_writer/yaml_writer.dart';

class Note {
  static final Parser _parser = Parser();
  static final YamlWriter writer = YamlWriter(
    allowUnquotedStrings: true,
    indentSize: 2,
  );
  static Note fromString(String note) {
    Set<String> tags = _parser.parseTags(note);
    Set<NoteLink> links = _parser.parseLinks(note);
    Match? match = _parser.frontMatterExp.firstMatch(note);
    String frontMatter = match?.group(1) ?? '';
    String body = match?.group(2) ?? note;
    Map<String, dynamic> props = _parser.parseProps(frontMatter);
    // add tags from props
    if (props.containsKey('tags')) {
      tags.addAll(Set.from(props['tags'] ?? []));
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
  Set<NoteLink> links;

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
    Set<NoteLink>? links,
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

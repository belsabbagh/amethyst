// This is an example unit test.
//
// A unit test tests a single function, method, or class. To learn more about
// writing unit tests, visit
// https://flutter.dev/docs/cookbook/testing/unit/introduction

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:amethyst/src/core/models/note.dart';

void main() {
  group('Note Parser', () {
    test('should parse tags from front matter', () {
      String note = '---\ntags: \n  - tag1\n  - tag2\nlat: 3.1415\n---\n# Body';
      Note n = Note.fromString(note);
      expect(n.body, '# Body');
      expect(n.tags, {'tag1', 'tag2'});
      expect(n.props, {'lat': 3.1415});
    });
  });
  group("Note Writer", () {
    test('should write tags to front matter', () {
      Note n = Note(
        tags: {'tag1', 'tag2'},
        body: '# Body',
        props: {'lat': 3.1415},
      );
      String note = n.toString();
      expect(note, '---\nlat: 3.1415\ntags: \n  - tag1\n  - tag2\n---\n# Body');
    });
  });
}

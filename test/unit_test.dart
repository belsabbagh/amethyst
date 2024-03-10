// This is an example unit test.
//
// A unit test tests a single function, method, or class. To learn more about
// writing unit tests, visit
// https://flutter.dev/docs/cookbook/testing/unit/introduction

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:amethyst/src/core/note.dart';

int? canReturnNullButDoesnt() => -3;

int canDeclareNullButDoesnt() {
  int? n = 1;
  return n;
}

List<int?> canHoldNulls() => [2, null, 4];

class Vector3D {
  double _x, _y, _z;
  Vector3D(this._x, this._y, this._z);

  Vector3D.fromList(List<double> ls)
      : _x = ls[0],
        _y = ls[1],
        _z = ls[2];

  String toString() {
    return "$_x, $_y, $_z";
  }
}

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
  group('Lab 1', () {
    test('should declare a list of strings', () {
      List<String> strs = ["one", "two", "three"];
      expect(strs, ["one", "two", "three"]);
      print(strs);
    });

    test('should declare a list of nullable strings', () {
      List<String?> strs = ["a", "b", null, "d"];
      expect(strs, ["a", "b", null, "d"]);
      print(strs);
    });

    test("should create function by expression",
        () => {expect(canReturnNullButDoesnt(), -3)});

    test("can be null but isn't", () => {expect(1, canDeclareNullButDoesnt())});
    test(
        "list can hold null",
        () => {
              expect([2, null, 4], canHoldNulls())
            });

    test("can hold null but doesn't", () {
      int? aa = canReturnNullButDoesnt();
      if (aa == null) {
        expect(true, false);
        return;
      }
      int? bb = canHoldNulls()[0];

      int cc = max(aa, -aa);

      expect(aa, -3);
      expect(bb, 2);
      expect(cc, 3);
    });

    test("can hold null but doesn't", () {
      int? aa = canReturnNullButDoesnt();
      if (aa == null) {
        expect(true, false);
        return;
      }
      int? bb = canHoldNulls()[0];

      int cc = max(aa, -aa);

      expect(aa, -3);
      expect(bb, 2);
      expect(cc, 3);
    });

    test("vector 3d class test", () {
      Vector3D x = Vector3D(11, 22, 33);
      Vector3D y = Vector3D.fromList([44, 55, 66]);

      expect(x.toString(), "11.0, 22.0, 33.0");
      expect(y.toString(), "44.0, 55.0, 66.0");
    });
  });
}

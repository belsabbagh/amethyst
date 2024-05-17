
class Tag {
  String name;
  Tag({required this.name}) {
    if (name.contains(' ')) {
      print('Warning: tag $name contains spaces');
      throw Exception('Tag name cannot contain spaces');
    }
  }
  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) =>
      other is Tag && other.name == name;
  @override
  int get hashCode => name.hashCode;

  bool isSubsetOf(Tag other) {
    return name.startsWith(other.name);
  }
}
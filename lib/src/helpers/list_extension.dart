extension ListExtension on List {
  List rotate(int start) {
    if (isEmpty || start == 0 || start >= length) return this;
    return sublist(start)..addAll(sublist(0, start));
  }
}

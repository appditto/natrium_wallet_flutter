import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Keeps a Dart List in sync with an AnimatedList.
///
/// This class only exposes as much of the Dart List API as is needed by the
/// sample app. More list methods are easily added, however methods that mutate the
/// list must make the same changes to the animated list in terms of
/// [AnimatedListState.insertItem] and [AnimatedList.removeItem].
class ListModel<E> {
  ListModel({
    @required this.listKey,
    Iterable<E> initialItems,
  })  : assert(listKey != null),
        _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final List<E> _items;

  List<E> get items => _items;

  AnimatedListState get _animatedList => listKey.currentState;

  void insertAtTop(E item) {
    _items.insert(0, item);
    _animatedList.insertItem(0);
  }
 
  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}

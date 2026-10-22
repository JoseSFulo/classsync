import 'dart:async';

/// Keeps a value in memory and tells listeners when it changes.
class FakeStore<T> {
  FakeStore(this._value);

  T _value;
  final _controller = StreamController<T>.broadcast();

  T get value => _value;

  set value(T next) {
    _value = next;
    _controller.add(next);
  }

  /// Emits the current value first, then every change.
  Stream<T> watch() async* {
    yield _value;
    yield* _controller.stream;
  }
}

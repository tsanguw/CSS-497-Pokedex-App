/// Caches the result of an async load for the lifetime of the app.
///
/// The first [get] starts the load; every later call (including calls made
/// while it is still running) gets the same future, so [load] runs once. If
/// the load fails the cache is cleared, so the next call tries again instead
/// of replaying the error forever.
class AsyncCache<T> {
  Future<T>? _future;

  Future<T> get(Future<T> Function() load) {
    final existing = _future;
    if (existing != null) return existing;

    final future = load();
    _future = future;
    future.then<void>((_) {}, onError: (Object _) {
      if (identical(_future, future)) _future = null;
    });
    return future;
  }
}

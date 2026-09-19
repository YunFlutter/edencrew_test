import 'package:flutter/foundation.dart';

import '../../../shared/favorites/favorite_store.dart';
import '../../../shared/models/load_status.dart';
import 'watchlist_view_state.dart';

class WatchlistViewModel extends ChangeNotifier {
  WatchlistViewModel({required FavoriteStore favoriteStore})
    : _favoriteStore = favoriteStore,
      _state = const WatchlistViewState.initial() {
    _favoriteStore.addListener(_syncFavorites);
    _syncFavorites();
  }

  final FavoriteStore _favoriteStore;
  WatchlistViewState _state;
  bool _disposed = false;

  WatchlistViewState get state => _state;

  void _syncFavorites() {
    if (_disposed) return;
    final stocks = _favoriteStore.stocks;
    _state = WatchlistViewState(
      status: stocks.isEmpty ? LoadStatus.empty : LoadStatus.success,
      stocks: stocks,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _favoriteStore.removeListener(_syncFavorites);
    super.dispose();
  }
}

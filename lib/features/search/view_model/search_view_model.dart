import 'package:flutter/foundation.dart';

import '../../../domain/models/stock.dart';
import '../../../shared/favorites/favorite_store.dart';
import '../../../shared/models/load_status.dart';
import 'search_view_state.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({required FavoriteStore favoriteStore})
    : _favoriteStore = favoriteStore {
    _favoriteStore.addListener(_onFavoritesChanged);
  }

  final FavoriteStore _favoriteStore;
  SearchViewState _state = const SearchViewState.initial();
  bool _disposed = false;

  SearchViewState get state => _state;

  bool isFavorite(String stockId) => _favoriteStore.contains(stockId);

  void changeQuery(String query) {
    if (_disposed) return;
    _state = SearchViewState(
      query: query,
      status: query.trim().isEmpty ? LoadStatus.initial : LoadStatus.empty,
      results: const <Stock>[],
    );
    notifyListeners();
  }

  bool toggleFavorite(Stock stock) => _favoriteStore.toggle(stock);

  void _onFavoritesChanged() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _favoriteStore.removeListener(_onFavoritesChanged);
    super.dispose();
  }
}

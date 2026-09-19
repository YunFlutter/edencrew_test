import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/models/stock.dart';
import '../../../domain/repositories/stock_repository.dart';
import '../../../shared/favorites/favorite_store.dart';
import '../../../shared/models/load_status.dart';
import 'search_view_state.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({
    required FavoriteStore favoriteStore,
    required StockRepository stockRepository,
    Duration searchDebounce = const Duration(milliseconds: 300),
    Duration feedbackDuration = const Duration(seconds: 2),
  }) : _favoriteStore = favoriteStore,
       _stockRepository = stockRepository,
       _searchDebounce = searchDebounce,
       _feedbackDuration = feedbackDuration {
    _favoriteStore.addListener(_onFavoritesChanged);
  }

  final FavoriteStore _favoriteStore;
  final StockRepository _stockRepository;
  final Duration _searchDebounce;
  final Duration _feedbackDuration;
  SearchViewState _state = const SearchViewState.initial();
  Timer? _searchTimer;
  Timer? _feedbackTimer;
  int _requestId = 0;
  bool _disposed = false;

  SearchViewState get state => _state;

  bool isFavorite(String stockId) => _favoriteStore.contains(stockId);

  void changeQuery(String query) {
    if (_disposed) return;
    _searchTimer?.cancel();
    final normalizedQuery = query.trim();
    _requestId++;
    _state = _state.copyWith(
      query: query,
      status: normalizedQuery.isEmpty ? LoadStatus.initial : LoadStatus.loading,
      results: const <Stock>[],
      clearErrorMessage: true,
    );
    notifyListeners();

    if (normalizedQuery.isEmpty) return;
    _searchTimer = Timer(_searchDebounce, () => search(normalizedQuery));
  }

  Future<void> search([String? query]) async {
    if (_disposed) return;
    _searchTimer?.cancel();
    final normalizedQuery = (query ?? _state.query).trim();
    if (normalizedQuery.isEmpty) {
      changeQuery('');
      return;
    }

    final requestId = ++_requestId;
    _state = _state.copyWith(
      query: query ?? _state.query,
      status: LoadStatus.loading,
      results: const <Stock>[],
      clearErrorMessage: true,
    );
    notifyListeners();

    try {
      final results = await _stockRepository.searchStocks(normalizedQuery);
      if (_disposed || requestId != _requestId) return;
      _state = _state.copyWith(
        status: results.isEmpty ? LoadStatus.empty : LoadStatus.success,
        results: results,
      );
    } on Object {
      if (_disposed || requestId != _requestId) return;
      _state = _state.copyWith(
        status: LoadStatus.error,
        results: const <Stock>[],
        errorMessage: '검색 결과를 불러오지 못했습니다.',
      );
    }
    notifyListeners();
  }

  bool toggleFavorite(Stock stock) {
    final isFavorite = _favoriteStore.toggle(stock);
    _feedbackTimer?.cancel();
    _state = _state.copyWith(
      favoriteFeedback: isFavorite
          ? SearchFavoriteFeedback.added
          : SearchFavoriteFeedback.removed,
    );
    notifyListeners();
    _feedbackTimer = Timer(_feedbackDuration, clearFavoriteFeedback);
    return isFavorite;
  }

  void clearFavoriteFeedback() {
    if (_disposed || _state.favoriteFeedback == null) return;
    _state = _state.copyWith(clearFavoriteFeedback: true);
    notifyListeners();
  }

  void _onFavoritesChanged() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestId++;
    _searchTimer?.cancel();
    _feedbackTimer?.cancel();
    _favoriteStore.removeListener(_onFavoritesChanged);
    super.dispose();
  }
}

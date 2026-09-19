import 'package:flutter/foundation.dart';

import '../../../domain/models/stock.dart';
import '../../../shared/favorites/favorite_store.dart';
import '../../../shared/models/load_status.dart';
import 'stock_detail_view_state.dart';

class StockDetailViewModel extends ChangeNotifier {
  StockDetailViewModel({
    required Stock stock,
    required FavoriteStore favoriteStore,
  }) : _favoriteStore = favoriteStore,
       _state = StockDetailViewState(
         stock: stock,
         status: LoadStatus.initial,
         period: StockPeriod.oneMonth,
         isFavorite: favoriteStore.contains(stock.id),
       ) {
    _favoriteStore.addListener(_syncFavorite);
  }

  final FavoriteStore _favoriteStore;
  StockDetailViewState _state;
  bool _disposed = false;

  StockDetailViewState get state => _state;

  void changePeriod(StockPeriod period) {
    if (_disposed || period == _state.period) return;
    _state = _state.copyWith(period: period);
    notifyListeners();
  }

  void toggleFavorite() {
    _favoriteStore.toggle(_state.stock);
  }

  void _syncFavorite() {
    if (_disposed) return;
    _state = _state.copyWith(
      isFavorite: _favoriteStore.contains(_state.stock.id),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _favoriteStore.removeListener(_syncFavorite);
    super.dispose();
  }
}

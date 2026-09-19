import 'package:flutter/foundation.dart';

import '../../domain/models/stock.dart';

class FavoriteStore extends ChangeNotifier {
  FavoriteStore({Iterable<Stock> initialStocks = const <Stock>[]})
    : _stocksById = <String, Stock>{
        for (final stock in initialStocks) stock.id: stock,
      };

  final Map<String, Stock> _stocksById;

  List<Stock> get stocks => List<Stock>.unmodifiable(_stocksById.values);

  bool contains(String stockId) => _stocksById.containsKey(stockId);

  bool add(Stock stock) {
    if (contains(stock.id)) return false;

    _stocksById[stock.id] = stock;
    notifyListeners();
    return true;
  }

  bool remove(String stockId) {
    if (_stocksById.remove(stockId) == null) return false;

    notifyListeners();
    return true;
  }

  bool toggle(Stock stock) {
    final isFavorite = !contains(stock.id);
    isFavorite ? add(stock) : remove(stock.id);
    return isFavorite;
  }

  void clear() {
    if (_stocksById.isEmpty) return;

    _stocksById.clear();
    notifyListeners();
  }
}

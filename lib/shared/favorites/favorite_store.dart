import 'package:flutter/foundation.dart';

import '../../domain/models/stock.dart';

class FavoriteStore extends ChangeNotifier {
  final Map<String, Stock> _stocksById = <String, Stock>{};

  List<Stock> get stocks => List<Stock>.unmodifiable(_stocksById.values);

  bool contains(String stockId) => _stocksById.containsKey(stockId);

  bool toggle(Stock stock) {
    final bool isFavorite;
    if (_stocksById.containsKey(stock.id)) {
      _stocksById.remove(stock.id);
      isFavorite = false;
    } else {
      _stocksById[stock.id] = stock;
      isFavorite = true;
    }
    notifyListeners();
    return isFavorite;
  }
}

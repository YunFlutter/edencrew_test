import 'package:edencrew_assignment_starter/domain/models/stock.dart';
import 'package:edencrew_assignment_starter/features/search/view_model/search_view_model.dart';
import 'package:edencrew_assignment_starter/features/stock_detail/view_model/stock_detail_view_model.dart';
import 'package:edencrew_assignment_starter/features/watchlist/view_model/watchlist_view_model.dart';
import 'package:edencrew_assignment_starter/shared/favorites/favorite_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_stock_repository.dart';

void main() {
  test('관심 상태 변경이 세 ViewModel에 함께 반영된다', () {
    final store = FavoriteStore();
    final repository = FakeStockRepository();
    final stock = Stock.domestic(symbol: '005930', name: '삼성전자', market: '코스피');
    final watchlist = WatchlistViewModel(
      favoriteStore: store,
      stockRepository: repository,
    );
    final search = SearchViewModel(favoriteStore: store);
    final detail = StockDetailViewModel(stock: stock, favoriteStore: store);

    detail.toggleFavorite();

    expect(watchlist.state.stocks, contains(stock));
    expect(search.isFavorite(stock.id), isTrue);
    expect(detail.state.isFavorite, isTrue);

    search.toggleFavorite(stock);

    expect(watchlist.state.stocks, isEmpty);
    expect(search.isFavorite(stock.id), isFalse);
    expect(detail.state.isFavorite, isFalse);

    watchlist.dispose();
    search.dispose();
    detail.dispose();
    store.dispose();
  });
}

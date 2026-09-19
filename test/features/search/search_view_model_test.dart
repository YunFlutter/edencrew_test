import 'package:edencrew_assignment_starter/domain/models/stock.dart';
import 'package:edencrew_assignment_starter/features/search/view_model/search_view_model.dart';
import 'package:edencrew_assignment_starter/features/search/view_model/search_view_state.dart';
import 'package:edencrew_assignment_starter/shared/favorites/favorite_store.dart';
import 'package:edencrew_assignment_starter/shared/models/load_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_stock_repository.dart';

void main() {
  late FavoriteStore favoriteStore;

  setUp(() {
    favoriteStore = FavoriteStore();
  });

  tearDown(() {
    favoriteStore.dispose();
  });

  test('검색 성공 결과와 검색어를 상태에 반영한다', () async {
    final stock = Stock.domestic(symbol: '005930', name: '삼성전자', market: '코스피');
    final repository = FakeStockRepository(searchResults: <Stock>[stock]);
    final viewModel = SearchViewModel(
      favoriteStore: favoriteStore,
      stockRepository: repository,
    );

    await viewModel.search('삼성');

    expect(viewModel.state.status, LoadStatus.success);
    expect(viewModel.state.query, '삼성');
    expect(viewModel.state.results, <Stock>[stock]);
    expect(repository.lastSearchQuery, '삼성');
    viewModel.dispose();
  });

  test('검색 결과 없음과 입력 초기화를 구분한다', () async {
    final repository = FakeStockRepository();
    final viewModel = SearchViewModel(
      favoriteStore: favoriteStore,
      stockRepository: repository,
    );

    await viewModel.search('없는종목');
    expect(viewModel.state.status, LoadStatus.empty);

    viewModel.changeQuery('   ');
    expect(viewModel.state.status, LoadStatus.initial);
    expect(viewModel.state.results, isEmpty);
    viewModel.dispose();
  });

  test('검색 오류에 재시도 가능한 오류 상태를 만든다', () async {
    final repository = FakeStockRepository(searchError: Exception('network'));
    final viewModel = SearchViewModel(
      favoriteStore: favoriteStore,
      stockRepository: repository,
    );

    await viewModel.search('삼성');

    expect(viewModel.state.status, LoadStatus.error);
    expect(viewModel.state.errorMessage, isNotNull);
    viewModel.dispose();
  });

  test('관심 등록과 해제 피드백은 새 동작으로 교체된다', () {
    final stock = Stock.domestic(symbol: '005930', name: '삼성전자', market: '코스피');
    final viewModel = SearchViewModel(
      favoriteStore: favoriteStore,
      stockRepository: FakeStockRepository(),
    );

    viewModel.toggleFavorite(stock);
    expect(viewModel.isFavorite(stock.id), isTrue);
    expect(viewModel.state.favoriteFeedback, SearchFavoriteFeedback.added);

    viewModel.toggleFavorite(stock);
    expect(viewModel.isFavorite(stock.id), isFalse);
    expect(viewModel.state.favoriteFeedback, SearchFavoriteFeedback.removed);

    viewModel.clearFavoriteFeedback();
    expect(viewModel.state.favoriteFeedback, isNull);
    viewModel.dispose();
  });
}

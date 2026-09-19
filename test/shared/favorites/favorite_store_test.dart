import 'package:edencrew_assignment_starter/domain/models/stock.dart';
import 'package:edencrew_assignment_starter/shared/favorites/favorite_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('관심 종목을 등록하고 다시 누르면 해제한다', () {
    final store = FavoriteStore();
    final stock = Stock.domestic(symbol: '005930', name: '삼성전자', market: '코스피');

    expect(store.toggle(stock), isTrue);
    expect(store.contains(stock.id), isTrue);
    expect(store.stocks, contains(stock));

    expect(store.toggle(stock), isFalse);
    expect(store.contains(stock.id), isFalse);
    expect(store.stocks, isEmpty);

    store.dispose();
  });
}

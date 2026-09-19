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

  test('초기 관심 종목의 순서를 유지하고 외부에서 목록을 수정할 수 없다', () {
    final samsung = Stock.domestic(
      symbol: '005930',
      name: '삼성전자',
      market: '코스피',
    );
    final skHynix = Stock.domestic(
      symbol: '000660',
      name: 'SK하이닉스',
      market: '코스피',
    );
    final store = FavoriteStore(initialStocks: <Stock>[samsung, skHynix]);

    expect(store.stocks, <Stock>[samsung, skHynix]);
    expect(() => store.stocks.add(samsung), throwsUnsupportedError);

    store.dispose();
  });

  test('실제로 상태가 바뀔 때만 구독자에게 알린다', () {
    final store = FavoriteStore();
    final stock = Stock.domestic(symbol: '005930', name: '삼성전자', market: '코스피');
    var notificationCount = 0;
    store.addListener(() => notificationCount++);

    expect(store.add(stock), isTrue);
    expect(store.add(stock), isFalse);
    expect(store.remove('domestic:000660'), isFalse);
    expect(notificationCount, 1);

    expect(store.remove(stock.id), isTrue);
    expect(notificationCount, 2);

    store.clear();
    expect(notificationCount, 2);

    store.add(stock);
    store.clear();
    expect(store.stocks, isEmpty);
    expect(notificationCount, 4);

    store.dispose();
  });
}

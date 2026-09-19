import 'package:edencrew_assignment_starter/data/datasources/mock_naver_stock_remote_data_source.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNaverStockRemoteDataSource dataSource;

  setUp(() {
    dataSource = MockNaverStockRemoteDataSource(assetBundle: rootBundle);
  });

  test('여러 국내 종목을 이름과 종목코드로 검색한다', () async {
    final samsungStocks = await dataSource.searchStocks('삼성');
    final byName = await dataSource.searchStocks('카카오');
    final bySymbol = await dataSource.searchStocks('035420');
    final unsupported = await dataSource.searchStocks('애플');

    expect(samsungStocks.length, greaterThan(1));
    expect(byName.single.symbol, '035720');
    expect(bySymbol.single.name, 'NAVER');
    expect(unsupported, isEmpty);
  });

  test('fixture와 개발용 종목 모두 요청한 시세를 반환한다', () async {
    final quotes = await dataSource.getQuotes(<String>['005930', '035420']);

    expect(quotes, hasLength(2));
    expect(
      quotes.map((quote) => quote.symbol),
      containsAll(<String>['005930', '035420']),
    );
    expect(quotes.every((quote) => quote.currentPrice > 0), isTrue);
  });

  test('일별 시세 페이지 경계에서도 날짜와 가격 흐름이 이어진다', () async {
    final firstPage = await dataSource.getDailyPrices('005930', 1);
    final secondPage = await dataSource.getDailyPrices('005930', 2);

    expect(firstPage.items, hasLength(10));
    expect(secondPage.items, hasLength(10));
    expect(firstPage.lastPage, 25);
    expect(secondPage.lastPage, 25);
    expect(
      secondPage.items.first.localDate.compareTo(
        firstPage.items.last.localDate,
      ),
      lessThan(0),
    );
    final boundaryChange =
        (firstPage.items.last.closePrice - secondPage.items.first.closePrice)
            .abs() /
        firstPage.items.last.closePrice;
    expect(boundaryChange, lessThan(0.05));
    expect(
      firstPage.items.map((item) => item.closePrice).toSet().length,
      greaterThan(5),
    );
  });
}

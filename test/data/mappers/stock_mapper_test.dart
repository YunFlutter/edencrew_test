import 'package:edencrew_assignment_starter/data/dto/daily_price_dto.dart';
import 'package:edencrew_assignment_starter/data/dto/realtime_quote_dto.dart';
import 'package:edencrew_assignment_starter/data/dto/search_stock_dto.dart';
import 'package:edencrew_assignment_starter/data/dto/stock_metadata_dto.dart';
import 'package:edencrew_assignment_starter/data/mappers/stock_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('국내 6자리 종목에 canonical id를 부여한다', () {
    const dto = SearchStockDto(
      symbol: '005930',
      name: '삼성전자',
      market: '코스피',
      nationCode: 'KOR',
      category: 'stock',
    );

    final stock = StockMapper.fromSearchDto(dto);

    expect(stock?.id, 'domestic:005930');
  });

  test('해외 종목과 6자리가 아닌 코드를 제외한다', () {
    const overseas = SearchStockDto(
      symbol: 'AAPL',
      name: 'Apple',
      market: 'NASDAQ',
      nationCode: 'USA',
      category: 'stock',
    );

    expect(StockMapper.fromSearchDto(overseas), isNull);
  });

  test('국내 지수는 6자리 코드여도 주식 검색 결과에서 제외한다', () {
    const index = SearchStockDto(
      symbol: '123456',
      name: '테스트 지수',
      market: '코스피',
      nationCode: 'KOR',
      category: 'index',
    );

    expect(StockMapper.fromSearchDto(index), isNull);
  });

  test('메타데이터 DTO를 canonical id가 있는 종목으로 변환한다', () {
    const dto = StockMetadataDto(symbol: '005930', name: '삼성전자', market: '코스피');

    final stock = StockMapper.fromMetadataDto(dto);

    expect(stock.id, 'domestic:005930');
    expect(stock.name, '삼성전자');
    expect(stock.market, '코스피');
  });

  test('실시간 시세 DTO를 계산 가능한 Domain Model로 변환한다', () {
    const dto = RealtimeQuoteDto(
      symbol: '005930',
      currentPrice: 260000,
      previousClose: 252500,
      openPrice: 261000,
      highPrice: 262000,
      lowPrice: 257500,
      accumulatedTradingVolume: 15042569,
      countOfListedStock: 5846278608,
    );

    final quote = StockMapper.fromQuoteDto(dto);

    expect(quote.symbol, '005930');
    expect(quote.priceChange, 7500);
    expect(quote.changeRate, closeTo(2.970297, 0.000001));
  });

  test('일별 시세 페이지 DTO를 Domain Model 페이지로 변환한다', () {
    const dto = DailyPricePageDto(
      items: [
        DailyPriceDto(
          localDate: '20240424',
          closePrice: 78600,
          openPrice: 77500,
          highPrice: 78800,
          lowPrice: 77200,
          accumulatedTradingVolume: 21804564,
        ),
      ],
      lastPage: 698,
    );

    final page = StockMapper.fromDailyPricePageDto(dto);

    expect(page.items.single.localDate, '20240424');
    expect(page.items.single.closePrice, 78600);
    expect(page.lastPage, 698);
  });
}

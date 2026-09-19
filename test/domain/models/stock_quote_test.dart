import 'package:edencrew_assignment_starter/domain/models/stock_quote.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('등락액, 등락률, 시가총액을 원본 시세에서 계산한다', () {
    const quote = StockQuote(
      symbol: '005930',
      currentPrice: 260000,
      previousClose: 252500,
      openPrice: 261000,
      highPrice: 262000,
      lowPrice: 257500,
      accumulatedTradingVolume: 15042569,
      countOfListedStock: 5846278608,
    );

    expect(quote.priceChange, 7500);
    expect(quote.direction, PriceChangeDirection.up);
    expect(quote.changeRate, closeTo(2.970297, 0.000001));
    expect(quote.marketCapitalization, 1520032438080000);
  });

  test('등락액 부호로 상승, 하락, 보합을 구분한다', () {
    StockQuote quoteWithCurrentPrice(int currentPrice) => StockQuote(
      symbol: '005930',
      currentPrice: currentPrice,
      previousClose: 100,
      openPrice: 100,
      highPrice: 100,
      lowPrice: 100,
      accumulatedTradingVolume: 0,
      countOfListedStock: 1,
    );

    expect(quoteWithCurrentPrice(101).direction, PriceChangeDirection.up);
    expect(quoteWithCurrentPrice(99).direction, PriceChangeDirection.down);
    expect(quoteWithCurrentPrice(100).direction, PriceChangeDirection.flat);
  });

  test('전일 종가가 0이면 등락률은 0으로 처리한다', () {
    const quote = StockQuote(
      symbol: '005930',
      currentPrice: 100,
      previousClose: 0,
      openPrice: 0,
      highPrice: 100,
      lowPrice: 0,
      accumulatedTradingVolume: 0,
      countOfListedStock: 1,
    );

    expect(quote.changeRate, 0);
  });
}

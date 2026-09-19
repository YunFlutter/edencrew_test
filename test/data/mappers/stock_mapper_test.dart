import 'package:edencrew_assignment_starter/data/dto/search_stock_dto.dart';
import 'package:edencrew_assignment_starter/data/mappers/stock_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('국내 6자리 종목에 canonical id를 부여한다', () {
    const dto = SearchStockDto(
      symbol: '005930',
      name: '삼성전자',
      market: '코스피',
      nationCode: 'KOR',
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
    );

    expect(StockMapper.fromSearchDto(overseas), isNull);
  });
}

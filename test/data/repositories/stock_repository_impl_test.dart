import 'package:edencrew_assignment_starter/data/datasources/naver_stock_remote_data_source.dart';
import 'package:edencrew_assignment_starter/data/dto/daily_price_dto.dart';
import 'package:edencrew_assignment_starter/data/dto/realtime_quote_dto.dart';
import 'package:edencrew_assignment_starter/data/dto/search_stock_dto.dart';
import 'package:edencrew_assignment_starter/data/dto/stock_metadata_dto.dart';
import 'package:edencrew_assignment_starter/data/repositories/stock_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('같은 symbol과 page의 일별 시세 요청을 한 번만 수행한다', () async {
    final dataSource = _FakeRemoteDataSource();
    final repository = StockRepositoryImpl(remoteDataSource: dataSource);

    final first = repository.getDailyPrices('005930', 1);
    final second = repository.getDailyPrices('005930', 1);
    await Future.wait(<Future<Object>>[first, second]);
    await repository.getDailyPrices('005930', 1);

    expect(dataSource.dailyPriceRequestCount, 1);
  });
}

class _FakeRemoteDataSource implements NaverStockRemoteDataSource {
  int dailyPriceRequestCount = 0;

  @override
  Future<DailyPricePageDto> getDailyPrices(String symbol, int page) async {
    dailyPriceRequestCount++;
    return const DailyPricePageDto(items: <DailyPriceDto>[], lastPage: 1);
  }

  @override
  Future<List<RealtimeQuoteDto>> getQuotes(List<String> symbols) {
    throw UnimplementedError();
  }

  @override
  Future<StockMetadataDto> getStockMetadata(String symbol) {
    throw UnimplementedError();
  }

  @override
  Future<List<SearchStockDto>> searchStocks(String query) {
    throw UnimplementedError();
  }
}

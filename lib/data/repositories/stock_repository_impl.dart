import '../../domain/models/daily_price.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/stock_quote.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/naver_stock_remote_data_source.dart';
import '../mappers/stock_mapper.dart';

class StockRepositoryImpl implements StockRepository {
  StockRepositoryImpl({required NaverStockRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final NaverStockRemoteDataSource _remoteDataSource;

  @override
  Future<List<Stock>> searchStocks(String query) async {
    final dtos = await _remoteDataSource.searchStocks(query);
    return dtos.map(StockMapper.fromSearchDto).whereType<Stock>().toList();
  }

  @override
  Future<Map<String, StockQuote>> getQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return const <String, StockQuote>{};
    final dtos = await _remoteDataSource.getQuotes(symbols);
    return <String, StockQuote>{
      for (final dto in dtos) dto.symbol: StockMapper.fromQuoteDto(dto),
    };
  }

  @override
  Future<Stock> getStockMetadata(String symbol) async {
    final dto = await _remoteDataSource.getStockMetadata(symbol);
    return StockMapper.fromMetadataDto(dto);
  }

  @override
  Future<DailyPricePage> getDailyPrices(String symbol, int page) async {
    final dto = await _remoteDataSource.getDailyPrices(symbol, page);
    return DailyPricePage(
      items: dto.items.map(StockMapper.fromDailyPriceDto).toList(),
      lastPage: dto.lastPage,
    );
  }
}

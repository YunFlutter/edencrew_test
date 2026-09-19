import '../dto/daily_price_dto.dart';
import '../dto/realtime_quote_dto.dart';
import '../dto/search_stock_dto.dart';
import '../dto/stock_metadata_dto.dart';

/// Naver의 JSON/HTML 형식을 앱 나머지 계층에서 격리하는 경계입니다.
///
/// HTTP 요청과 파싱은 다음 데이터 연동 작업에서 이 계약을 구현합니다.
abstract interface class NaverStockRemoteDataSource {
  Future<List<SearchStockDto>> searchStocks(String query);

  Future<List<RealtimeQuoteDto>> getQuotes(List<String> symbols);

  Future<StockMetadataDto> getStockMetadata(String symbol);

  Future<DailyPricePageDto> getDailyPrices(String symbol, int page);
}

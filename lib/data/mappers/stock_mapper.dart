import '../../domain/models/daily_price.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/stock_quote.dart';
import '../dto/daily_price_dto.dart';
import '../dto/realtime_quote_dto.dart';
import '../dto/search_stock_dto.dart';
import '../dto/stock_metadata_dto.dart';

abstract final class StockMapper {
  static Stock? fromSearchDto(SearchStockDto dto) {
    if (dto.nationCode != 'KOR' || !RegExp(r'^\d{6}$').hasMatch(dto.symbol)) {
      return null;
    }
    return Stock.domestic(
      symbol: dto.symbol,
      name: dto.name,
      market: dto.market,
    );
  }

  static Stock fromMetadataDto(StockMetadataDto dto) =>
      Stock.domestic(symbol: dto.symbol, name: dto.name, market: dto.market);

  static StockQuote fromQuoteDto(RealtimeQuoteDto dto) => StockQuote(
    symbol: dto.symbol,
    currentPrice: dto.currentPrice,
    previousClose: dto.previousClose,
    openPrice: dto.openPrice,
    highPrice: dto.highPrice,
    lowPrice: dto.lowPrice,
    accumulatedTradingVolume: dto.accumulatedTradingVolume,
    countOfListedStock: dto.countOfListedStock,
  );

  static DailyPrice fromDailyPriceDto(DailyPriceDto dto) => DailyPrice(
    localDate: dto.localDate,
    closePrice: dto.closePrice,
    openPrice: dto.openPrice,
    highPrice: dto.highPrice,
    lowPrice: dto.lowPrice,
    accumulatedTradingVolume: dto.accumulatedTradingVolume,
  );
}

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../../core/error/app_exception.dart';
import '../dto/daily_price_dto.dart';
import '../dto/realtime_quote_dto.dart';
import '../dto/search_stock_dto.dart';
import '../dto/stock_metadata_dto.dart';
import '../parsers/naver_daily_price_parser.dart';
import '../parsers/naver_stock_response_parser.dart';
import '../parsers/naver_text_decoder.dart';
import 'naver_stock_remote_data_source.dart';

/// 저장된 Naver 응답과 개발용 종목 카탈로그를 사용하는 DataSource입니다.
///
/// JSON/HTML fixture는 운영 DataSource와 같은 파서에 통과시킵니다. fixture에 없는
/// 종목의 시세와 기간별 OHLC는 네트워크 없는 화면·캐시 검증을 위해 종목코드에서
/// 결정적으로 생성하며, 실제 시세로 취급하지 않습니다.
class MockNaverStockRemoteDataSource implements NaverStockRemoteDataSource {
  MockNaverStockRemoteDataSource({required AssetBundle assetBundle})
    : _assetBundle = assetBundle;

  static const int _mockLastPage = 25;
  static const Map<String, int> _mockCurrentPrices = <String, int>{
    '005930': 260000,
    '000660': 1849000,
    '035420': 230000,
    '035720': 62000,
    '005380': 298000,
    '373220': 385000,
    '068270': 210000,
    '247540': 145000,
    '105560': 124000,
    '012450': 980000,
    '009150': 290000,
    '006400': 320000,
    '010140': 27000,
    '005935': 220000,
  };

  final AssetBundle _assetBundle;
  Future<List<SearchStockDto>>? _catalogRequest;
  Future<Map<String, RealtimeQuoteDto>>? _quoteFixtureRequest;
  Future<DailyPricePageDto>? _dailyFixtureRequest;

  @override
  Future<List<SearchStockDto>> searchStocks(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return const <SearchStockDto>[];

    final catalog = await _loadCatalog();
    return catalog
        .where(
          (stock) =>
              stock.symbol.contains(normalizedQuery) ||
              stock.name.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);
  }

  @override
  Future<List<RealtimeQuoteDto>> getQuotes(List<String> symbols) async {
    final catalog = <String, SearchStockDto>{
      for (final stock in await _loadCatalog()) stock.symbol: stock,
    };
    final fixtureQuotes = await _loadQuoteFixture();
    return <RealtimeQuoteDto>[
      for (final symbol in symbols.toSet())
        if (catalog.containsKey(symbol))
          fixtureQuotes[symbol] ?? _createQuote(symbol),
    ];
  }

  @override
  Future<StockMetadataDto> getStockMetadata(String symbol) async {
    final stock = (await _loadCatalog())
        .where((candidate) => candidate.symbol == symbol)
        .firstOrNull;
    if (stock == null) throw _unsupportedSymbol(symbol);
    return StockMetadataDto(
      symbol: stock.symbol,
      name: stock.name,
      market: stock.market,
    );
  }

  @override
  Future<DailyPricePageDto> getDailyPrices(String symbol, int page) async {
    if (page < 1 || page > _mockLastPage) {
      throw RangeError.range(page, 1, _mockLastPage, 'page');
    }
    final quotes = await getQuotes(<String>[symbol]);
    if (quotes.isEmpty) throw _unsupportedSymbol(symbol);

    final quote = quotes.single;
    final fixture = await _loadDailyFixture();
    final symbolSeed = int.parse(symbol);
    return DailyPricePageDto(
      lastPage: _mockLastPage,
      items: <DailyPriceDto>[
        for (var index = 0; index < 10; index++)
          _createDailyPrice(
            quote: quote,
            symbolSeed: symbolSeed,
            dayIndex: (page - 1) * 10 + index,
            volumeSeed: fixture.items[index].accumulatedTradingVolume,
          ),
      ],
    );
  }

  Future<List<SearchStockDto>> _loadCatalog() {
    return _catalogRequest ??= () async {
      final response = jsonDecode(
        await _assetBundle.loadString('assets/mock/search_stock_catalog.json'),
      );
      return NaverStockResponseParser.parseSearch(response);
    }();
  }

  Future<Map<String, RealtimeQuoteDto>> _loadQuoteFixture() {
    return _quoteFixtureRequest ??= () async {
      final response = jsonDecode(
        NaverTextDecoder.decode(
          await _loadBytes('assets/mock/realtime_quotes_005930_000660.json'),
          charset: 'euc-kr',
        ),
      );
      return <String, RealtimeQuoteDto>{
        for (final quote in NaverStockResponseParser.parseQuotes(response))
          quote.symbol: quote,
      };
    }();
  }

  Future<DailyPricePageDto> _loadDailyFixture() {
    return _dailyFixtureRequest ??= () async {
      return NaverDailyPriceParser.parseBytes(
        await _loadBytes(
          'assets/mock/daily_prices_005930_page_1_20240424.html',
        ),
      );
    }();
  }

  RealtimeQuoteDto _createQuote(String symbol) {
    final seed = int.parse(symbol);
    final currentPrice =
        _mockCurrentPrices[symbol] ?? _roundPrice(30000 + seed % 470000);
    final direction = seed.isEven ? 1 : -1;
    final priceChange = _roundPrice(
      currentPrice * (0.006 + (seed % 17) / 1000),
    );
    final previousClose = currentPrice - direction * priceChange;
    final openPrice = _roundPrice(
      previousClose * (1 + math.sin(seed.toDouble()) * 0.008),
    );
    final highPrice = _roundPrice(math.max(currentPrice, openPrice) * 1.013);
    final lowPrice = _roundPrice(math.min(currentPrice, openPrice) * 0.987);
    return RealtimeQuoteDto(
      symbol: symbol,
      currentPrice: currentPrice,
      previousClose: previousClose,
      openPrice: openPrice,
      highPrice: highPrice,
      lowPrice: lowPrice,
      accumulatedTradingVolume: 3000000 + seed % 27000000,
      countOfListedStock: 100000000 + seed % 1900000000,
    );
  }

  DailyPriceDto _createDailyPrice({
    required RealtimeQuoteDto quote,
    required int symbolSeed,
    required int dayIndex,
    required int volumeSeed,
  }) {
    final close = _historicalClose(
      currentPrice: quote.currentPrice,
      symbolSeed: symbolSeed,
      dayIndex: dayIndex,
    );
    final previousClose = _historicalClose(
      currentPrice: quote.currentPrice,
      symbolSeed: symbolSeed,
      dayIndex: dayIndex + 1,
    );
    final gap = math.sin((symbolSeed + dayIndex * 13) * 0.17) * 0.006;
    final open = _roundPrice(previousClose * (1 + gap));
    final spread = 0.008 + (symbolSeed + dayIndex) % 9 / 1000;
    final high = _roundPrice(math.max(open, close) * (1 + spread));
    final low = _roundPrice(math.min(open, close) * (1 - spread));
    final volumeScale = 0.65 + symbolSeed % 11 / 20;
    return DailyPriceDto(
      localDate: _formatDate(_tradingDate(dayIndex)),
      closePrice: close,
      openPrice: open,
      highPrice: high,
      lowPrice: math.max(1, low),
      accumulatedTradingVolume: (volumeSeed * volumeScale).round(),
    );
  }

  int _historicalClose({
    required int currentPrice,
    required int symbolSeed,
    required int dayIndex,
  }) {
    final phase = symbolSeed % 37 / 5;
    final wave = math.sin(dayIndex * 0.23 + phase) * 0.018;
    final shortWave = math.sin(dayIndex * 0.61 + phase / 2) * 0.008;
    final baseWave = math.sin(phase) * 0.018 + math.sin(phase / 2) * 0.008;
    final trend = dayIndex * 0.00028;
    return _roundPrice(
      currentPrice * (1 + wave + shortWave - baseWave - trend),
    );
  }

  int _roundPrice(num value) {
    final safeValue = math.max(1, value).toDouble();
    final tick = safeValue >= 100000
        ? 100
        : safeValue >= 10000
        ? 50
        : 10;
    return (safeValue / tick).round() * tick;
  }

  DateTime _tradingDate(int dayIndex) {
    var date = DateTime.utc(2026, 9, 18);
    var remaining = dayIndex;
    while (remaining > 0) {
      date = date.subtract(const Duration(days: 1));
      if (date.weekday <= DateTime.friday) remaining--;
    }
    return date;
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';

  Future<Uint8List> _loadBytes(String path) async {
    final data = await _assetBundle.load(path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  ParsingException _unsupportedSymbol(String symbol) =>
      ParsingException('개발용 mock 종목 카탈로그에 없는 종목입니다: $symbol');
}

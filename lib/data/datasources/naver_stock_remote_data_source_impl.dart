import 'dart:convert';
import 'dart:io';

import '../dto/daily_price_dto.dart';
import '../dto/realtime_quote_dto.dart';
import '../dto/search_stock_dto.dart';
import '../dto/stock_metadata_dto.dart';
import '../parsers/naver_daily_price_parser.dart';
import '../parsers/naver_stock_response_parser.dart';
import 'naver_stock_remote_data_source.dart';

class NaverStockRemoteDataSourceImpl implements NaverStockRemoteDataSource {
  NaverStockRemoteDataSourceImpl({required HttpClient httpClient})
    : _httpClient = httpClient;

  final HttpClient _httpClient;

  @override
  Future<List<SearchStockDto>> searchStocks(String query) async {
    final uri = Uri.https('ac.stock.naver.com', '/ac', <String, String>{
      'q': query,
      'target': 'stock,ipo,index,marketindicator',
    });
    return NaverStockResponseParser.parseSearch(await _getJson(uri));
  }

  @override
  Future<List<RealtimeQuoteDto>> getQuotes(List<String> symbols) async {
    final uri = Uri.https(
      'polling.finance.naver.com',
      '/api/realtime',
      <String, String>{'query': 'SERVICE_ITEM:${symbols.join(',')}'},
    );
    return NaverStockResponseParser.parseQuotes(await _getJson(uri));
  }

  @override
  Future<StockMetadataDto> getStockMetadata(String symbol) async {
    final uri = Uri.https(
      'stock.naver.com',
      '/api/securityFe/api/fchart/domestic/stock/$symbol',
    );
    return NaverStockResponseParser.parseMetadata(await _getJson(uri));
  }

  @override
  Future<DailyPricePageDto> getDailyPrices(String symbol, int page) async {
    final uri = Uri.https(
      'finance.naver.com',
      '/item/sise_day.naver',
      <String, String>{'code': symbol, 'page': '$page'},
    );
    return NaverDailyPriceParser.parseBytes(await _getBytes(uri));
  }

  Future<Object?> _getJson(Uri uri) async {
    final bytes = await _getBytes(uri);
    return jsonDecode(utf8.decode(bytes));
  }

  Future<List<int>> _getBytes(Uri uri) async {
    final request = await _httpClient.getUrl(uri);
    request.headers
      ..set(HttpHeaders.acceptHeader, '*/*')
      ..set(
        HttpHeaders.userAgentHeader,
        'Mozilla/5.0 (Mobile; Edencrew assignment)',
      )
      ..set(HttpHeaders.refererHeader, 'https://finance.naver.com/');

    final response = await request.close();
    final bytes = await response.fold<List<int>>(
      <int>[],
      (buffer, chunk) => buffer..addAll(chunk),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Naver 요청에 실패했습니다. (${response.statusCode})',
        uri: uri,
      );
    }
    return bytes;
  }
}

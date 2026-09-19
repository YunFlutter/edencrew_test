import '../../core/error/app_exception.dart';
import '../dto/realtime_quote_dto.dart';
import '../dto/search_stock_dto.dart';
import '../dto/stock_metadata_dto.dart';
import 'json_field_reader.dart';

abstract final class NaverStockResponseParser {
  static List<SearchStockDto> parseSearch(Object? response) {
    final root = JsonFieldReader.map(response, r'$');
    final items = JsonFieldReader.list(root['items'], r'$.items');

    return List<SearchStockDto>.generate(items.length, (index) {
      final path = '\$.items[$index]';
      final item = JsonFieldReader.map(items[index], path);
      return SearchStockDto(
        symbol: JsonFieldReader.string(item, 'code', path),
        name: JsonFieldReader.string(item, 'name', path),
        market: JsonFieldReader.string(item, 'typeName', path),
        nationCode: JsonFieldReader.string(item, 'nationCode', path),
        category: JsonFieldReader.string(item, 'category', path),
      );
    }, growable: false);
  }

  static List<RealtimeQuoteDto> parseQuotes(Object? response) {
    final root = JsonFieldReader.map(response, r'$');
    final resultCode = JsonFieldReader.string(root, 'resultCode', r'$');
    if (resultCode != 'success') {
      throw ParsingException('실시간 시세 응답이 성공 상태가 아닙니다: $resultCode');
    }

    final result = JsonFieldReader.map(root['result'], r'$.result');
    final areas = JsonFieldReader.list(result['areas'], r'$.result.areas');
    Map<String, Object?>? serviceArea;
    for (var index = 0; index < areas.length; index++) {
      final path = '\$.result.areas[$index]';
      final area = JsonFieldReader.map(areas[index], path);
      if (area['name'] == 'SERVICE_ITEM') {
        serviceArea = area;
        break;
      }
    }
    if (serviceArea == null) {
      throw const ParsingException('실시간 시세 응답에 SERVICE_ITEM 영역이 없습니다.');
    }

    final datas = JsonFieldReader.list(
      serviceArea['datas'],
      r'$.result.areas[SERVICE_ITEM].datas',
    );
    return List<RealtimeQuoteDto>.generate(datas.length, (index) {
      final path = '\$.result.areas[SERVICE_ITEM].datas[$index]';
      final item = JsonFieldReader.map(datas[index], path);
      return RealtimeQuoteDto(
        symbol: JsonFieldReader.string(item, 'cd', path),
        currentPrice: JsonFieldReader.integer(item, 'nv', path),
        previousClose: JsonFieldReader.integer(item, 'pcv', path),
        openPrice: JsonFieldReader.integer(item, 'ov', path),
        highPrice: JsonFieldReader.integer(item, 'hv', path),
        lowPrice: JsonFieldReader.integer(item, 'lv', path),
        accumulatedTradingVolume: JsonFieldReader.integer(item, 'aq', path),
        countOfListedStock: JsonFieldReader.integer(
          item,
          'countOfListedStock',
          path,
        ),
      );
    }, growable: false);
  }

  static StockMetadataDto parseMetadata(Object? response) {
    final root = JsonFieldReader.map(response, r'$');
    return StockMetadataDto(
      symbol: JsonFieldReader.string(root, 'symbolCode', r'$'),
      name: JsonFieldReader.string(root, 'stockName', r'$'),
      market: JsonFieldReader.string(root, 'stockExchangeNameKor', r'$'),
    );
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/datasources/mock_naver_stock_remote_data_source.dart';
import '../data/datasources/naver_stock_remote_data_source_impl.dart';
import '../data/repositories/stock_repository_impl.dart';
import '../domain/repositories/stock_repository.dart';
import '../shared/favorites/favorite_store.dart';

/// 앱 전역 객체의 생성과 수명 주기를 한곳에서 관리합니다.
class AppDependencies {
  AppDependencies({
    required this.favoriteStore,
    required this.stockRepository,
    HttpClient? httpClient,
  }) : _httpClient = httpClient;

  factory AppDependencies.bootstrap() {
    const useMockData = bool.fromEnvironment(
      'USE_MOCK_DATA',
      defaultValue: kDebugMode,
    );
    if (useMockData) {
      return AppDependencies(
        favoriteStore: FavoriteStore(),
        stockRepository: StockRepositoryImpl(
          remoteDataSource: MockNaverStockRemoteDataSource(
            assetBundle: rootBundle,
          ),
        ),
      );
    }

    final httpClient = HttpClient();
    final remoteDataSource = NaverStockRemoteDataSourceImpl(
      httpClient: httpClient,
    );
    return AppDependencies(
      favoriteStore: FavoriteStore(),
      stockRepository: StockRepositoryImpl(remoteDataSource: remoteDataSource),
      httpClient: httpClient,
    );
  }

  final FavoriteStore favoriteStore;
  final StockRepository stockRepository;
  final HttpClient? _httpClient;

  void dispose() {
    favoriteStore.dispose();
    _httpClient?.close(force: true);
  }
}

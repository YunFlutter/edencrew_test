import 'package:flutter/material.dart';

import '../domain/models/stock.dart';
import '../features/search/view/search_screen.dart';
import '../features/stock_detail/view/stock_detail_screen.dart';
import '../features/watchlist/view/watchlist_screen.dart';
import 'app_dependencies.dart';

abstract final class AppRoutes {
  static const String watchlist = '/';
  static const String search = '/search';
  static const String stockDetail = '/stock-detail';

  static Route<void> onGenerateRoute(
    RouteSettings settings,
    AppDependencies dependencies,
  ) {
    final Widget page = switch (settings.name) {
      watchlist => WatchlistScreen(
        favoriteStore: dependencies.favoriteStore,
        stockRepository: dependencies.stockRepository,
      ),
      search => SearchScreen(
        favoriteStore: dependencies.favoriteStore,
        stockRepository: dependencies.stockRepository,
      ),
      stockDetail when settings.arguments is Stock => StockDetailScreen(
        stock: settings.arguments! as Stock,
        favoriteStore: dependencies.favoriteStore,
        stockRepository: dependencies.stockRepository,
      ),
      _ => WatchlistScreen(
        favoriteStore: dependencies.favoriteStore,
        stockRepository: dependencies.stockRepository,
      ),
    };

    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }
}

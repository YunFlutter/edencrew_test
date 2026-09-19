import 'package:flutter/material.dart';

import '../../../core/widgets/app_bottom_navigation.dart';
import '../../../shared/favorites/favorite_store.dart';
import '../../../theme/theme.dart';
import '../view_model/watchlist_view_model.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({required this.favoriteStore, super.key});

  final FavoriteStore favoriteStore;

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late final WatchlistViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = WatchlistViewModel(favoriteStore: widget.favoriteStore);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('관심')),
      bottomNavigationBar: const AppBottomNavigation(
        currentTab: AppTab.watchlist,
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final stocks = _viewModel.state.stocks;
          if (stocks.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(context.dimens.space6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.star_border_rounded,
                      color: context.colors.favoriteInactive,
                      size: context.dimens.iconMd,
                    ),
                    SizedBox(height: context.dimens.space3),
                    Text(
                      '관심 종목이 없습니다',
                      style: TextStyle(color: context.colors.textPrimary),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: stocks.length,
            itemBuilder: (BuildContext context, int index) {
              final stock = stocks[index];
              return ListTile(
                title: Text(stock.name),
                subtitle: Text('${stock.symbol} · ${stock.market}'),
              );
            },
          );
        },
      ),
    );
  }
}

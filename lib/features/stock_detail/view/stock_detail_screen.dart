import 'package:flutter/material.dart';

import '../../../domain/models/stock.dart';
import '../../../shared/favorites/favorite_store.dart';
import '../../../theme/theme.dart';
import '../view_model/stock_detail_view_model.dart';

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({
    required this.stock,
    required this.favoriteStore,
    super.key,
  });

  final Stock stock;
  final FavoriteStore favoriteStore;

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late final StockDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = StockDetailViewModel(
      stock: widget.stock,
      favoriteStore: widget.favoriteStore,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final state = _viewModel.state;
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(state.stock.name),
                Text(
                  '${state.stock.symbol} · ${state.stock.market}',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                onPressed: _viewModel.toggleFavorite,
                color: state.isFavorite
                    ? context.colors.favoriteActive
                    : context.colors.favoriteInactive,
                icon: Icon(
                  state.isFavorite
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                ),
              ),
            ],
          ),
          body: Center(
            child: Text(
              '상세 데이터 연동 예정',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
        );
      },
    );
  }
}

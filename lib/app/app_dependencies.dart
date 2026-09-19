import '../shared/favorites/favorite_store.dart';

/// 앱 전역 객체의 생성과 수명 주기를 한곳에서 관리합니다.
///
/// 네트워크 계층을 구현할 때 `StockRepository` 조립도 이곳에 추가합니다.
class AppDependencies {
  AppDependencies({required this.favoriteStore});

  factory AppDependencies.bootstrap() {
    return AppDependencies(favoriteStore: FavoriteStore());
  }

  final FavoriteStore favoriteStore;

  void dispose() {
    favoriteStore.dispose();
  }
}

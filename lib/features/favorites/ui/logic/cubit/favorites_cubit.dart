import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/favorites/data/model/favorites_model.dart';
import 'package:mushtary/features/favorites/data/repo/favorites_repo.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepo _repo;
  FavoritesCubit(this._repo) : super(FavoritesInitial());

  final Set<int> _favoriteIds = {}; // IDs للإعلان/المزاد

  Future<void> fetchFavorites() async {
    try {
      final ids = await _repo.getFavoriteIds();
      _favoriteIds
        ..clear()
        ..addAll(ids);
      if (isClosed) return;
      emit(FavoritesLoaded(Set.from(_favoriteIds)));
    } catch (_) {
      emit(FavoritesLoaded(Set.from(_favoriteIds)));
      if (isClosed) return;
    }
  }

  Future<void> toggleFavorite({required String type, required int id}) async {
    final wasFav = _favoriteIds.contains(id);

    // Optimistic
    if (wasFav) _favoriteIds.remove(id); else _favoriteIds.add(id);
    emit(FavoritesLoaded(Set.from(_favoriteIds)));

    try {
      if (wasFav) {
        await _repo.removeFavoriteByTypeAndId(type: type, id: id);
      } else {
        final ok = await _repo.addFavorite(type: type, id: id);
        if (!ok) throw Exception('not ok');
      }
    } catch (e) {
      // rollback
      if (wasFav) _favoriteIds.add(id); else _favoriteIds.remove(id);
      emit(FavoritesLoaded(Set.from(_favoriteIds)));
      emit(AddFavoriteFailure(e.toString()));
    }
  }

  Future<void> getFavoritesScreenItems() async {
    emit(FavoritesLoading());
    try {
      final auc = await _repo.getFavorites(type: 'auction');
      final ads = await _repo.getFavorites(type: 'ad');
      final all = [...auc, ...ads];

      // حدث IDs العامة (لتلوين القلوب في الهوم)
      _favoriteIds
        ..clear()
        ..addAll(all.map((e) => e.favoriteId));

      // Enrich لو details فاضي
      final enriched = <FavoriteItemModel>[];
      for (final f in all) {
        final d = f.details;
        final missingTitle = (d.title == null || d.title!.trim().isEmpty);
        final missingImages = (d.imageUrls == null || d.imageUrls!.isEmpty)
            && (d.thumbnail == null || d.thumbnail!.isEmpty);

        if (f.favoriteType == 'ad' && (missingTitle || missingImages)) {
          final det = await _repo.resolveAdDetailsById(f.favoriteId);
          if (det != null) {
            enriched.add(FavoriteItemModel(
              id: f.id,
              favoriteType: f.favoriteType,
              favoriteId: f.favoriteId,
              details: det,
            ));
            continue;
          }
        }
        enriched.add(f);
      }

      emit(FavoritesSuccess(enriched));
      // لا تبث FavoritesLoaded هنا حتى لا تختفي القائمة في شاشة المفضلة
      // القلوب في الهوم تتلوّن من fetchFavorites/ toggle فقط
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> removeFavorite({required int favoriteRecordId}) async {
    FavoriteItemModel? item;
    if (state is FavoritesSuccess) {
      final cur = (state as FavoritesSuccess).favoriteItems;
      item = cur.firstWhere((e) => e.id == favoriteRecordId, orElse: () => null as dynamic);
      if (item != null) {
        final updated = List<FavoriteItemModel>.from(cur)..remove(item);
        emit(FavoritesSuccess(updated));
      }
    }
    if (item == null) {
      await getFavoritesScreenItems();
      return;
    }

    try {
      await _repo.removeFavoriteByTypeAndId(type: item.favoriteType, id: item.favoriteId);
      _favoriteIds.remove(item.favoriteId);
      // لا تبث FavoritesLoaded هنا لتفادي إعادة بناء الشاشة الحالية
    } catch (e) {
      await getFavoritesScreenItems();
      emit(AddFavoriteFailure(e.toString()));
    }
  }
}
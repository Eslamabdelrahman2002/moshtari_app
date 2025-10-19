import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/favorites/data/repo/favorites_repo.dart';

import 'favorites_state.dart';


class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepo _favoritesRepo;
  FavoritesCubit(this._favoritesRepo) : super(FavoritesInitial());

  final Set<int> _favoriteIds = {};

  // For the Home Screen icons
  Future<void> fetchFavorites() async {
    // This is a simplified version. Ideally, you would fetch all favorite IDs
    // from an API endpoint when the app starts.
    emit(FavoritesLoaded(Set.from(_favoriteIds)));
  }

  // For adding/removing from the Home Screen
  Future<void> toggleFavorite({required String type, required int id}) async {
    final isCurrentlyFavorite = _favoriteIds.contains(id);

    if (isCurrentlyFavorite) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    emit(FavoritesLoaded(Set.from(_favoriteIds)));

    try {
      await _favoritesRepo.addFavorite(type: type, id: id);
    } catch (e) {
      // Revert the change on failure
      if (isCurrentlyFavorite) {
        _favoriteIds.add(id);
      } else {
        _favoriteIds.remove(id);
      }
      emit(FavoritesLoaded(Set.from(_favoriteIds)));
      emit(AddFavoriteFailure(e.toString()));
    }
  }

  // For the main Favorites Screen
  Future<void> getFavoritesScreenItems() async {
    emit(FavoritesLoading());
    try {
      final auctionFavorites = await _favoritesRepo.getFavorites(type: 'auction');
      final adFavorites = await _favoritesRepo.getFavorites(type: 'ad');
      final allFavorites = [...auctionFavorites, ...adFavorites];
      emit(FavoritesSuccess(allFavorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  // For removing from the Favorites Screen
  Future<void> removeFavorite({required int favoriteRecordId}) async {
    if (state is FavoritesSuccess) {
      final currentItems = (state as FavoritesSuccess).favoriteItems;
      final updatedItems = currentItems.where((item) => item.id != favoriteRecordId).toList();
      emit(FavoritesSuccess(updatedItems));
    }

    try {
      await _favoritesRepo.removeFavorite(favoriteRecordId: favoriteRecordId);
    } catch (e) {
      getFavoritesScreenItems(); // Refresh the list if deletion fails
    }
  }
}
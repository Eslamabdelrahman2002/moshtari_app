import 'package:flutter/material.dart';
import '../../../data/model/favorites_model.dart';

@immutable
abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

// For the main Favorites Screen
class FavoritesLoading extends FavoritesState {}

class FavoritesSuccess extends FavoritesState {
  final List<FavoriteItemModel> favoriteItems;
  FavoritesSuccess(this.favoriteItems);
}

class FavoritesError extends FavoritesState {
  final String error;
  FavoritesError(this.error);
}


// For the Home Screen favorite icons
class FavoritesLoaded extends FavoritesState {
  final Set<int> favoriteIds;
  FavoritesLoaded(this.favoriteIds);
}

class AddFavoriteLoading extends FavoritesState {
  final int itemId;
  AddFavoriteLoading(this.itemId);
}

class AddFavoriteSuccess extends FavoritesState {
  final String message;
  AddFavoriteSuccess(this.message);
}

class AddFavoriteFailure extends FavoritesState {
  final String error;
  AddFavoriteFailure(this.error);
}
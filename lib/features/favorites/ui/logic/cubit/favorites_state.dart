import 'package:equatable/equatable.dart';
import 'package:mushtary/features/favorites/data/model/favorites_model.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

// IDs فقط لتلوين القلوب في أي شاشة
class FavoritesLoaded extends FavoritesState {
  final Set<int> favoriteIds;
  const FavoritesLoaded(this.favoriteIds);
  @override
  List<Object?> get props => [favoriteIds];
}

class FavoritesSuccess extends FavoritesState {
  final List<FavoriteItemModel> favoriteItems;
  const FavoritesSuccess(this.favoriteItems);
  @override
  List<Object?> get props => [favoriteItems];
}

class FavoritesError extends FavoritesState {
  final String error;
  const FavoritesError(this.error);
  @override
  List<Object?> get props => [error];
}

// عند فشل الإضافة/الحذف
class AddFavoriteFailure extends FavoritesState {
  final String message;
  const AddFavoriteFailure(this.message);
  @override
  List<Object?> get props => [message];
}
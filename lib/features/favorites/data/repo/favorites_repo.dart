import 'package:mushtary/core/api/api_constants.dart';

import 'package:mushtary/core/api/app_exception.dart';

import '../../../../core/api/api_service.dart';
import '../model/favorites_model.dart';


class FavoritesRepo {
  final ApiService _apiService;
  FavoritesRepo(this._apiService);

  // Method to add a favorite (you already have this)
  Future<void> addFavorite({required String type, required int id}) async {
    // ... your existing code
  }

  // ✨ NEW: Method to get all favorites for a specific type
  Future<List<FavoriteItemModel>> getFavorites({required String type}) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.favorites}?favorite_type=$type&page=1',
      );
      final List<dynamic> favoriteList = response['data']['favorites'];
      return favoriteList.map((item) => FavoriteItemModel.fromJson(item)).toList();
    } catch (e) {
      throw AppException('Failed to load favorites: $e');
    }
  }

  // ✨ NEW: Method to delete a favorite by its unique record ID
  Future<void> removeFavorite({required int favoriteRecordId}) async {
    try {
      await _apiService.delete('${ApiConstants.favorites}/$favoriteRecordId');
    } catch (e) {
      throw AppException('Failed to remove favorite: $e');
    }
  }
}
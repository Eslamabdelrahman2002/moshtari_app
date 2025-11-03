import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../model/favorites_model.dart';

class FavoritesRepo {
  final ApiService _api;
  FavoritesRepo(this._api);

  Future<bool> addFavorite({required String type, required int id}) async {
    try {
      final map = await _api.post(ApiConstants.favorites,requireAuth: true, {
        'favorite_type': type,
        'favorite_id': id,
      });

      final dynamic status = map['status'];
      final ok = map['success'] == true || status == true || status == 'success';
      return ok;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('already') || msg.contains('exists') || msg.contains('موجود')) {
        return true;
      }
      throw AppException('Failed to add favorite: $e');
    }
  }

  Future<void> removeFavoriteByTypeAndId({required String type, required int id}) async {
    try {
      await _api.deleteWithBody(
        ApiConstants.favorites,
        requireAuth: true,
        data: {
          'favorite_type': type,
          'favorite_id': id,
        },
      );

    } catch (e) {
      throw AppException('Failed to remove favorite: $e');
    }
  }

  Future<List<FavoriteItemModel>> getFavorites({required String type}) async {
    try {
      final response = await _api.get('${ApiConstants.favorites}?favorite_type=$type&page=1');
      final list =
      (response is Map && response['data'] is Map && response['data']['favorites'] is List)
          ? response['data']['favorites'] as List
          : <dynamic>[];
      return list
          .map((item) => FavoriteItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      throw AppException('Failed to load favorites: $e');
    }
  }

  Future<Set<int>> getFavoriteIds() async {
    final adFavs = await getFavorites(type: 'ad');
    final aucFavs = await getFavorites(type: 'auction');
    final ids = <int>{};
    ids.addAll(adFavs.map((e) => e.favoriteId));
    ids.addAll(aucFavs.map((e) => e.favoriteId));
    return ids;
  }

  Future<FavoriteDetailsModel?> resolveAdDetailsById(int id) async {
    final candidates = <String>[
      'car-ads/$id',
      'real-estate-ads/$id',
      'other-ads/$id',
      'car-part-ads/$id',
      'car-ads?id=$id',
    ];

    for (final path in candidates) {
      try {
        final res = await _api.getResponse(path, relaxStatus: true);
        final sc = res.statusCode ?? 0;
        if (sc >= 200 && sc < 300) {
          final root = res.data;
          final data = (root is Map && root['data'] is Map)
              ? root['data'] as Map<String, dynamic>
              : (root is Map ? root : null);
          if (data == null) continue;

          List<String> images = [];
          if (data['image_urls'] is List) {
            images = List<String>.from((data['image_urls'] as List).map((e) => e.toString()));
          }
          final thumb = (data['thumbnail'] ?? data['image_url'] ?? (images.isNotEmpty ? images.first : null))?.toString();

          String? loc;
          if (data['city'] is Map && (data['city'] as Map)['name'] != null) {
            loc = (data['city'] as Map)['name']?.toString();
          } else if (data['region'] is Map && (data['region'] as Map)['name'] != null) {
            loc = (data['region'] as Map)['name']?.toString();
          } else if (data['name_ar'] != null) {
            loc = data['name_ar']?.toString();
          } else if (data['location'] != null) {
            loc = data['location']?.toString();
          }

          return FavoriteDetailsModel(
            title: data['title']?.toString(),
            description: data['description']?.toString(),
            price: data['price']?.toString(),
            thumbnail: thumb,
            imageUrls: images,
            createdAt: data['created_at']?.toString(),
            location: loc,
            username: (data['owner_name'] ?? data['username'])?.toString(),
            phoneNumber: (data['phone_number'] ?? data['phone'])?.toString(),
          );
        }
      } catch (_) {}
    }
    return null;
  }
}
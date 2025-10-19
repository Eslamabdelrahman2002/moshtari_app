// // --- موديل للـ Banner ---
// class BannerModel {
//   final String? image;
//
//   BannerModel({this.image});
// }
//
// // --- بيانات وهمية للـ Banners ---
// final List<BannerModel> mockBanners = [
//   BannerModel(image: "https://via.placeholder.com/800x400.png/FF6F61/FFFFFF?text=Banner+1"),
//   BannerModel(image: "https://via.placeholder.com/800x400.png/2196F3/FFFFFF?text=Banner+2"),
//   BannerModel(image: "https://via.placeholder.com/800x400.png/4CAF50/FFFFFF?text=Banner+3"),
// ];
// BANNER MODEL
class BannerModel {
  final int id;
  final String imageUrl;

  BannerModel({required this.id, required this.imageUrl});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      imageUrl: json['image_url'] ?? '',
    );
  }
}

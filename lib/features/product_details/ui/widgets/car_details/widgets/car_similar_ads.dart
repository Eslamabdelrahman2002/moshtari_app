// lib/features/car_details/ui/widgets/car_details/widgets/car_similar_ads.dart
import 'package:flutter/material.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import '../../../../data/model/car_details_model.dart';


class CarSimilarAds extends StatelessWidget {
  final List<SimilarCarAdModel> similarAds;
  const CarSimilarAds({super.key, required this.similarAds});

  @override
  Widget build(BuildContext context) {
    if (similarAds.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text("إعلانات مشابهة", style: TextStyle(fontSize: 18)),
        ),
        ...similarAds.map((s) => ListTile(
          leading: s.image != null && s.image!.isNotEmpty
              ? Image.network(s.image!, width: 50, height: 50, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const MySvg(image: 'image'))
              : const MySvg(image: 'image'),
          title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text("السنة: ${s.year ?? '-'} | السعر: ${s.price ?? 'N/A'}"),
        ))
      ],
    );
  }
}
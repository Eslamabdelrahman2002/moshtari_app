// features/home/ui/widgets/home_item_card.dart
import 'package:flutter/material.dart';
import '../../../../core/router/open_ad_details.dart';
import '../../data/models/unified_home_item.dart';

class HomeItemCard extends StatelessWidget {
  final UnifiedHomeItem item;
  const HomeItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // ignore: avoid_print
        print('[Home] tap id=${item.id}, source=${item.source}');
        openAdDetails(
          context,
          id: item.id,
          source: item.source,      // نعتمد على المصدر مباشرة
          // categoryId: item.categoryId, // اختياري كـ fallback
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              item.imageUrls.isNotEmpty ? item.imageUrls.first : '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black12),
            ),
          ),
          const SizedBox(height: 6),
          Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
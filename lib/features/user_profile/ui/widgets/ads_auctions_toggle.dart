import 'package:flutter/material.dart';
import 'package:mushtary/features/user_profile/ui/widgets/product_item.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/utils/helpers/spacing.dart';
import '../../../../core/widgets/primary/primary_button.dart';
import '../../data/model/my_ads_model.dart';
import '../../data/model/my_auctions_model.dart';

class AdsAuctionsToggle extends StatefulWidget {
  final List<MyAdsModel> myAds;
  final List<MyAuctionModel> myAuctions;

  const AdsAuctionsToggle({
    super.key,
    required this.myAds,
    required this.myAuctions,
  });

  @override
  State<AdsAuctionsToggle> createState() => _AdsAuctionsToggleState();
}

class _AdsAuctionsToggleState extends State<AdsAuctionsToggle> {
  bool showAds = true; // true => إعلاناتي, false => مزاداتي

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'إعلاناتي',
                    onPressed: () => setState(() => showAds = true),
                    backgroundColor: showAds ? ColorsManager.primaryColor : Colors.grey[300],
                    textColor: showAds ? Colors.white : Colors.black,
                  ),
                ),
                horizontalSpace(12),
                Expanded(
                  child: PrimaryButton(
                    text: 'مزاداتي',
                    onPressed: () => setState(() => showAds = false),
                    backgroundColor: !showAds ? ColorsManager.primaryColor : Colors.grey[300],
                    textColor: !showAds ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          verticalSpace(12),
          Expanded(
            child: showAds
                ? (widget.myAds.isEmpty
                ? const Center(child: Text('لا يوجد لديك إعلانات بعد.'))
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78, // عدّلها لو احتجت
              ),
              itemCount: widget.myAds.length,
              itemBuilder: (context, index) => ProductItem(model: widget.myAds[index]),
            ))
                : (widget.myAuctions.isEmpty
                ? const Center(child: Text('لا يوجد لديك مزادات بعد.'))
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: widget.myAuctions.length,
              itemBuilder: (context, index) => ProductItem(model: widget.myAuctions[index]),
            )),
          ),
        ],
      ),
    );
  }
}

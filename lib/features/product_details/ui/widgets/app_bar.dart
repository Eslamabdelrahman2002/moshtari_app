import 'package:flutter/material.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class ProductScreenAppBar extends StatelessWidget {
  const ProductScreenAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const MySvg(
        image: 'logo',
        isImage: false,
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
    );
  }
}

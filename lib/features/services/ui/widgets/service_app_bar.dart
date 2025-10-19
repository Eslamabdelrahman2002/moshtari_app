import 'package:flutter/material.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class ServiceAppBar extends StatelessWidget {
  const ServiceAppBar({
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

bool isValidHttpUrl(String? url) {
  if (url == null || url.trim().isEmpty) return false;
  final uri = Uri.tryParse(url.trim());
  return uri != null && uri.hasScheme && uri.host.isNotEmpty;
}

class SafeNetworkImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (!isValidHttpUrl(url)) {
      return errorWidget ??
          Container(
            color: const Color(0xffECECEC),
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
          );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      placeholder: (_, __) => placeholder ?? Container(color: const Color(0xffECECEC)),
      errorWidget: (_, __, ___) => errorWidget ??
          Container(
            color: const Color(0xffECECEC),
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
    );
  }
}

class SafeCircleAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  final Color bg;

  const SafeCircleAvatar({
    super.key,
    required this.url,
    this.radius = 18,
    this.bg = const Color(0xffEEEEEE),
  });

  @override
  Widget build(BuildContext context) {
    final valid = isValidHttpUrl(url);
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      backgroundImage: valid ? CachedNetworkImageProvider(url!) : null,
      child: valid
          ? null
          : const Icon(Icons.person_outline, color: Colors.grey, size: 18),
    );
  }
}
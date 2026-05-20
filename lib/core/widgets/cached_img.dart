import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedImg extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const CachedImg({
    required this.url,
    this.fit = BoxFit.cover,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const Icon(Icons.broken_image, color: Colors.grey);
    }
    
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (_, __) => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (_, __, ___) => const Icon(Icons.error, color: Colors.redAccent),
      fadeInDuration: const Duration(milliseconds: 300),
      memCacheHeight: 600,
      memCacheWidth: 600,
    );
  }
}

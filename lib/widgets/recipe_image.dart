import 'package:flutter/material.dart';

/// Gambar resep dengan placeholder saat memuat / URL kosong / gagal dimuat.
class RecipeImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  const RecipeImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
  });

  Widget _placeholder({Widget? child}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: child ?? const Icon(Icons.restaurant, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url.isEmpty
          ? _placeholder()
          : Image.network(
              url,
              width: width,
              height: height,
              fit: fit,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _placeholder(
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => _placeholder(
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/ui/widget/pill_badge.dart';

/// GradientImageCard — pola "Product Card" dari DESIGN.md: full-bleed image,
/// 20px radius, gradient bottom-up hitam untuk keterbacaan teks overlay.
///
/// Ini widget yang paling banyak dipakai ulang di 9 screen restyle — Home
/// ("Recommended for You", "Trending"), Search (hasil pencarian), Saved
/// Destinations (grid wishlist), dan Destination Details (header hero).
class GradientImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final double price;
  final double? rating;
  final String? overlayBadgeLabel; // mis. "Most Popular", "New"
  final bool isWishlisted;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistToggle;
  final double height;
  final double? width;

  const GradientImageCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    this.rating,
    this.overlayBadgeLabel,
    this.isWishlisted = false,
    this.onTap,
    this.onWishlistToggle,
    this.height = 192,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  child: Container(
                    height: height,
                    width: double.infinity,
                    foregroundDecoration: const BoxDecoration(
                      gradient: AppTheme.imageOverlayGradient,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: height,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppTheme.surfaceContainerHigh),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.surfaceContainerHigh,
                        child: const Icon(Icons.image_not_supported_outlined,
                            color: AppTheme.outline),
                      ),
                    ),
                  ),
                ),
                if (overlayBadgeLabel != null)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: PillBadge.overlay(overlayBadgeLabel!.toUpperCase()),
                  ),
                if (rating != null)
                  Positioned(
                    bottom: 12,
                    right: onWishlistToggle != null ? 48 : 12,
                    child: PillBadge.rating(rating!),
                  ),
                if (onWishlistToggle != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onWishlistToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 18,
                          color: isWishlisted ? AppTheme.loveColor : AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(location,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '\$${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: AppTheme.secondary, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  TextSpan(
                    text: ' / night',
                    style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

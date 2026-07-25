import 'package:flutter/material.dart';
import 'package:sasacation/core/apptheme.dart';

/// PillBadge — badge bentuk pil, dipakai untuk rating, "Most Popular", tag
/// kategori, dsb. Sesuai DESIGN.md bagian "Badges": "Rating and price badges
/// are pill-shaped for high distinctiveness against rectangular card imagery."
///
/// Dipakai di HAMPIR SEMUA 9 screen restyle — dibuat sekali di sini supaya
/// konsisten, bukan didefinisikan ulang per screen.
class PillBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool glass; // true = semi-transparan + blur-like (dipakai di atas gambar)

  const PillBadge({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = Colors.white,
    this.foregroundColor = AppTheme.onSurface,
    this.glass = false,
  });

  /// Preset: badge rating bintang (dipakai di card destinasi/hotel)
  factory PillBadge.rating(double rating, {bool glass = true}) => PillBadge(
        label: rating.toStringAsFixed(1),
        icon: Icons.star_rounded,
        backgroundColor: glass ? Colors.white.withOpacity(0.9) : Colors.white,
        foregroundColor: AppTheme.primary,
        glass: glass,
      );

  /// Preset: badge label di atas gambar (mis. "Most Popular", "New Arrivals")
  factory PillBadge.overlay(String label) => PillBadge(
        label: label,
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        glass: true,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: label.length > 10 ? 10 : 12,
              fontWeight: FontWeight.w700,
              color: foregroundColor,
              letterSpacing: label == label.toUpperCase() ? 0.5 : 0,
            ),
          ),
        ],
      ),
    );
  }
}

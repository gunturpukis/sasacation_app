import 'package:flutter/material.dart';
import 'package:sasacation/core/apptheme.dart';

/// HeroBanner
/// FIX 1: gambar background dulu pakai DecorationImage(NetworkImage(...)) yang
/// tidak punya fallback — sekali URL Unsplash 404, seluruh frame melempar
/// NetworkImageLoadException berulang kali. Sekarang pakai Image.network
/// dengan errorBuilder + loadingBuilder supaya gagal secara elegan (gradient
/// warna brand), bukan crash berulang di console.
/// FIX 2: tombol "Explore Deals" (oranye) dihapus dari sini karena sekarang
/// bertabrakan secara visual dengan search card mengambang baru di Home —
/// CTA pencarian di search card sudah menggantikan perannya.
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  static const _imageUrl =
      'https://images.unsplash.com/photo-1512100356356-de1b84283e18?w=800&q=80';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image dengan fallback gradient bila gagal dimuat.
          Image.network(
            _imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _fallbackGradient();
            },
            errorBuilder: (context, error, stackTrace) => _fallbackGradient(),
          ),
          // Overlay gradient supaya teks putih tetap kebaca di atas foto apapun.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromRGBO(0, 0, 0, 0.15),
                  const Color.fromRGBO(0, 0, 0, 0.65),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 56),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Limited Offer',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Discover Paradise\nin Lombok',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      '4.9',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '(2,500+ reviews)',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackGradient() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withAlpha((0.7 * 255).round()),
          ],
        ),
      ),
    );
  }
}

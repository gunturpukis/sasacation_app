import 'package:flutter/material.dart';
import 'package:sasacation/core/apptheme.dart';

/// Gallery bento grid — mengikuti mockup: 1 gambar besar (2x2) di kiri,
/// 1 gambar lebar di kanan-atas, 2 gambar kecil kanan-bawah (yang terakhir
/// diberi overlay "+N" kalau ada gambar lebih banyak dari yang ditampilkan).
///
/// Dipakai bersama oleh `detail_hotels_page.dart` dan
/// `destination_detail_screen.dart` (sebelumnya duplikat di keduanya).
class GalleryBento extends StatelessWidget {
  final List<String> images;
  const GalleryBento({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final extra = images.length - 4;
    return SizedBox(
      height: 256,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              child: Image.network(images[0],
                  fit: BoxFit.cover,
                  height: double.infinity,
                  errorBuilder: (_, _, _) =>
                      Container(color: AppTheme.surfaceContainerHigh)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    child: Image.network(images[1],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, _, _) =>
                            Container(color: AppTheme.surfaceContainerHigh)),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                          child: images.length > 2
                              ? Image.network(images[2],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                      color: AppTheme.surfaceContainerHigh))
                              : Container(
                                  color: AppTheme.surfaceContainerHigh),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                          child: images.length > 3
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(images[3],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                            color: AppTheme
                                                .surfaceContainerHigh)),
                                    if (extra > 0)
                                      Container(
                                        color: Colors.black
                                            .withValues(alpha: 0.4),
                                        child: Center(
                                          child: Text('+$extra',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                        ),
                                      ),
                                  ],
                                )
                              : Container(
                                  color: AppTheme.surfaceContainerHighest),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

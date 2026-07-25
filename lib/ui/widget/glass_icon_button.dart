import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sasacation/core/apptheme.dart';

/// GlassIconButton — "Glass AppBars: Circular icon buttons (36x36px) with
/// 12px radius, utilizing backdrop blur when placed over photography."
/// (DESIGN.md, bagian Navigation)
///
/// Dipakai di header yang menimpa foto: Destination Details, Search hero,
/// dan AppBar transparan lain di 9 screen restyle.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color iconColor;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withOpacity(0.25),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(icon, size: 20, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}

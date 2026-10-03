
import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/data/repo/hotel_repository.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/ui/widget/pill_badge.dart';
import 'package:sasacation/utils/money.dart';
import 'package:sasacation/viewmodel/wishlist/wishlist_cubit.dart';
 
/// WishlistScreen — restyle mengikuti mockup `saved_destinations`.
///
/// PERUBAHAN: card sebelumnya ListTile (thumbnail 64x64 + teks di kanan).
/// Sekarang full-width image card dengan gradient overlay, judul di atas
/// foto, dan tombol "Book Now" eksplisit — sesuai mockup yang menekankan
/// tiap saved destination sebagai "siap dipesan", bukan cuma daftar biasa.
///
/// Badge mengikuti mockup ("Best Seller"/"Special Offer"/"Trending") lewat
/// heuristik deterministik dari field nyata HotelModel — tanpa mengarang:
/// rating >= 4.8 → BEST SELLER; featured → SPECIAL OFFER; review >= 100 →
/// TRENDING. Hotel yang tidak memenuhi ketiganya tampil tanpa badge.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
 
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}
 
class _WishlistScreenState extends State<WishlistScreen> {
  final _repo = HotelRepository();
  List<HotelModel> _hotels = [];
  bool _loading = true;
 
  @override
  void initState() {
    super.initState();
    _loadHotels();
  }
 
  Future<void> _loadHotels() async {
    final ids = context.read<WishlistCubit>().state;
    setState(() => _loading = true);
    final results = await Future.wait(ids.map((id) => _repo.getHotelById(id)));
    setState(() {
      _hotels = results.whereType<HotelModel>().toList();
      _loading = false;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<WishlistCubit, Set<String>>(
      listener: (context, _) => _loadHotels(),
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.fun_savedTitle, style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 4),
                            Text(l10n.fun_savedSubtitle,
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    if (_hotels.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_border, size: 72, color: AppTheme.outlineVariant),
                              const SizedBox(height: 16),
                              Text(l10n.fun_emptyWishlistTitle, style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 6),
                              Text(l10n.fun_emptyWishlistHint,
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final hotel = _hotels[index];
                              return _SavedDestinationCard(
                                hotel: hotel,
                                onUnsave: () => context.read<WishlistCubit>().toggle(hotel.id),
                                onTap: () =>
                                    context.push(AppRouter.hotelDetailPath(hotel.id)),
                              );
                            },
                            childCount: _hotels.length,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
 
/// Heuristik badge dari data nyata (lihat catatan di atas file).
String? _badgeLabel(HotelModel hotel, BuildContext context) {
  final l10n = AppLocalizations.of(context);
  if (hotel.rating >= 4.8) return l10n.fun_badgeBestSeller;
  if (hotel.featured) return l10n.fun_badgeSpecialOffer;
  if (hotel.reviewCount >= 100) return l10n.fun_badgeTrending;
  return null;
}

/// Warna badge mengikuti mockup: teal untuk Best Seller/Trending,
/// oranye untuk Special Offer.
Color _badgeColor(BuildContext context, String? badgeLabel) {
  final l10n = AppLocalizations.of(context);
  if (badgeLabel == l10n.fun_badgeSpecialOffer) {
    return AppTheme.secondaryContainer;
  }
  return AppTheme.primaryContainer;
}

class _SavedDestinationCard extends StatelessWidget {
  final HotelModel hotel;
  final VoidCallback onUnsave;
  final VoidCallback onTap;

  const _SavedDestinationCard({required this.hotel, required this.onUnsave, required this.onTap});
 
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final badge = _badgeLabel(hotel, context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          boxShadow: AppTheme.softCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusCard)),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    foregroundDecoration: const BoxDecoration(gradient: AppTheme.imageOverlayGradient),
                    child: Image.network(
                      hotel.image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.surfaceContainerHigh,
                        child: const Icon(Icons.image_not_supported_outlined, color: AppTheme.outline),
                      ),
                    ),
                  ),
                ),
                if (badge != null)
                  Positioned(
                    bottom: 44,
                    left: 14,
                    child: PillBadge(
                      label: badge,
                      backgroundColor: _badgeColor(context, badge),
                      foregroundColor: Colors.white,
                    ),
                  ),
                Positioned(
                  left: 14,
                  bottom: 12,
                  right: 12,
                  child: Text(hotel.name,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onUnsave,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded, size: 18, color: AppTheme.loveColor),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppTheme.radiusCard)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.onSurfaceVariant),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(hotel.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        MoneyText(
                          hotel.price,
                          style: const TextStyle(
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                          suffix: l10n.common_perNight,
                          suffixStyle: const TextStyle(
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w400,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryContainer,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                    ),
                    child: Text(l10n.common_bookNow, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
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
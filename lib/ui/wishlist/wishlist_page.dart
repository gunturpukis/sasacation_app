
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/data/repo/hotel_repository.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/ui/widget/pill_badge.dart';
import 'package:sasacation/viewmodel/wishlist/wishlist_cubit.dart';
 
/// WishlistScreen — restyle mengikuti mockup `saved_destinations`.
///
/// PERUBAHAN: card sebelumnya ListTile (thumbnail 64x64 + teks di kanan).
/// Sekarang full-width image card dengan gradient overlay, judul di atas
/// foto, dan tombol "Book Now" eksplisit — sesuai mockup yang menekankan
/// tiap saved destination sebagai "siap dipesan", bukan cuma daftar biasa.
///
/// CATATAN: mockup punya badge "Best Seller"/"Special Offer"/"Trending" per
/// card — HotelModel tidak punya field kategori badge seperti itu, jadi
/// saya TIDAK mengarang label acak. Badge cuma muncul untuk hotel dengan
/// `featured: true` (data asli dari backend), diberi label generik
/// "Featured" — bukan 3 variasi label seperti mockup.
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
                            Text('Saved Destinations', style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 4),
                            Text('Discover your dream vacations waiting for you.',
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
                              Text('Belum ada hotel tersimpan', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 6),
                              Text('Ketuk ikon hati pada hotel untuk menyimpannya',
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
                                    context.push(AppRouter.hotelDetail.replaceFirst(':id', hotel.id)),
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
 
class _SavedDestinationCard extends StatelessWidget {
  final HotelModel hotel;
  final VoidCallback onUnsave;
  final VoidCallback onTap;
 
  const _SavedDestinationCard({required this.hotel, required this.onUnsave, required this.onTap});
 
  @override
  Widget build(BuildContext context) {
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
                if (hotel.featured)
                  Positioned(bottom: 44, left: 14, child: PillBadge.overlay('FEATURED')),
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
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: '\$${hotel.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: AppTheme.secondary, fontWeight: FontWeight.w700, fontSize: 15)),
                              TextSpan(
                                  text: ' / night',
                                  style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                            ],
                          ),
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
                    child: const Text('Book Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
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
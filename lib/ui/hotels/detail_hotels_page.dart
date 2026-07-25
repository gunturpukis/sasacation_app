import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/ui/widget/booking_sheets.dart';
import 'package:sasacation/ui/widget/glass_icon_button.dart';
import 'package:sasacation/ui/widget/pill_badge.dart';
import 'package:sasacation/viewmodel/hotel/hotel_bloc.dart';
import 'package:sasacation/viewmodel/wishlist/wishlist_cubit.dart';
 
/// HotelDetailScreen — restyle mengikuti mockup `destination_details`.
///
/// PERUBAHAN STRUKTUR:
/// - Tombol back/wishlist di AppBar sekarang GlassIconButton (blur di atas
///   foto) menggantikan Container putih solid.
/// - Section baru: "Experience indicators" (chip horizontal, ambil dari 2
///   amenity teratas), "Gallery" (bento grid dari hotel.images, HANYA
///   tampil kalau hotel.images.length >= 3 — lihat catatan di bawah).
/// - Bottom booking bar diselaraskan ke style mockup (radius, warna).
///
/// CATATAN JUJUR — bagian mockup yang SENGAJA tidak diimplementasi:
/// - "Guest Reviews" (avatar reviewer + kutipan) di mockup itu data per-
///   review (nama, tanggal, teks ulasan). HotelModel cuma punya
///   `reviewCount` (angka), tidak ada data ulasan individual. Menambahkan
///   section ini berarti mengarang data — saya skip, bukan bug.
/// - Peta lokasi (yang sudah ada sebelumnya, placeholder "Peta lokasi
///   hotel") saya PERTAHANKAN apa adanya — mockup tidak eksplisit
///   menunjukkan peta, dan mengimplementasikan peta sungguhan (Google Maps
///   SDK) di luar scope restyle visual.
class HotelDetailScreen extends StatefulWidget {
  final String hotelId;
  const HotelDetailScreen({super.key, required this.hotelId});
 
  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}
 
class _HotelDetailScreenState extends State<HotelDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HotelBloc>().add(HotelDetailRequested(hotelId: widget.hotelId));
  }
 
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelBloc, HotelState>(
      builder: (context, state) {
        if (state is HotelCompositeState) {
          if (state.isLoadingDetail) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (state.detailError != null && state.detailHotel == null) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                    const SizedBox(height: 16),
                    Text(state.detailError!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<HotelBloc>()
                          .add(HotelDetailRequested(hotelId: widget.hotelId)),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          final hotel = state.detailHotel;
          if (hotel == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
 
          return Scaffold(
            backgroundColor: AppTheme.surface,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 340,
                  pinned: true,
                  backgroundColor: AppTheme.surface,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(hotel.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: AppTheme.surfaceContainerHigh)),
                        Container(decoration: const BoxDecoration(gradient: AppTheme.imageOverlayGradient)),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (hotel.featured) ...[
                                    const PillBadge(
                                      label: 'PREMIUM ESCAPE',
                                      backgroundColor: AppTheme.primaryContainer,
                                      foregroundColor: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Icon(Icons.star_rounded, size: 16, color: AppTheme.ratingColor),
                                  const SizedBox(width: 2),
                                  Text('${hotel.rating.toStringAsFixed(1)} (${hotel.reviewCount} reviews)',
                                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(hotel.name,
                                  style: const TextStyle(
                                      fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.white70),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(hotel.address ?? hotel.location,
                                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: GlassIconButton(
                      icon: Icons.arrow_back,
                      iconColor: AppTheme.onSurface,
                      onTap: () => context.pop(),
                    ),
                  ),
                  actions: [
                    BlocBuilder<WishlistCubit, Set<String>>(
                      builder: (context, wishlist) {
                        final saved = wishlist.contains(hotel.id);
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GlassIconButton(
                            icon: saved ? Icons.favorite : Icons.favorite_border,
                            iconColor: saved ? AppTheme.loveColor : AppTheme.onSurface,
                            onTap: () => context.read<WishlistCubit>().toggle(hotel.id),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMarginMobile),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Experience indicator chips ────────────────────
                        if (hotel.amenities.isNotEmpty)
                          SizedBox(
                            height: 64,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: hotel.amenities.take(3).map((a) => Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: AppTheme.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                            ),
                                            child: Icon(_amenityIcon(a), size: 18, color: AppTheme.primary),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(a, style: Theme.of(context).textTheme.bodyMedium),
                                        ],
                                      ),
                                    ),
                                  )).toList(),
                            ),
                          ),
                        const SizedBox(height: AppTheme.spacingSectionGap),
 
                        // ─── About ──────────────────────────────────────────
                        Text('About the Experience', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 10),
                        Text(
                          hotel.description ??
                              'Nikmati pengalaman menginap yang tak terlupakan di ${hotel.name}. '
                              'Dengan fasilitas lengkap dan layanan prima, hotel ini menawarkan kenyamanan terbaik.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppTheme.spacingSectionGap),
 
                        // ─── What's Included ────────────────────────────────
                        Text("What's Included", style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: (hotel.amenities.isNotEmpty
                                  ? hotel.amenities
                                  : const ['Free WiFi', 'Pool', 'Restaurant'])
                              .map((a) => AmenityChip(icon: _amenityIcon(a), label: a))
                              .toList(),
                        ),
                        const SizedBox(height: AppTheme.spacingSectionGap),
 
                        // ─── Gallery bento — hanya kalau gambar cukup ──────
                        if (hotel.images.length >= 3) ...[
                          Text('The Property', style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 12),
                          _GalleryBento(images: hotel.images),
                          const SizedBox(height: AppTheme.spacingSectionGap),
                        ],
 
                        // Peta lokasi — dipertahankan apa adanya (placeholder),
                        // lihat catatan di atas class.
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map_outlined, size: 40, color: AppTheme.outline),
                                const SizedBox(height: 10),
                                Text('Peta lokasi hotel',
                                    style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.95),
                boxShadow: AppTheme.floatingShadow,
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price per night', style: Theme.of(context).textTheme.labelSmall),
                          const SizedBox(height: 2),
                          Text('\$${hotel.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSheet)),
                            ),
                            builder: (_) => BookingSheet(hotel: hotel),
                          );
                        },
                        style: AppTheme.heroButtonStyle,
                        child: const Text('Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
 
  IconData _amenityIcon(String amenity) {
    final a = amenity.toLowerCase();
    if (a.contains('wifi')) return Icons.wifi;
    if (a.contains('pool')) return Icons.pool;
    if (a.contains('spa')) return Icons.spa;
    if (a.contains('restaurant') || a.contains('dining')) return Icons.restaurant;
    if (a.contains('gym') || a.contains('fitness')) return Icons.fitness_center;
    if (a.contains('parking')) return Icons.local_parking;
    if (a.contains('beach')) return Icons.beach_access;
    if (a.contains('bar')) return Icons.local_bar;
    if (a.contains('airport') || a.contains('transfer')) return Icons.airport_shuttle;
    if (a.contains('butler')) return Icons.room_service;
    return Icons.check_circle_outline;
  }
}
 
/// Gallery bento grid — mengikuti mockup: 1 gambar besar (2x2) di kiri,
/// 1 gambar lebar di kanan-atas, 2 gambar kecil kanan-bawah (yang terakhir
/// diberi overlay "+N" kalau ada gambar lebih banyak dari yang ditampilkan).
class _GalleryBento extends StatelessWidget {
  final List<String> images;
  const _GalleryBento({required this.images});
 
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
              child: Image.network(images[0], fit: BoxFit.cover, height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceContainerHigh)),
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
                    child: Image.network(images[1], fit: BoxFit.cover, width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceContainerHigh)),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          child: images.length > 2
                              ? Image.network(images[2], fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceContainerHigh))
                              : Container(color: AppTheme.surfaceContainerHigh),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          child: images.length > 3
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(images[3], fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceContainerHigh)),
                                    if (extra > 0)
                                      Container(
                                        color: Colors.black.withOpacity(0.4),
                                        child: Center(
                                          child: Text('+$extra',
                                              style: const TextStyle(
                                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                        ),
                                      ),
                                  ],
                                )
                              : Container(color: AppTheme.surfaceContainerHighest),
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
 
class AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const AmenityChip({super.key, required this.icon, required this.label});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.4)),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/data/repo/weather_repository.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/ui/widget/booking_sheets.dart';
import 'package:sasacation/ui/widget/glass_icon_button.dart';
import 'package:sasacation/ui/widget/pill_badge.dart';
import 'package:sasacation/utils/money.dart';
import 'package:sasacation/viewmodel/hotel/hotel_bloc.dart';
import 'package:sasacation/viewmodel/wishlist/wishlist_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
 
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
    final l10n = AppLocalizations.of(context);
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
                      child: Text(l10n.common_retry),
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
                                    PillBadge(
                                      label: l10n.fun_badgePremium,
                                      backgroundColor: AppTheme.primaryContainer,
                                      foregroundColor: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Icon(Icons.star_rounded, size: 16, color: AppTheme.ratingColor),
                                  const SizedBox(width: 2),
                                  Text(l10n.fun_ratingReviews(hotel.rating.toStringAsFixed(1), hotel.reviewCount),
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
                        Text(l10n.fun_aboutExperience, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 10),
                        Text(
                          hotel.description ??
                              l10n.fun_aboutFallback(hotel.name),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppTheme.spacingSectionGap),
 
                        // ─── What's Included ────────────────────────────────
                        Text(l10n.fun_whatsIncluded, style: Theme.of(context).textTheme.headlineMedium),
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
                          Text(l10n.fun_propertyTitle, style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 12),
                          _GalleryBento(images: hotel.images),
                          const SizedBox(height: AppTheme.spacingSectionGap),
                        ],

                        // ─── Destination Alert (F13) — hanya bila hotel
                        // punya koordinat DAN backend mengembalikan alert.
                        // Tanpa keduanya section disembunyikan total.
                        if (hotel.latitude != null &&
                            hotel.longitude != null)
                          _WeatherAlertCard(
                            latitude: hotel.latitude!,
                            longitude: hotel.longitude!,
                          ),

                        // ─── Guest Reviews — mengikuti mockup. Hanya tampil
                        // bila backend mengirim ulasan individual (lihat
                        // kontrak di HotelReview); kalau kosong, section
                        // disembunyikan alih-alih mengarang kutipan.
                        if (hotel.reviews.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.fun_guestReviews,
                                  style: Theme.of(context).textTheme.headlineMedium),
                              TextButton(
                                onPressed: () =>
                                    _showAllReviews(context, hotel.reviews),
                                child: Text(l10n.common_seeAll,
                                    style: const TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _ReviewCard(review: hotel.reviews.first),
                          const SizedBox(height: AppTheme.spacingSectionGap),
                        ],
 
                        // Peta lokasi — placeholder visual yang bisa diketuk
                        // untuk membuka Google Maps (tanpa Maps SDK).
                        InkWell(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          onTap: () async {
                            final query = Uri.encodeComponent(
                                '${hotel.name} ${hotel.location}');
                            final url = Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=$query');
                            final opened = await launchUrl(
                                url, mode: LaunchMode.externalApplication);
                            if (!opened && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(l10n.fun_cannotOpenMaps)),
                              );
                            }
                          },
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLow,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusLg),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.map_outlined,
                                      size: 40, color: AppTheme.outline),
                                  const SizedBox(height: 10),
                                  Text(l10n.fun_hotelMapHint,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                ],
                              ),
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
                          Text(l10n.fun_pricePerNightTitle, style: Theme.of(context).textTheme.labelSmall),
                          const SizedBox(height: 2),
                          MoneyText(hotel.price,
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
                        child: Text(l10n.common_bookNow, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

/// Kartu ulasan tamu mengikuti mockup: avatar, nama, info menginap,
/// bintang, dan kutipan.
class _ReviewCard extends StatelessWidget {
  final HotelReview review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                backgroundImage: review.avatar != null
                    ? NetworkImage(review.avatar!)
                    : null,
                child: review.avatar == null
                    ? Text(
                        review.userName.isNotEmpty
                            ? review.userName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    if (review.stayed != null)
                      Text(l10n.fun_stayedWith(review.stayed!),
                          style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final filled = i < review.rating.round().clamp(0, 5);
                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 15,
                    color: AppTheme.ratingColor,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('"${review.text}"',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

/// "See all" membuka bottom sheet berisi semua ulasan dari data yang sama —
/// tanpa route baru karena datanya sudah ada di memori.
void _showAllReviews(BuildContext context, List<HotelReview> reviews) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusSheet)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
                    Text(AppLocalizations.of(sheetContext).fun_guestReviewsCount(reviews.length),
                style: Theme.of(sheetContext).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: controller,
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _ReviewCard(review: reviews[i]),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
/// F13: kartu "Destination Alert" — tampil HANYA bila backend mengembalikan
/// `alert` untuk koordinat hotel. Tombol mengarah ke My Bookings (di sana
/// tombol Reschedule per booking confirmed berada) — deep-link jujur,
/// bukan reschedule tanpa konteks booking.
class _WeatherAlertCard extends StatefulWidget {
  final double latitude;
  final double longitude;
  const _WeatherAlertCard(
      {required this.latitude, required this.longitude});

  @override
  State<_WeatherAlertCard> createState() => _WeatherAlertCardState();
}

class _WeatherAlertCardState extends State<_WeatherAlertCard> {
  WeatherInfo? _info;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await WeatherRepository().getWeather(
      lat: widget.latitude,
      lng: widget.longitude,
    );
    if (!mounted) return;
    setState(() {
      _info = info;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    final alert = _info?.alert;
    // Tanpa alert (cuaca normal) atau gagal muat: sembunyikan total.
    if (alert == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSectionGap),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (alert.isHigh ? AppTheme.error : AppTheme.secondaryContainer)
            .withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: (alert.isHigh
                  ? AppTheme.error
                  : AppTheme.secondaryContainer)
              .withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                alert.kind == 'thunderstorm'
                    ? Icons.thunderstorm_outlined
                    : Icons.water_drop_outlined,
                color: alert.isHigh
                    ? AppTheme.error
                    : AppTheme.secondary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.fun_weatherAlertTitle,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppTheme.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(alert.title,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            '${_info?.description ?? ''}${alert.window.isNotEmpty ? ' • ${alert.window}' : ''}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push(AppRouter.myBookings),
              style: AppTheme.heroButtonStyle,
              child: Text(l10n.fun_rescheduleAction),
            ),
          ),
        ],
      ),
    );
  }
}

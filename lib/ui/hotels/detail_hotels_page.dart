import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/api/api_client.dart';
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

                        // ─── F.2 AI Review Summary — kartu ringkasan pros/cons.
                        // Fail-soft: sembunyi bila 404/kosong (no-fake-data).
                        _ReviewSummaryCard(hotelId: hotel.id),

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
                                    _showAllReviews(context, hotel.id, hotel.reviews),
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

/// F.2: kartu "AI Review Summary" — pros/cons + baris personal.
/// Fail-soft: kosong/404 → SizedBox.shrink (no-fake-data).
class _ReviewSummaryCard extends StatelessWidget {
  final String hotelId;
  const _ReviewSummaryCard({required this.hotelId});

  Future<Map<String, dynamic>?> _fetch() async {
    try {
      final res = await ApiClient.get('/hotels/$hotelId/review-summary');
      final data = res.data['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetch(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingSectionGap),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: const Row(children: [
              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 10),
              Text('✨ AI meringkas ulasan...', style: TextStyle(fontSize: 12)),
            ]),
          );
        }
        final d = snap.data;
        if (d == null || (d['count'] ?? 0) == 0) return const SizedBox.shrink();
        final pros = List<String>.from(d['pros'] ?? []);
        final cons = List<String>.from(d['cons'] ?? []);
        final isSeeded = d['isSeeded'] == true;
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingSectionGap),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.auto_awesome, size: 15, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '⭐ ${d['avgRating'] ?? '-'} · ${d['count']} ulasan — ringkasan AI',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryColor),
                ),
              ),
              // F.2: BE menandai ringkasan dari seed dummy (isSeeded) —
              // tampilkan badge "contoh" sesuai kontrak, bukan diam-diam.
              if (isSeeded)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'en'
                        ? 'sample'
                        : 'contoh',
                    style: const TextStyle(fontSize: 10, color: Colors.orange),
                  ),
                ),
            ]),
            if ((d['summaryText'] as String?)?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(d['summaryText'] as String, style: const TextStyle(fontSize: 12)),
            ],
            if (pros.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Paling disukai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              ...pros.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(children: [
                      const Icon(Icons.check_circle, size: 13, color: Colors.green),
                      const SizedBox(width: 6),
                      Expanded(child: Text(p, style: const TextStyle(fontSize: 12))),
                    ]),
                  )),
            ],
            if (cons.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Text('Sering dikeluhkan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              ...cons.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(children: [
                      const Icon(Icons.info_outline, size: 13, color: Colors.orange),
                      const SizedBox(width: 6),
                      Expanded(child: Text(c, style: const TextStyle(fontSize: 12))),
                    ]),
                  )),
            ],
            if ((d['personalizedLine'] as String?)?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(d['personalizedLine'] as String,
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.primaryColor)),
            ],
          ]),
        );
      },
    );
  }
}

/// "See all" membuka bottom sheet berisi semua ulasan — paginasi dari
/// GET /hotels/:id/reviews (bukan cuma 50 inline dari detail), dengan fallback
/// ke data inline bila endpoint gagal (no-fake-data: tampilkan yang ada saja).
void _showAllReviews(BuildContext context, String hotelId, List<HotelReview> inline) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => _AllReviewsSheet(
        hotelId: hotelId,
        inline: inline,
        scrollController: controller,
      ),
    ),
  );
}

class _AllReviewsSheet extends StatefulWidget {
  final String hotelId;
  final List<HotelReview> inline;
  final ScrollController scrollController;
  const _AllReviewsSheet({
    required this.hotelId,
    required this.inline,
    required this.scrollController,
  });

  @override
  State<_AllReviewsSheet> createState() => _AllReviewsSheetState();
}

class _AllReviewsSheetState extends State<_AllReviewsSheet> {
  static const _limit = 10;
  List<HotelReview> _items = [];
  int _page = 1;
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _items = widget.inline;
    _load(1);
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final c = widget.scrollController;
    if (c.position.pixels >= c.position.maxScrollExtent - 200) _loadMore();
  }

  Future<void> _load(int page) async {
    try {
      final res = await ApiClient.get(
        '/hotels/${widget.hotelId}/reviews',
        params: {'page': page, 'limit': _limit},
      );
      final data = res.data['data'];
      final list = data is List ? data : [];
      final parsed = list
          .whereType<Map<String, dynamic>>()
          .map(HotelReview.fromJson)
          .where((r) => r.text.isNotEmpty)
          .toList();
      final meta = res.data['meta'];
      final total = meta is Map ? int.tryParse('${meta['total']}') ?? parsed.length : parsed.length;
      if (!mounted) return;
      setState(() {
        if (page == 1 && parsed.isNotEmpty) {
          // Server adalah sumber kebenaran; inline hanya fallback awal.
          _items = parsed;
        } else if (page > 1) {
          final ids = _items.map((e) => e.id).toSet();
          _items.addAll(parsed.where((e) => !ids.contains(e.id)));
        }
        _total = total;
        _page = page;
        _loading = false;
        _loadingMore = false;
      });
    } catch (_) {
      // Endpoint gagal (mis. DB lama): pertahankan inline, jangan kosong.
      if (!mounted) return;
      setState(() {
        _total = _items.length;
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _loadMore() {
    if (_loading || _loadingMore || _items.length >= _total) return;
    setState(() => _loadingMore = true);
    _load(_page + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSheet)),
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
          Text(
            AppLocalizations.of(context).fun_guestReviewsCount(_total == 0 ? _items.length : _total),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    controller: widget.scrollController,
                    itemCount: _items.length + (_loadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => i < _items.length
                        ? _ReviewCard(review: _items[i])
                        : const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
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

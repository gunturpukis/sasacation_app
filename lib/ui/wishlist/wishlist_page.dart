
import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/explore_model.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/data/repo/explore_repository.dart';
import 'package:sasacation/data/repo/hotel_repository.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/ui/widget/pill_badge.dart';
import 'package:sasacation/utils/money.dart';
import 'package:sasacation/viewmodel/wishlist/explore_wishlist_cubit.dart';
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
///
/// Destinasi & kuliner (EXPLORE) ikut tampil di sini lewat
/// [ExploreWishlistCubit] — dulu key `explore_wishlist_ids_cache` hanya
/// dibaca layar detailnya sendiri, sehingga hati "tersimpan" menyesatkan
/// (tab Saved kosong). Sekarang state berbagi; catatan tetap: simpan
/// lokal, belum sinkron server (kontrak `/wishlist` baru mengenal hotelId).
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
 
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}
 
class _WishlistScreenState extends State<WishlistScreen> {
  final _repo = HotelRepository();
  final _exploreRepo = ExploreRepository();
  List<HotelModel> _hotels = [];
  List<ExploreItemModel> _explore = [];
  bool _loading = true;
  // F.3: mode pilih-banding. Aktif lewat tombol di header; pilih 2–3 hotel
  // lalu dorong ke /compare. Sengaja tanpa state management baru — lokal saja.
  bool _comparing = false;
  final Set<String> _selected = {};
 
  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final hotelIds = context.read<WishlistCubit>().state;
    final exploreIds = context.read<ExploreWishlistCubit>().state;
    setState(() => _loading = true);
    final hotelResults =
        await Future.wait(hotelIds.map((id) => _repo.getHotelById(id)));
    // Backend `/explore` belum punya fetch-by-id → ambil daftar lalu saring
    // di klien (daftar explore jauh lebih kecil daripada katalog hotel).
    final exploreResults = exploreIds.isEmpty
        ? <ExploreItemModel>[]
        : (await _exploreRepo.getExplore())
            .where((e) => exploreIds.contains(e.id))
            .toList();
    if (!mounted) return;
    setState(() {
      _hotels = hotelResults.whereType<HotelModel>().toList();
      _explore = exploreResults;
      _loading = false;
      _selected.removeWhere((id) => !_hotels.any((h) => h.id == id));
      if (_hotels.length < 2) _comparing = false;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final empty = _hotels.isEmpty && _explore.isEmpty;
    return MultiBlocListener(
      listeners: [
        BlocListener<WishlistCubit, Set<String>>(
          listener: (context, _) => _loadSaved(),
        ),
        BlocListener<ExploreWishlistCubit, Set<String>>(
          listener: (context, _) => _loadSaved(),
        ),
      ],
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(l10n.fun_savedTitle,
                                      style: Theme.of(context).textTheme.headlineMedium),
                                ),
                                // F.3 entry point: bandingkan 2–3 hotel favorit
                                if (_hotels.length >= 2)
                                  TextButton.icon(
                                    onPressed: () => setState(() {
                                      _comparing = !_comparing;
                                      _selected.clear();
                                    }),
                                    icon: Icon(
                                      _comparing ? Icons.close : Icons.compare_arrows,
                                      size: 16,
                                    ),
                                    label: Text(_comparing
                                        ? (isEn ? 'Cancel' : 'Batal')
                                        : (isEn ? 'Compare' : 'Bandingkan')),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                                _comparing
                                    ? (isEn
                                        ? 'Select 2–3 hotels to compare'
                                        : 'Pilih 2–3 hotel untuk dibandingkan')
                                    : l10n.fun_savedSubtitle,
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    if (empty)
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
                    else ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final hotel = _hotels[index];
                              final checked = _selected.contains(hotel.id);
                              return _SavedDestinationCard(
                                hotel: hotel,
                                selecting: _comparing,
                                selected: checked,
                                onUnsave: () => context.read<WishlistCubit>().toggle(hotel.id),
                                onTap: () {
                                  if (_comparing) {
                                    setState(() {
                                      if (checked) {
                                        _selected.remove(hotel.id);
                                      } else if (_selected.length < 3) {
                                        _selected.add(hotel.id);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(isEn
                                                ? 'Maximum 3 hotels'
                                                : 'Maksimal 3 hotel'),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    });
                                  } else {
                                    context.push(AppRouter.hotelDetailPath(hotel.id));
                                  }
                                },
                              );
                            },
                            childCount: _hotels.length,
                          ),
                        ),
                      ),
                      // Destinasi & kuliner tersimpan (explore) — lokal.
                      if (_explore.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                            child: Text(l10n.fun_savedExploreSection,
                                style: Theme.of(context).textTheme.titleLarge),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = _explore[index];
                                return _SavedExploreCard(
                                  item: item,
                                  onUnsave: () =>
                                      context.read<ExploreWishlistCubit>().toggle(item.id),
                                  onTap: () => context
                                      .push(AppRouter.destinationDetail, extra: item),
                                );
                              },
                              childCount: _explore.length,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
        ),
        // F.3: bar bawah muncul bila 2+ hotel dipilih
        bottomNavigationBar: _comparing && _selected.length >= 2
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(
                      AppRouter.compare,
                      extra: _selected.toList(),
                    ),
                    icon: const Icon(Icons.compare_arrows, size: 18),
                    label: Text(isEn
                        ? 'Compare (${_selected.length})'
                        : 'Bandingkan (${_selected.length})'),
                  ),
                ),
              )
            : null,
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
  // F.3: mode pilih-banding — tampilkan checkbox, sembunyikan tombol love/book
  final bool selecting;
  final bool selected;

  const _SavedDestinationCard({
    required this.hotel,
    required this.onUnsave,
    required this.onTap,
    this.selecting = false,
    this.selected = false,
  });
 
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
          border: selecting && selected
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
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
                  child: selecting
                      ? Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            selected ? Icons.check_circle : Icons.radio_button_unchecked,
                            size: 24,
                            color: selected ? AppTheme.primaryColor : Colors.grey,
                          ),
                        )
                      : GestureDetector(
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

/// Kartu destinasi/kuliner tersimpan (explore) — gaya mengikuti
/// [_SavedDestinationCard] (image + gradient overlay + judul di foto).
/// Tanpa badge heuristik hotel (field-nya beda) dan tanpa tombol "Book
/// Now": CTA sebenarnya ada di layar detail (reservasi / Google Maps).
class _SavedExploreCard extends StatelessWidget {
  final ExploreItemModel item;
  final VoidCallback onUnsave;
  final VoidCallback onTap;

  const _SavedExploreCard({
    required this.item,
    required this.onUnsave,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRestaurant = item.type == 'restaurant';
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
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusCard)),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    foregroundDecoration:
                        const BoxDecoration(gradient: AppTheme.imageOverlayGradient),
                    child: Image.network(
                      item.image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppTheme.surfaceContainerHigh,
                        child: const Icon(Icons.image_not_supported_outlined,
                            color: AppTheme.outline),
                      ),
                    ),
                  ),
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
                      child: const Icon(Icons.favorite_rounded,
                          size: 18, color: AppTheme.loveColor),
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  bottom: 12,
                  right: 12,
                  child: Text(item.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(AppTheme.radiusCard)),
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
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: AppTheme.onSurfaceVariant),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(item.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        item.price > 0
                            ? MoneyText(
                                item.price,
                                style: const TextStyle(
                                    color: AppTheme.secondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15),
                                suffix: isRestaurant ? l10n.fun_perPerson : '',
                                suffixStyle: const TextStyle(
                                    color: AppTheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12),
                              )
                            : Text(
                                isRestaurant
                                    ? l10n.fun_priceVaried
                                    : l10n.fun_freeLabel,
                                style: const TextStyle(
                                    color: AppTheme.secondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15),
                              ),
                      ],
                    ),
                  ),
                  PillBadge(
                    label: (item.subCategory ?? item.category).toUpperCase(),
                    backgroundColor: AppTheme.primaryContainer,
                    foregroundColor: Colors.white,
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
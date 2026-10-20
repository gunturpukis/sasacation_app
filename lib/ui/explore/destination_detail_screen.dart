import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/explore_model.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/ui/widget/glass_icon_button.dart';
import 'package:sasacation/ui/widget/gallery_bento.dart';
import 'package:sasacation/ui/widget/pill_badge.dart';
import 'package:sasacation/utils/info_money_row.dart';
import 'package:sasacation/utils/money.dart';
import 'package:sasacation/viewmodel/wishlist/explore_wishlist_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

/// DestinationDetailScreen — restyle mengikuti Stitch `destination_details`
/// (Azure Sands Retreat, hero 50vh + experience indicators + bento gallery
/// + fixed booking bar) dan MTS Vol.1 sebagai jembatan DISCOVER → PLAN.
///
/// KEPUTUSAN JUJUR (no-fake-data, selaras `detail_hotels_page.dart`):
/// - "Guest Reviews" ala Stitch TIDAK diimplementasi: [ExploreItemModel]
///   hanya punya `rating` + `reviewCount`, tanpa ulasan individual.
///   Mengarang nama/kutipan reviewer berarti fake data — section disembunyi.
/// - "What's Included" (Free Wi-Fi / Pool / Breakfast) TIDAK di-hardcode:
///   model tidak punya daftar amenitas. Sebagai gantinya tampil info card
///   dari field nyata (cuisine/openHours untuk restoran, category/location
///   untuk destinasi).
/// - Wishlist destinasi/restoran bersifat LOKAL (SharedPreferences
///   `explore_wishlist_ids_cache` lewat `ExploreWishlistCubit`). Backend
///   `/wishlist` saat ini hanya mengenal hotelId (lihat
///   `WishlistRepository.toggle`), jadi sinkron server untuk explore item
///   belum dimungkinkan tanpa kontrak backend baru — TAPI state dibagikan
///   ke tab Saved lewat cubit supaya hati tidak menyesatkan.
/// - CTA tunggal per layar (v1.1 spec): restoran → bottom-sheet reservasi
///   informatif (fulfilment penuh Year-2), destinasi → Google Maps.
class DestinationDetailScreen extends StatelessWidget {
  final ExploreItemModel item;
  const DestinationDetailScreen({super.key, required this.item});

  bool get _isRestaurant => item.type == 'restaurant';

  Future<void> _toggleWishlist(BuildContext context) async {
    final cubit = context.read<ExploreWishlistCubit>();
    final nowSaved = await cubit.toggle(item.id);
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(nowSaved
            ? l10n.fun_savedFavoriteSoon(item.name)
            : l10n.fun_removedFavorite(item.name)),
      ),
    );
  }

  Future<void> _onPrimaryAction(BuildContext context) async {
    if (_isRestaurant) {
      _showReserveSheet(context);
      return;
    }
    await _openMaps(context);
  }

  /// Buka Google Maps untuk lokasi item — dipakai CTA destinasi DAN
  /// placeholder peta (untuk restoran maupun destinasi).
  Future<void> _openMaps(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final query =
        Uri.encodeComponent('${item.name} ${item.location}');
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fun_cannotOpenMaps)),
      );
    }
  }

  void _showReserveSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSheet)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                '${item.cuisine ?? l10n.fun_cuisineFallback} • ${item.openHours ?? l10n.fun_openHoursFallback}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: AppTheme.heroButtonStyle,
                  child: Text(l10n.fun_reservationSoon),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── Hero (Stitch: 50vh, glass back/fav, badge + rating + title) ──
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: AppTheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                        color: AppTheme.surfaceContainerHigh),
                  ),
                  Container(
                      decoration: const BoxDecoration(
                          gradient: AppTheme.imageOverlayGradient)),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            PillBadge(
                              label: (item.subCategory ?? item.category)
                                  .toUpperCase(),
                              backgroundColor: AppTheme.primaryContainer,
                              foregroundColor: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.star_rounded,
                                size: 16, color: AppTheme.ratingColor),
                            const SizedBox(width: 2),
                            Text(
                              l10n.fun_ratingReviews(
                                  item.rating.toStringAsFixed(1),
                                  item.reviewCount),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(item.name,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 16, color: Colors.white70),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(item.location,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
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
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: BlocBuilder<ExploreWishlistCubit, Set<String>>(
                  builder: (context, wishlist) {
                    final saved = wishlist.contains(item.id);
                    return GlassIconButton(
                      icon: saved ? Icons.favorite : Icons.favorite_border,
                      iconColor:
                          saved ? AppTheme.loveColor : AppTheme.onSurface,
                      onTap: () => _toggleWishlist(context),
                    );
                  },
                ),
              ),
            ],
          ),

          // ── Content ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.all(AppTheme.spacingMarginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Experience indicators (Stitch floating cards) — dari
                  // field nyata, bukan data karangan.
                  SizedBox(
                    height: 64,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _indicators(item, l10n)
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.only(right: 12),
                                child: _ExperienceIndicator(
                                  icon: e.$1,
                                  title: e.$2,
                                  subtitle: e.$3,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(
                      height: AppTheme.spacingSectionGap),

                  // About (Stitch: "About the Experience")
                  Text(l10n.fun_aboutExperience,
                      style:
                          Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  Text(
                    item.description ??
                        l10n.fun_placeDescFallback(
                            item.name, item.location),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                            color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(
                      height: AppTheme.spacingSectionGap),

                  // Detail jujur pengganti "What's Included" Stitch
                  Text(l10n.fun_whatsIncluded,
                      style:
                          Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  _isRestaurant
                      ? _RestaurantInfoCard(item: item)
                      : _DestinationInfoCard(item: item),
                  const SizedBox(
                      height: AppTheme.spacingSectionGap),

                  // PLAN bridge (MTS DISCOVER → PLAN): dua aksi sekunder.
                  // CTA primer tunggal tetap di bottom bar (v1.1 spec).
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.push(AppRouter.tripPlanner),
                          icon: const Icon(Icons.luggage_outlined,
                              size: 18),
                          label: Text(l10n.auth_aiTripPlanner),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(
                                color: AppTheme.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusCard)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.push(AppRouter.aiChat),
                          icon: const Icon(Icons.smart_toy_outlined,
                              size: 18),
                          label: Text(l10n.auth_aiAskSasa),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.tertiary,
                            side: const BorderSide(
                                color: AppTheme.tertiary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusCard)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height: AppTheme.spacingSectionGap),

                  // Gallery bento (Stitch: 2x2 + wide + 2 small + "+N")
                  if (item.images.length >= 3) ...[
                    Text(l10n.fun_propertyTitle,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium),
                    const SizedBox(height: 12),
                    GalleryBento(images: item.images),
                    const SizedBox(
                        height: AppTheme.spacingSectionGap),
                  ] else if (item.images.length > 1) ...[
                    Text(l10n.fun_photoGallery,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: item.images.length,
                        itemBuilder: (context, i) => Padding(
                          padding:
                              const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusMd),
                            child: Image.network(
                              item.images[i],
                              width: 140,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 140,
                                color:
                                    AppTheme.surfaceContainerHigh,
                                child: const Icon(Icons.image,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: AppTheme.spacingSectionGap),
                  ],

                  // Map placeholder → Google Maps (tanpa Maps SDK,
                  // selaras keputusan di hotel detail). Berlaku untuk
                  // restoran DAN destinasi — bukan shortcut ke sheet.
                  InkWell(
                    borderRadius: BorderRadius.circular(
                        AppTheme.radiusLg),
                    onTap: () => _openMaps(context),
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(
                            AppTheme.radiusLg),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.map_outlined,
                                size: 40,
                                color: AppTheme.outline),
                            const SizedBox(height: 10),
                            Text(
                              l10n.fun_mapLocationName(item.name),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium,
                            ),
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

      // ── Fixed booking bar (Stitch) ───────────────────────────────
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
                    Text(
                      _isRestaurant
                          ? l10n.fun_avgPerPerson
                          : l10n.fun_entryTicket,
                      style:
                          Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 2),
                    item.price > 0
                        ? MoneyText(item.price,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ))
                        : Text(
                            l10n.fun_freeLabel,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _onPrimaryAction(context),
                  style: AppTheme.heroButtonStyle,
                  child: Text(
                    _isRestaurant
                        ? l10n.fun_reserveAction
                        : l10n.fun_directionsAction,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Indikator dari field nyata — tanpa mengarang amenitas Stitch.
  List<(IconData, String, String)> _indicators(
      ExploreItemModel item, AppLocalizations l10n) {
    if (item.type == 'restaurant') {
      return [
        (Icons.restaurant_menu, l10n.fun_cuisineType,
            item.cuisine ?? l10n.fun_cuisineFallback),
        (Icons.schedule, l10n.fun_openHours,
            item.openHours ?? l10n.fun_openHoursFallback),
        (Icons.star_rounded, l10n.fun_filterRating,
            item.rating.toStringAsFixed(1)),
      ];
    }
    return [
      (Icons.category, l10n.fun_categoryLabel,
          item.subCategory ?? item.category),
      (Icons.location_on_outlined, l10n.fun_locationLabel,
          item.location.split(',').first.trim()),
      (Icons.confirmation_number_outlined, l10n.fun_entryTicket,
          item.price > 0 ? Money.formatSync(item.price) : l10n.fun_freeLabel),
    ];
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _ExperienceIndicator extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _ExperienceIndicator(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.labelSmall),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

// Restoran: pakai field cuisine dan openHours dari model
class _RestaurantInfoCard extends StatelessWidget {
  final ExploreItemModel item;
  const _RestaurantInfoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _InfoCard(
      rows: [
        _InfoRow(
          icon: Icons.restaurant_menu,
          label: l10n.fun_cuisineType,
          value: item.cuisine ?? l10n.fun_cuisineFallback,
        ),
        _InfoRow(
          icon: Icons.schedule,
          label: l10n.fun_openHours,
          value: item.openHours ?? l10n.fun_openHoursFallback,
        ),
        InfoMoneyRow(
          icon: Icons.attach_money,
          label: l10n.fun_avgPrice,
          usd: item.price,
          suffix: l10n.fun_perPerson,
          emptyText: l10n.fun_priceVaried,
        ),
      ],
    );
  }
}

// Destinasi wisata
class _DestinationInfoCard extends StatelessWidget {
  final ExploreItemModel item;
  const _DestinationInfoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _InfoCard(
      rows: [
        _InfoRow(
          icon: Icons.category,
          label: l10n.fun_categoryLabel,
          value: item.subCategory ?? item.category,
        ),
        _InfoRow(
          icon: Icons.location_city,
          label: l10n.fun_locationLabel,
          value: item.location,
        ),
        _InfoMoneyRow(
          icon: Icons.confirmation_number,
          label: l10n.fun_entryTicket,
          usd: item.price,
          emptyText: l10n.fun_freeLabel,
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border:
            Border.all(color: AppTheme.outlineVariant.withOpacity(0.4)),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(children: rows),
    );
  }
}

// Varian _InfoRow untuk nominal uang (ikut kurs via MoneyText).
class _InfoMoneyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double usd;
  final String emptyText;
  const _InfoMoneyRow({
    required this.icon,
    required this.label,
    required this.usd,
    this.emptyText = '-',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Text(
            '$label:  ',
            style: const TextStyle(
                color: AppTheme.onSurfaceVariant, fontSize: 14),
          ),
          Expanded(
            child: usd > 0
                ? MoneyText(usd,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14))
                : Text(
                    emptyText,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Text(
            '$label:  ',
            style: const TextStyle(
                color: AppTheme.onSurfaceVariant, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

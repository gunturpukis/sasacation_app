import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/explore_model.dart';
import 'package:sasacation/utils/info_money_row.dart';
import 'package:sasacation/utils/money.dart';
import 'package:url_launcher/url_launcher.dart';

/// Detail screen untuk destinasi wisata dan restoran.
/// Menggunakan ExploreItemModel yang sudah punya field
/// cuisine, openHours, dan subCategory.
class DestinationDetailScreen extends StatelessWidget {
  final ExploreItemModel item;
  const DestinationDetailScreen({super.key, required this.item});

  bool get _isRestaurant => item.type == 'restaurant';

  Future<void> _onPrimaryAction(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    if (_isRestaurant) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fun_reservationSoon)),
      );
      return;
    }
    final query = Uri.encodeComponent('${item.name} ${item.location}');
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fun_cannotOpenMaps)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero image + AppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, size: 60, color: Colors.grey),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                item.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.favorite_border, color: Colors.black87),
                ),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context).fun_savedFavoriteSoon(item.name))),
                ),
              ),
            ],
          ),

          // ── Content ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating + category row
                  Row(
                    children: [
                      _RatingBadge(rating: item.rating),
                      const SizedBox(width: 8),
                      Text(
                        l10n.fun_reviewCountLabel(item.reviewCount),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      _CategoryBadge(label: item.subCategory ?? item.category),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Name
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    l10n.fun_aboutPlace,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.description ??
                        l10n.fun_placeDescFallback(item.name, item.location),
                    style: TextStyle(
                      height: 1.6,
                      color: Colors.grey.shade700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info card — berbeda untuk restoran vs destinasi
                  _isRestaurant
                      ? _RestaurantInfoCard(item: item)
                      : _DestinationInfoCard(item: item),

                  const SizedBox(height: 24),

                  // Photo gallery jika ada
                  if (item.images.length > 1) ...[
                    Text(
                      l10n.fun_photoGallery,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: item.images.length,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item.images[i],
                              width: 140,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 140,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Map placeholder
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text(
                          l10n.fun_mapLocationName(item.name),
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom bar ──────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isRestaurant ? l10n.fun_avgPerPerson : l10n.fun_entryTicket,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    item.price > 0
                        ? MoneyText(item.price,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ))
                        : Text(
                            l10n.fun_freeLabel,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _onPrimaryAction(context),
                  icon: Icon(_isRestaurant ? Icons.restaurant : Icons.directions),
                  label: Text(
                    _isRestaurant ? l10n.fun_reserveAction : l10n.fun_directionsAction,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: AppTheme.primaryColor, size: 15),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
          // Gunakan field cuisine dari model, fallback ke 'Masakan Lokal'
          value: item.cuisine ?? 'Masakan Lokal',
        ),
        _InfoRow(
          icon: Icons.schedule,
          label: l10n.fun_openHours,
          // Gunakan field openHours dari model, fallback ke string default
          value: item.openHours ?? '10:00 - 22:00',
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
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
      ),
      child: Column(children: rows),
    );
  }
}

// Varian _InfoRow untuk nominal uang (ikut kurs via MoneyText).
// Bila [usd] <= 0 tampil [emptyText] polos (mis. 'Gratis', 'Variatif').
class _InfoMoneyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double usd;
  final String suffix;
  final String emptyText;
  const _InfoMoneyRow({
    required this.icon,
    required this.label,
    required this.usd,
    this.suffix = '',
    this.emptyText = '-',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Text(
            '$label:  ',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Expanded(
            child: usd > 0
                ? MoneyText(usd,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                    suffix: suffix)
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
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Text(
            '$label:  ',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

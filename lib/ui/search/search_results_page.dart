import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/ui/widget/pill_badge.dart';
import 'package:sasacation/utils/money.dart';
import 'package:sasacation/viewmodel/search/hotel_search_cubit.dart';
import 'package:sasacation/viewmodel/wishlist/wishlist_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
/// View: SearchResultsScreen
/// Halaman perantara baru antara Home dan Hotel Detail, meniru pola Agoda:
/// search -> hasil pencarian dengan filter & sort -> detail hotel.
/// Menggunakan HotelSearchCubit (page-scoped) supaya tidak menabrak
/// HotelBloc composite state yang dipakai Home & Hotel Detail.
class SearchResultsScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchResultsScreen({super.key, this.initialQuery});
 
  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}
 
class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _searchCtrl;
  List<String> _recents = [];

  static const _recentsKey = 'recent_searches';
  static const _maxRecents = 5;

  /// F5: personalisasi AI dari Settings. OFF = kartu AI Pick disembunyikan.
  bool _aiEnabled = true;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery ?? '');
    _searchCtrl.addListener(() => setState(() {}));
    context.read<HotelSearchCubit>().search(query: widget.initialQuery);
    _loadRecents();
    _loadAiPref();
  }

  Future<void> _loadAiPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(
        () => _aiEnabled = prefs.getBool('ai_personalization') ?? true);
  }

  Future<void> _loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _recents = prefs.getStringList(_recentsKey) ?? []);
  }

  /// Riwayat tersimpan lokal (SharedPreferences) — tanpa backend.
  Future<void> _saveRecent(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = [q, ..._recents.where((e) => e.toLowerCase() != q.toLowerCase())]
        .take(_maxRecents)
        .toList();
    await prefs.setStringList(_recentsKey, updated);
    if (!mounted) return;
    setState(() => _recents = updated);
  }

  Future<void> _clearRecents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentsKey);
    if (!mounted) return;
    setState(() => _recents = []);
  }

  void _submitSearch(String q) {
    _saveRecent(q);
    context.read<HotelSearchCubit>().search(query: q);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context),
            _buildFilterChips(context),
            Expanded(child: _buildResultList(context)),
          ],
        ),
      ),
    );
  }
 
  Widget _buildSearchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              ),
              child: TextField(
                controller: _searchCtrl,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l10n.fun_searchHotelHint,
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.primary),
                ),
                onSubmitted: _submitSearch,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: GestureDetector(
              onTap: () => _openFilterSheet(context),
              child: const Icon(Icons.tune, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildFilterChips(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<HotelSearchCubit, HotelSearchState>(
      builder: (context, state) {
        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _FilterChip(
                label: l10n.fun_filterAll,
                icon: Icons.tune,
                filled: true,
                onTap: () => _openFilterSheet(context),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: state.minPrice != null || state.maxPrice != null ? l10n.fun_filterPriceActive : l10n.fun_filterPrice,
                onTap: () => _openFilterSheet(context),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: state.minRating > 0 ? l10n.fun_filterRatingValue(state.minRating.toStringAsFixed(0)) : l10n.fun_filterRating,
                onTap: () => _openFilterSheet(context),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: state.amenities.isEmpty
                    ? l10n.fun_filterAmenities
                    : l10n.fun_filterAmenitiesCount(state.amenities.length),
                onTap: () => _openFilterSheet(context),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: _sortLabel(context, state.sort),
                icon: Icons.swap_vert,
                onTap: () => _openSortSheet(context),
              ),
            ],
          ),
        );
      },
    );
  }

  String _sortLabel(BuildContext context, HotelSortOption sort) {
    final l10n = AppLocalizations.of(context);
    return switch (sort) {
      HotelSortOption.priceLowHigh => l10n.fun_sortCheapest,
      HotelSortOption.priceHighLow => l10n.fun_sortExpensive,
      HotelSortOption.ratingHigh => l10n.fun_filterRating,
      HotelSortOption.newest => l10n.fun_sortNewest,
      HotelSortOption.recommended => l10n.fun_sortDefault,
    };
  }

  Widget _buildResultList(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<HotelSearchCubit, HotelSearchState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = state.results;
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(state.error ?? l10n.fun_noResults, textAlign: TextAlign.center),
              ],
            ),
          );
        }
        // "AI Pick": rekomendasi rating tertinggi dari hasil nyata —
        // bukan dari backend AI, tapi deterministik dari data yang ada.
        // Disembunyikan bila personalisasi AI dimatikan di Settings (F5).
        final queryEmpty = _searchCtrl.text.trim().isEmpty;
        final showRecents = queryEmpty && _recents.isNotEmpty;
        final HotelModel? aiPick =
            (_aiEnabled && !queryEmpty && results.length >= 2)
                ? results.reduce((a, b) => a.rating >= b.rating ? a : b)
                : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showRecents) _buildRecents(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(l10n.fun_propertiesFound(results.length),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final hotel = results[index];
                  return BlocBuilder<WishlistCubit, Set<String>>(
                    builder: (context, wishlist) {
                      final saved = wishlist.contains(hotel.id);
                      return _HotelResultCard(
                        name: hotel.name,
                        location: hotel.location,
                        image: hotel.image,
                        price: hotel.price,
                        rating: hotel.rating,
                        reviewCount: hotel.reviewCount,
                        amenities: hotel.amenities,
                        isSaved: saved,
                        onSave: () => context.read<WishlistCubit>().toggle(hotel.id),
                        onTap: () => context.push(
                          AppRouter.hotelDetailPath(hotel.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (aiPick != null) _buildAiPick(context, aiPick),
          ],
        );
      },
    );
  }

  /// Riwayat pencarian lokal — mengikuti desain ("Recent Searches" + Clear All).
  Widget _buildRecents() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.fun_recentSearches,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
              TextButton(
                onPressed: _clearRecents,
                child: Text(l10n.fun_clearAll, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ..._recents.map((q) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  onTap: () {
                    _searchCtrl.text = q;
                    _submitSearch(q);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: AppTheme.softCardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                          ),
                          child: const Icon(Icons.history,
                              size: 18, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(q,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                        const Icon(Icons.chevron_right,
                            size: 18, color: AppTheme.outline),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// Kartu "AI Pick for You" mengikuti desain — isinya hotel rating tertinggi
  /// dari hasil pencarian nyata (deterministik, tanpa backend AI).
  Widget _buildAiPick(BuildContext context, HotelModel hotel) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border:
            Border.all(color: AppTheme.secondaryContainer.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(l10n.fun_aiPickTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          Text(hotel.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            l10n.fun_aiPickDesc(hotel.rating.toStringAsFixed(1)),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  context.push(AppRouter.hotelDetailPath(hotel.id)),
              style: AppTheme.heroButtonStyle,
              child: Text(l10n.fun_viewDetail,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
 
  /// Opsi amenities = string persis seperti tersimpan di backend
  /// (F3: filter AND, case-sensitive). Diverifikasi via curl.
  static const _amenityOptions = [
    'WiFi',
    'Pool',
    'Restaurant',
    'Spa',
    'Bar',
    'Private Beach',
  ];

  void _openFilterSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<HotelSearchCubit>();
    double minRating = cubit.state.minRating;
    final selectedAmenities = List<String>.of(cubit.state.amenities);
    final minCtrl = TextEditingController(text: cubit.state.minPrice?.toStringAsFixed(0) ?? '');
    final maxCtrl = TextEditingController(text: cubit.state.maxPrice?.toStringAsFixed(0) ?? '');
 
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.fun_filterTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(l10n.fun_priceRangeLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: l10n.fun_minHint,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: l10n.fun_maxHint,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(l10n.fun_minRatingLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [0.0, 3.0, 4.0, 4.5].map((r) {
                  final selected = minRating == r;
                  return ChoiceChip(
                    label: Text(r == 0 ? l10n.fun_allLabel : '$r+'),
                    selected: selected,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: selected ? AppTheme.primaryColor : Colors.black87,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setSheetState(() => minRating = r),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(l10n.fun_amenitiesMustAll, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _amenityOptions.map((a) {
                  final selected = selectedAmenities.contains(a);
                  return FilterChip(
                    label: Text(a),
                    selected: selected,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: selected ? AppTheme.primaryColor : Colors.black87,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setSheetState(() {
                      if (selected) {
                        selectedAmenities.remove(a);
                      } else {
                        selectedAmenities.add(a);
                      }
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    cubit.setMinRating(minRating);
                    cubit.applyPriceRange(
                      double.tryParse(minCtrl.text),
                      double.tryParse(maxCtrl.text),
                    );
                    cubit.setAmenities(selectedAmenities);
                    Navigator.pop(sheetContext);
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text(l10n.fun_applyFilter, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  void _openSortSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<HotelSearchCubit>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.fun_sortByTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            _SortTile(l10n.fun_sortRecommended, HotelSortOption.recommended, cubit, sheetContext),
            _SortTile(l10n.fun_sortPriceLow, HotelSortOption.priceLowHigh, cubit, sheetContext),
            _SortTile(l10n.fun_sortPriceHigh, HotelSortOption.priceHighLow, cubit, sheetContext),
            _SortTile(l10n.fun_sortRatingHigh, HotelSortOption.ratingHigh, cubit, sheetContext),
            _SortTile(l10n.fun_sortNewest, HotelSortOption.newest, cubit, sheetContext),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
 
class _SortTile extends StatelessWidget {
  final String label;
  final HotelSortOption option;
  final HotelSearchCubit cubit;
  final BuildContext sheetContext;
  const _SortTile(this.label, this.option, this.cubit, this.sheetContext);
 
  @override
  Widget build(BuildContext context) {
    final selected = cubit.state.sort == option;
    return ListTile(
      title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      trailing: selected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
      onTap: () {
        cubit.setSort(option);
        Navigator.pop(sheetContext);
      },
    );
  }
}
 
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool filled;
  final VoidCallback onTap;
  const _FilterChip({required this.label, this.icon, this.filled = false, required this.onTap});
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppTheme.primaryContainer : AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: filled ? null : Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: filled ? Colors.white : AppTheme.onSurfaceVariant),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(
                    fontSize: 12.5,
                    color: filled ? Colors.white : AppTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
 
class _HotelResultCard extends StatelessWidget {
  final String name, location, image;
  final double price, rating;
  final int reviewCount;
  final List<String> amenities;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onTap;
 
  const _HotelResultCard({
    required this.name,
    required this.location,
    required this.image,
    required this.price,
    required this.rating,
    required this.reviewCount,
    this.amenities = const [],
    required this.isSaved,
    required this.onSave,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
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
                  child: Image.network(
                    image,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: AppTheme.surfaceContainerHigh,
                      child: const Icon(Icons.image_not_supported_outlined, color: AppTheme.outline),
                    ),
                  ),
                ),
                Positioned(bottom: 10, left: 10, child: PillBadge.rating(rating, glass: true)),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onSave,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 16,
                        color: isSaved ? AppTheme.loveColor : AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      MoneyText(price,
                          style: const TextStyle(
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.onSurfaceVariant),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ],
                  ),
                  if (amenities.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: amenities.take(2).map((a) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                            ),
                            child: Text(a,
                                style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant)),
                          )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
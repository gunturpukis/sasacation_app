import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/ui/widget/pill_badge.dart';
import 'package:sasacation/viewmodel/search/hotel_search_cubit.dart';
import 'package:sasacation/viewmodel/wishlist/wishlist_cubit.dart';
 
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
 
  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery ?? '');
    context.read<HotelSearchCubit>().search(query: widget.initialQuery);
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
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Cari hotel atau lokasi...',
                  prefixIcon: Icon(Icons.search, size: 20, color: AppTheme.primary),
                ),
                onSubmitted: (q) => context.read<HotelSearchCubit>().search(query: q),
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
    return BlocBuilder<HotelSearchCubit, HotelSearchState>(
      builder: (context, state) {
        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _FilterChip(
                label: 'Semua filter',
                icon: Icons.tune,
                filled: true,
                onTap: () => _openFilterSheet(context),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: state.minPrice != null || state.maxPrice != null ? 'Harga •' : 'Harga',
                onTap: () => _openFilterSheet(context),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: state.minRating > 0 ? 'Rating ${state.minRating.toStringAsFixed(0)}+' : 'Rating',
                onTap: () => _openFilterSheet(context),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Urutkan',
                icon: Icons.swap_vert,
                onTap: () => _openSortSheet(context),
              ),
            ],
          ),
        );
      },
    );
  }
 
  Widget _buildResultList(BuildContext context) {
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
                Text(state.error ?? 'Tidak ada hasil', textAlign: TextAlign.center),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('${results.length} properti ditemukan',
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
                          AppRouter.hotelDetail.replaceFirst(':id', hotel.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
 
  void _openFilterSheet(BuildContext context) {
    final cubit = context.read<HotelSearchCubit>();
    double minRating = cubit.state.minRating;
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
              const Text('Filter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Rentang harga per malam (\$)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Min',
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
                        hintText: 'Max',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Rating minimum', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [0.0, 3.0, 4.0, 4.5].map((r) {
                  final selected = minRating == r;
                  return ChoiceChip(
                    label: Text(r == 0 ? 'Semua' : '$r+'),
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
                    Navigator.pop(sheetContext);
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Terapkan Filter', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  void _openSortSheet(BuildContext context) {
    final cubit = context.read<HotelSearchCubit>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Urutkan berdasarkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            _SortTile('Rekomendasi', HotelSortOption.recommended, cubit, sheetContext),
            _SortTile('Harga terendah', HotelSortOption.priceLowHigh, cubit, sheetContext),
            _SortTile('Harga tertinggi', HotelSortOption.priceHighLow, cubit, sheetContext),
            _SortTile('Rating tertinggi', HotelSortOption.ratingHigh, cubit, sheetContext),
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
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: '\$${price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: AppTheme.secondary, fontWeight: FontWeight.w700, fontSize: 15)),
                          ],
                        ),
                      ),
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
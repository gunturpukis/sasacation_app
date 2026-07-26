import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/ui/hotels/detail_hotels_page.dart';
import 'package:sasacation/ui/hotels/featured_hotel_page.dart';
import 'package:sasacation/ui/hotels/nearby_hotel_page.dart';
import 'package:sasacation/ui/widget/category_widget.dart';
import 'package:sasacation/ui/widget/gradient_image_card.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/viewmodel/recommendation/recommendation_cubit.dart';
 
/// HomeScreen — restyle mengikuti mockup `home_discover_destinations`.
///
/// PERUBAHAN STRUKTUR dari versi sebelumnya (bukan cuma reskin warna):
/// - HeroBanner (gambar besar di background) DIHAPUS. Mockup tidak punya
///   hero image di Home — cuma AppBar polos + headline teks.
/// - Search bar sebelumnya "mengambang" di atas HeroBanner (Positioned,
///   bottom: -28). Sekarang inline mengikuti alur konten biasa, sesuai
///   mockup ("Floating white container... sitting prominently" tapi tanpa
///   hero image di baliknya).
/// - Urutan section diubah mengikuti mockup persis: Search → Recommended for
///   You → Popular Categories → Trending This Week.
///
/// UPDATE: 2 TODO dari batch pertama SUDAH DISELESAIKAN —
/// - Icon menu (kiri atas) sekarang membuka quick-menu bottom sheet nyata
///   (Saved/My Bookings/Notifications/Settings), bukan placeholder kosong.
/// - Avatar (kanan atas) sekarang benar-benar pindah ke tab Profile lewat
///   callback `onNavigateToTab` dari MainNavigation (lihat
///   main_navigation_page.dart — HomeScreen sekarang dikonstruksi dengan
///   callback, bukan `const HomeScreen()` polos lagi).
///
/// CATATAN JUJUR (masih belum diselesaikan):
/// - FeaturedHotels & NearbyHotels (isi "Trending This Week") BELUM diubah
///   tampilan kartunya — itu widget terpisah yang dipakai juga di layar
///   lain, di luar scope perbaikan ini. Cuma judul section yang diselaraskan.
class HomeScreen extends StatelessWidget {
  /// Callback untuk pindah tab di MainNavigation induk (index 3 = Profile).
  /// FIX dari TODO batch 1: sebelumnya avatar cuma bisa ke wishlist karena
  /// HomeScreen tidak dikonstruksi dengan akses ke tab controller induk.
  final void Function(int index)? onNavigateToTab;
 
  const HomeScreen({super.key, this.onNavigateToTab});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _TopBar(onNavigateToTab: onNavigateToTab)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMarginMobile,
                12,
                AppTheme.spacingMarginMobile,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Where to next?', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text('Find your dream vacation with AI assistance',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    const _SearchBar(),
                    const SizedBox(height: AppTheme.spacingSectionGap),
 
                    // ─── Recommended for You ─────────────────────────────
                    const _SectionHeader(title: 'Recommended for You', actionLabel: 'See all'),
                    const SizedBox(height: 12),
                    const _RecommendedSection(),
                    const SizedBox(height: AppTheme.spacingSectionGap),
 
                    // ─── Popular Categories ───────────────────────────────
                    Text('Popular Categories', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    const CategoryGrid(),
                    const SizedBox(height: AppTheme.spacingSectionGap),
 
                    // ─── Trending This Week ───────────────────────────────
                    const _SectionHeader(
                        title: 'Trending This Week', badgeLabel: 'New Arrivals'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMarginMobile),
              sliver: SliverToBoxAdapter(child: FeaturedHotels()),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: NearbyHotels(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
 
/// Top bar: menu (placeholder) — wordmark "Sasacation" — avatar.
/// Mengikuti mockup: bukan AppBar transparan di atas foto lagi (karena
/// HeroBanner sudah dihapus), tapi tetap bikin efek "glass" tipis sesuai
/// DESIGN.md ("Glass AppBars") lewat warna surface semi-transparan.
class _TopBar extends StatelessWidget {
  final void Function(int index)? onNavigateToTab;
  const _TopBar({this.onNavigateToTab});
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMarginMobile, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            // FIX dari TODO batch 1: sebelumnya kosong karena app tidak
            // punya Drawer. Sekarang buka quick-menu bottom sheet berisi
            // shortcut ke screen yang sudah nyata ada (bukan Drawer, tapi
            // menyelesaikan kebutuhan yang sama tanpa refactor Scaffold).
            onPressed: () => _showQuickMenu(context),
            icon: const Icon(Icons.menu, color: AppTheme.primary),
          ),
          Text('Sasacation',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: AppTheme.primary, fontSize: 22)),
          GestureDetector(
            // FIX dari TODO batch 1: sekarang benar-benar pindah ke tab
            // Profile (index 3) lewat callback dari MainNavigation, bukan
            // ke wishlist sebagai placeholder lagi.
            onTap: () => onNavigateToTab?.call(3),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryContainer, width: 2),
              ),
              child: const CircleAvatar(
                backgroundColor: AppTheme.surfaceContainerHigh,
                child: Icon(Icons.person, color: AppTheme.primary, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  void _showQuickMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSheet)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.bookmark_border, color: AppTheme.primary),
              title: const Text('Saved Destinations'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push(AppRouter.wishlist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.confirmation_number_outlined, color: AppTheme.primary),
              title: const Text('My Bookings'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push(AppRouter.myBookings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined, color: AppTheme.primary),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push(AppRouter.notifications);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppTheme.primary),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push(AppRouter.settings);
              },
            ),
          ],
        ),
      ),
    );
  }
}
 
/// Search bar inline (bukan floating lagi) — sesuai mockup: input teks +
/// tombol filter teal terpisah di ujung kanan.
class _SearchBar extends StatelessWidget {
  const _SearchBar();
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRouter.searchResults),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.floatingShadow,
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            const Icon(Icons.search, color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Search destinations, villas, or activities...',
                  style: TextStyle(color: AppTheme.outline, fontSize: 14)),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
 
/// Header section standar (judul + "See all" ATAU badge kecil) — dipakai
/// berulang untuk "Recommended for You" dan "Trending This Week".
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final String? badgeLabel;
 
  const _SectionHeader({required this.title, this.actionLabel, this.badgeLabel});
 
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (actionLabel != null)
          Text(actionLabel!, style: const TextStyle(color: AppTheme.primary, fontSize: 13)),
        if (badgeLabel != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(badgeLabel!,
                style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant)),
          ),
      ],
    );
  }
}
 
/// Section "Recommended for You" — sekarang pakai GradientImageCard bersama
/// (lihat lib/ui/widget/gradient_image_card.dart), gantikan card custom lama
/// yang stylenya beda sendiri. Logic BLoC-nya TIDAK berubah dari patch #3.
class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection();
 
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendationCubit, RecommendationState>(
      builder: (context, state) {
        if (state is! RecommendationLoaded || state.hotels.isEmpty) {
          return const SizedBox.shrink();
        }
 
        return SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.hotels.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final hotel = state.hotels[index];
              return GradientImageCard(
                width: 260,
                imageUrl: hotel.image,
                title: hotel.name,
                location: hotel.location,
                price: hotel.price,
                rating: hotel.rating,
                overlayBadgeLabel: index == 0 ? 'Most Popular' : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HotelDetailScreen(hotelId: hotel.id)),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
 
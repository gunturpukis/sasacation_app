import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/ui/hotels/featured_hotel_page.dart';
import 'package:sasacation/ui/widget/category_widget.dart';
import 'package:sasacation/ui/widget/hero_banner.dart';
import 'package:sasacation/viewmodel/wishlist/wishlist_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const HeroBanner(),
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sasacation',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                          GestureDetector(
                            onTap: () => context.push(AppRouter.wishlist),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: BlocBuilder<WishlistCubit, Set<String>>(
                                builder: (context, wishlist) => Icon(
                                  wishlist.isEmpty ? Icons.favorite_border : Icons.favorite,
                                  color: Colors.white, size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20, right: 20, bottom: -28,
                  child: _SearchCard(),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Explore Lombok',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Discover paradise islands, beaches & culture',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade600)),
                  const CategoryGrid(),
                  const SizedBox(height: 28),

                  // ─── AI Feature Banner ──────────────────────────────────
                  const _AiBanner(),
                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Featured Hotels',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () {}, child: const Text('See All')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(child: FeaturedHotels()),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

/// Kartu pencarian mengambang ala Agoda: tap membuka SearchResultsScreen.
/// Diletakkan di Home (bukan hanya di dalam Explore tab) supaya jalur
/// booking-first langsung terlihat di layar pertama, sesuai rekomendasi BA.
class _SearchCard extends StatelessWidget {
  const _SearchCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRouter.searchResults),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        shadowColor: Colors.black26,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.search, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 10),
                  Text('Mau ke mana? Cari hotel...',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 15, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text('Pilih tanggal', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(width: 18),
                  Icon(Icons.people_outline, size: 15, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text('Jumlah tamu', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiBanner extends StatelessWidget {
  const _AiBanner();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 18),
            const SizedBox(width: 8),
            const Text('Fitur AI',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _AiCard(
                icon: Icons.chat_bubble_outline,
                title: 'Tanya Sasa',
                subtitle: 'AI travel assistant',
                color: const Color(0xFF00A896),
                onTap: () => context.push(AppRouter.aiChat),
              ),
              const SizedBox(width: 12),
              _AiCard(
                icon: Icons.manage_search,
                title: 'Smart Search',
                subtitle: 'Cari dengan bahasa natural',
                color: const Color(0xFF4299E1),
                onTap: () => context.push(AppRouter.smartSearch),
              ),
              const SizedBox(width: 12),
              _AiCard(
                icon: Icons.map_outlined,
                title: 'Trip Planner',
                subtitle: 'Itinerary otomatis',
                color: const Color(0xFF48BB78),
                onTap: () => context.push(AppRouter.tripPlanner),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AiCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AiCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.75)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const Spacer(),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

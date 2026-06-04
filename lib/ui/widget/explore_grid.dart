import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/explore_model.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/ui/explore/destination_detail_screen.dart';
import 'package:sasacation/ui/hotels/detail_hotels_page.dart';
import 'package:sasacation/viewmodel/explore/explore_bloc.dart';

class ExploreGrid extends StatelessWidget {
  const ExploreGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreBloc, ExploreState>(
      builder: (context, state) {
        if (state is ExploreLoading || state is ExploreInitial) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ExploreError) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(state.message, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<ExploreBloc>().add(ExploreItemsRequested()),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is ExploreLoaded) {
          final items = state.items;
          if (items.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('Tidak ada tempat ditemukan',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                    SizedBox(height: 4),
                    Text('Coba kata kunci lain',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            );
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.75,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => ExploreGridCard(item: items[index]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class ExploreGridCard extends StatelessWidget {
  final ExploreItemModel item;
  const ExploreGridCard({super.key, required this.item});

  void _onTap(BuildContext context) {
    // FIX: navigasi ke detail yang sesuai berdasarkan type
    switch (item.type) {
      case 'hotel':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => HotelDetailScreen(hotelId: item.id)));
        break;
      case 'destination':
      case 'restaurant':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => DestinationDetailScreen(item: item)));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name} — coming soon')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    item.image,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text(item.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                // Category badge
                Positioned(
                  bottom: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
                    child: Text(item.category,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(item.location,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (item.price > 0) ...[
                    Row(
                      children: [
                        Text('\$${item.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        if (item.type == 'hotel')
                          const Text(' / malam', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        if (item.type == 'restaurant')
                          const Text(' / orang', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Gratis',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w500,
                              color: AppTheme.secondaryColor)),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/ui/hotels/detail_hotels_page.dart';
import 'package:sasacation/viewmodel/hotel/hotel_bloc.dart';

class FeaturedHotels extends StatefulWidget {
  const FeaturedHotels({super.key});

  @override
  State<FeaturedHotels> createState() => _FeaturedHotelsState();
}

class _FeaturedHotelsState extends State<FeaturedHotels> {
  @override
  void initState() {
    super.initState();
    context.read<HotelBloc>().add(HotelFeaturedRequested());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: BlocBuilder<HotelBloc, HotelState>(
        builder: (context, state) {
          // FIX: baca dari HotelCompositeState
          if (state is HotelCompositeState) {
            if (state.isLoadingFeatured) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.featuredError != null && state.featuredHotels == null) {
              return Center(child: Text(state.featuredError!));
            }
            final hotels = state.featuredHotels ?? [];
            if (hotels.isEmpty) return const Center(child: CircularProgressIndicator());
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotels[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HotelDetailScreen(hotelId: hotel.id)),
                  ),
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16),
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Image.network(
                                  hotel.image,
                                  height: 160, width: double.infinity, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 160, color: Colors.grey.shade200,
                                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12, right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 14),
                                      const SizedBox(width: 4),
                                      Text(hotel.rating.toStringAsFixed(1),
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(hotel.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Row(children: [
                                  const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(hotel.location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ]),
                                const SizedBox(height: 8),
                                Row(children: [
                                  Text('\$${hotel.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                                  const Text(' / malam', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

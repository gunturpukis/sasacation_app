import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/ui/widget/booking_sheets.dart';
import 'package:sasacation/viewmodel/hotel/hotel_bloc.dart';
import 'package:sasacation/viewmodel/wishlist/wishlist_cubit.dart';

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
    return BlocBuilder<HotelBloc, HotelState>(
      builder: (context, state) {
        // FIX: baca dari HotelCompositeState
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
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.detailError!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<HotelBloc>()
                          .add(HotelDetailRequested(hotelId: widget.hotelId)),
                      child: const Text('Coba Lagi'),
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
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 350,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(hotel.image, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300)),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(hotel.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back, color: Colors.black87),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    BlocBuilder<WishlistCubit, Set<String>>(
                      builder: (context, wishlist) {
                        final saved = wishlist.contains(hotel.id);
                        return IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Icon(saved ? Icons.favorite : Icons.favorite_border,
                                color: saved ? Colors.redAccent : Colors.black87),
                          ),
                          onPressed: () => context.read<WishlistCubit>().toggle(hotel.id),
                        );
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: AppTheme.primaryColor, size: 16),
                                  const SizedBox(width: 4),
                                  Text(hotel.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                          color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('Excellent', style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(width: 8),
                            Text('(${hotel.reviewCount} ulasan)',
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(hotel.name,
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 18, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(hotel.address ?? hotel.location,
                                  style: TextStyle(color: Colors.grey.shade600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        const Text('Tentang Hotel',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(
                          hotel.description ??
                              'Nikmati pengalaman menginap yang tak terlupakan di ${hotel.name}. '
                              'Dengan fasilitas lengkap dan layanan prima, hotel ini menawarkan kenyamanan terbaik.',
                          style: TextStyle(height: 1.6, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 24),
                        const Text('Fasilitas',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: hotel.amenities.isNotEmpty
                              ? hotel.amenities
                                  .map((a) => AmenityChip(icon: _amenityIcon(a), label: a))
                                  .toList()
                              : const [
                                  AmenityChip(icon: Icons.wifi, label: 'Free WiFi'),
                                  AmenityChip(icon: Icons.pool, label: 'Pool'),
                                  AmenityChip(icon: Icons.restaurant, label: 'Restaurant'),
                                ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map, size: 48, color: Colors.grey),
                                SizedBox(height: 12),
                                Text('Peta lokasi hotel'),
                              ],
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Harga per malam', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('\$${hotel.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
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
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (_) => BookingSheet(hotel: hotel),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('Book Now',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

class AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const AmenityChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/core/location_service.dart';
import 'package:sasacation/ui/hotels/detail_hotels_page.dart';
import 'package:sasacation/viewmodel/hotel/hotel_bloc.dart';

/// Menampilkan hotel terdekat dari lokasi GPS user saat ini.
/// Alur: minta izin lokasi → ambil koordinat → dispatch HotelNearbyRequested
/// → HotelBloc panggil GET /hotels/nearby di backend.
class NearbyHotels extends StatefulWidget {
  const NearbyHotels({super.key});

  @override
  State<NearbyHotels> createState() => _NearbyHotelsState();
}

class _NearbyHotelsState extends State<NearbyHotels> {
  bool _permissionDenied = false;
  String? _errorMessage;

  Future<void> _loadNearby() async {
    setState(() {
      _permissionDenied = false;
      _errorMessage = null;
    });

    final result = await LocationService.instance.getCurrentLocation();
    if (!mounted) return;

    if (!result.isSuccess) {
      setState(() {
        _permissionDenied = true;
        _errorMessage = result.errorMessage;
      });
      return;
    }

    context.read<HotelBloc>().add(HotelNearbyRequested(
          latitude: result.position!.latitude,
          longitude: result.position!.longitude,
        ));
  }

  @override
  void initState() {
    super.initState();
    _loadNearby();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.near_me, color: AppTheme.primaryColor, size: 18),
                const SizedBox(width: 8),
                const Text('Hotel Terdekat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            if (_permissionDenied)
              TextButton(onPressed: _loadNearby, child: const Text('Coba Lagi')),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(height: 260, child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_permissionDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _errorMessage ?? 'Izin lokasi dibutuhkan untuk fitur ini',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
      );
    }

    return BlocBuilder<HotelBloc, HotelState>(
      builder: (context, state) {
        if (state is! HotelCompositeState || state.isLoadingNearby) {
          return const Center(child: CircularProgressIndicator());
        }
        final hotels = state.nearbyHotels ?? [];
        if (hotels.isEmpty) {
          return Center(
            child: Text(
              state.nearbyError ?? 'Tidak ada hotel di sekitar Anda',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          );
        }
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
                width: 220,
                margin: const EdgeInsets.only(right: 14),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        hotel.image,
                        height: 130, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 130, color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hotel.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            if (hotel.distanceKm != null)
                              Row(
                                children: [
                                  Icon(Icons.social_distance, size: 12, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text('${hotel.distanceKm!.toStringAsFixed(1)} km dari Anda',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                ],
                              ),
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
      },
    );
  }
}
